import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/logger.dart';
import '../providers/camera_provider.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/shutter_button.dart';
import '../widgets/flash_button.dart';
import '../widgets/camera_switch_button.dart';
import '../widgets/zoom_slider.dart';
import '../widgets/zoom_level_indicator.dart';
import '../widgets/recording_timer.dart';
import '../../../camera/domain/entities/camera_settings.dart' as domain;
import '../../../gallery/presentation/widgets/gallery_thumbnail.dart';
import '../../../gallery/presentation/pages/gallery_view_page.dart';
import '../../../gallery/presentation/providers/latest_asset_provider.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  double _baseZoom = 1.0;
  bool _showZoomIndicator = false;
  bool _showZoomSlider = false;
  Timer? _zoomHideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).initialize();
      ref.read(latestAssetProvider.notifier).loadLatestAsset();
    });
  }

  @override
  void dispose() {
    _zoomHideTimer?.cancel();
    super.dispose();
  }

  void _showZoomUI() {
    setState(() {
      _showZoomIndicator = true;
      _showZoomSlider = true;
    });

    // Cancel existing timer
    _zoomHideTimer?.cancel();

    // Auto-hide after 2 seconds of inactivity
    _zoomHideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showZoomIndicator = false;
          _showZoomSlider = false;
        });
      }
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = ref.read(cameraProvider).currentZoom;
    Logger.info('Pinch zoom started: baseZoom=$_baseZoom', tag: 'CameraPage');
    _showZoomUI();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!ref.read(cameraProvider).isInitialized) return;

    final state = ref.read(cameraProvider);
    final newZoom =
        (_baseZoom * details.scale).clamp(state.minZoom, state.maxZoom);

    Logger.info('Pinch zoom update: scale=${details.scale}, newZoom=$newZoom',
        tag: 'CameraPage');
    ref.read(cameraProvider.notifier).setZoom(newZoom);
    _showZoomUI();
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    Logger.info('Pinch zoom ended', tag: 'CameraPage');
    // Timer in _showZoomUI will handle auto-hide
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

    final settings = domain.CameraSettings.defaults().copyWith(
      flashMode: state.flashMode,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreviewWidget(controller: state.controller!),

            // Zoom level indicator (center of screen)
            if (_showZoomIndicator)
              ZoomLevelIndicator(zoomLevel: state.currentZoom),

            // Recording timer - top center
            Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: RecordingTimer(isRecording: state.isRecording),
                ),
              ),
            ),

            // Flash toggle button - top left
            Positioned(
              top: 48,
              left: 16,
              child: SafeArea(
                child: FlashButton(
                  flashMode: state.flashMode,
                  onToggle: () =>
                      ref.read(cameraProvider.notifier).toggleFlashMode(),
                ),
              ),
            ),
            // Camera switch button - top right
            Positioned(
              top: 48,
              right: 16,
              child: SafeArea(
                child: CameraSwitchButton(
                  onSwitch: () =>
                      ref.read(cameraProvider.notifier).switchCamera(),
                ),
              ),
            ),
            // Zoom slider - above shutter button (auto-hide)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: ZoomSlider(
                  currentZoom: state.currentZoom,
                  minZoom: state.minZoom,
                  maxZoom: state.maxZoom,
                  isVisible: _showZoomSlider,
                  onZoomChanged: (zoom) {
                    ref.read(cameraProvider.notifier).setZoom(zoom);
                    _showZoomUI();
                  },
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
                  // Gallery thumbnail - left side
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final latestAsset = ref.watch(latestAssetProvider);
                            return GalleryThumbnail(
                              latestAsset: latestAsset,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GalleryViewPage(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Shutter button - center
                  ShutterButton(
                    onTap: () async {
                      final path = await ref
                          .read(cameraProvider.notifier)
                          .capturePhoto(settings);
                      if (!mounted) return;
                      if (path != null) {
                        // Refresh gallery thumbnail
                        ref.read(latestAssetProvider.notifier).refresh();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved: $path')),
                        );
                      }
                    },
                  ),

                  // Video button - right side
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: _VideoButton(
                          isRecording: state.isRecording,
                          onStart: () => ref
                              .read(cameraProvider.notifier)
                              .startVideo(settings),
                          onStop: () async {
                            await ref.read(cameraProvider.notifier).stopVideo();
                            // Refresh gallery thumbnail after video
                            ref.read(latestAssetProvider.notifier).refresh();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
  const _VideoButton(
      {required this.isRecording, required this.onStart, required this.onStop});
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
