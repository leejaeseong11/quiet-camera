import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/camera_provider.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/shutter_button.dart';
import '../widgets/flash_button.dart';
import '../widgets/camera_switch_button.dart';
import '../../../../core/theme/colors.dart' as app_colors;
import '../../../camera/domain/entities/camera_settings.dart' as domain;

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraProvider);

    if (!state.hasPermission) {
      return _PermissionView(onRequest: () async {
        await openAppSettings();
        ref.read(cameraProvider.notifier).initialize();
      });
    }

    if (!state.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final settings = domain.CameraSettings(flashMode: state.flashMode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreviewWidget(controller: state.controller!),
          // Flash toggle button - top left
          Positioned(
            top: 48,
            left: 16,
            child: SafeArea(
              child: FlashButton(
                flashMode: state.flashMode,
                onToggle: () => ref.read(cameraProvider.notifier).toggleFlashMode(),
              ),
            ),
          ),
          // Camera switch button - top right
          Positioned(
            top: 48,
            right: 16,
            child: SafeArea(
              child: CameraSwitchButton(
                onSwitch: () => ref.read(cameraProvider.notifier).switchCamera(),
              ),
            ),
          ),
          // Shutter and video controls - bottom center
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShutterButton(
                  onTap: () async {
                    final path = await ref.read(cameraProvider.notifier).capturePhoto(settings);
                    if (!mounted) return;
                    if (path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved: $path')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 24),
                _VideoButton(
                  isRecording: state.isRecording,
                  onStart: () => ref.read(cameraProvider.notifier).startVideo(settings),
                  onStop: () => ref.read(cameraProvider.notifier).stopVideo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.onRequest});
  final VoidCallback onRequest;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              '카메라 권한이 필요합니다',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              '설정에서 카메라/마이크/사진 권한을 허용해주세요.',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRequest,
              child: const Text('설정 열기'),
            )
          ],
        ),
      ),
    );
  }
}

class _VideoButton extends StatelessWidget {
  const _VideoButton({required this.isRecording, required this.onStart, required this.onStop});
  final bool isRecording;
  final VoidCallback onStart;
  final Future<void> Function() onStop;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (isRecording) {
          await onStop();
        } else {
          onStart();
        }
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: isRecording ? Colors.red : Colors.transparent,
          border: Border.all(color: Colors.white, width: 3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
