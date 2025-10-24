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
import '../widgets/recording_timer.dart';
import '../widgets/timer_button.dart';
import '../widgets/timer_countdown.dart';
import '../widgets/mode_selector.dart';
import '../widgets/zoom_scrubber.dart';
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
  Timer? _zoomHideTimer;
  double _hDragAccum = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request permissions first, then initialize
      await ref.read(cameraProvider.notifier).requestPermissions();
      if (mounted) {
        await ref.read(cameraProvider.notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    _zoomHideTimer?.cancel();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = ref.read(cameraProvider).currentZoom;
    Logger.info('Pinch zoom started: baseZoom=$_baseZoom', tag: 'CameraPage');
    _showZoomTemporarily();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!ref.read(cameraProvider).isInitialized) return;

    final state = ref.read(cameraProvider);
    final newZoom =
        (_baseZoom * details.scale).clamp(state.minZoom, state.maxZoom);

    Logger.info('Pinch zoom update: scale=${details.scale}, newZoom=$newZoom',
        tag: 'CameraPage');
    ref.read(cameraProvider.notifier).setZoom(newZoom);
    _showZoomTemporarily();
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    Logger.info('Pinch zoom ended', tag: 'CameraPage');
  }

  void _handleTapDown(TapDownDetails details) {
    _showZoomTemporarily();
  }

  void _onHorizontalDragStart(DragStartDetails d) {
    _hDragAccum = 0.0;
    _showZoomTemporarily();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    _hDragAccum += d.primaryDelta ?? 0.0;
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    // Screen-level swipe to change capture mode
    final vx = d.velocity.pixelsPerSecond.dx;
    const distanceThreshold = 40.0;
    if (vx > 150 || _hDragAccum > distanceThreshold) {
      ref
          .read(cameraProvider.notifier)
          .setCaptureMode(domain.CaptureMode.video);
    } else if (vx < -150 || _hDragAccum < -distanceThreshold) {
      ref
          .read(cameraProvider.notifier)
          .setCaptureMode(domain.CaptureMode.photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraProvider);

    if (!state.hasPermission) {
      return _PermissionView(
        onRequest: () async {
          await ref.read(cameraProvider.notifier).requestPermissions();
          if (mounted) {
            final hasPermission = ref.read(cameraProvider).hasPermission;
            if (hasPermission) {
              await ref.read(cameraProvider.notifier).initialize();
            } else {
              // If still no permission, open settings
              await openAppSettings();
            }
          }
        },
      );
    }

    if (!state.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final settings = domain.CameraSettings.defaults().copyWith(
      flashMode: state.flashMode,
    );

    // Screen and safe area (controls will be placed on black bars)
    final safeArea = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        onTapDown: _handleTapDown,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreviewWidget(controller: state.controller!),

            // Timer countdown overlay (center of screen)
            if (state.countdownSeconds != null)
              TimerCountdown(seconds: state.countdownSeconds!),

            // Mode selector - place on top black bar (outside preview)
            Positioned(
              top: safeArea.top + 12,
              left: 0,
              right: 0,
              child: Center(
                child: ModeSelector(),
              ),
            ),

            // Recording timer - below mode selector on top black bar
            Positioned(
              top: safeArea.top + 56,
              left: 0,
              right: 0,
              child: Center(
                child: RecordingTimer(isRecording: state.isRecording),
              ),
            ),

            // Flash toggle button - top left on black bar
            Positioned(
              top: safeArea.top + 12,
              left: 16,
              child: FlashButton(
                flashMode: state.flashMode,
                onToggle: () =>
                    ref.read(cameraProvider.notifier).toggleFlashMode(),
              ),
            ),

            // Camera switch button - top right on black bar
            Positioned(
              top: safeArea.top + 12,
              right: 16,
              child: CameraSwitchButton(
                onSwitch: () =>
                    ref.read(cameraProvider.notifier).switchCamera(),
              ),
            ),
            // Zoom scrubber - appears on interaction only, within preview bounds
            if (state.isZoomUIVisible)
              Positioned(
                // Place just above the shutter row on the bottom black bar
                bottom: safeArea.bottom + 120,
                left: 16,
                right: 16,
                child: Center(
                  child: ZoomScrubber(
                    onInteract: _showZoomTemporarily,
                  ),
                ),
              ),
            // Shutter and video controls - bottom center on bottom black bar
            Positioned(
              bottom: safeArea.bottom + 24,
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
                        padding: const EdgeInsets.only(left: 16),
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

                  // Shutter button - center, behavior depends on mode
                  _ModeAwareShutter(settings: settings),

                  // Right side: timer button only
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TimerButton(
                          timerSeconds: state.timerSeconds,
                          onToggle: () =>
                              ref.read(cameraProvider.notifier).toggleTimer(),
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

extension _ZoomVisibility on _CameraPageState {
  void _showZoomTemporarily() {
    ref.read(cameraProvider.notifier).setZoomUIVisible(true);
    _zoomHideTimer?.cancel();
    _zoomHideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(cameraProvider.notifier).setZoomUIVisible(false);
      }
    });
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
              '카메라, 마이크, 사진 권한을\n허용해주세요.',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRequest,
              child: const Text('권한 요청'),
            )
          ],
        ),
      ),
    );
  }
}

class _ModeAwareShutter extends ConsumerWidget {
  const _ModeAwareShutter({required this.settings});
  final domain.CameraSettings settings;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    return ShutterButton(
      isRecording:
          state.captureMode == domain.CaptureMode.video && state.isRecording,
      onTap: () async {
        if (state.captureMode == domain.CaptureMode.photo) {
          final path = await notifier.capturePhotoWithTimer(settings);
          if (context.mounted && path != null) {
            ref.read(latestAssetProvider.notifier).refresh();
            // Snackbar removed - silent save without popup
          }
        } else {
          // Video mode: toggle start/stop
          if (!state.isRecording) {
            await notifier.startVideo(settings);
          } else {
            final path = await notifier.stopVideo();
            if (context.mounted && path != null) {
              ref.read(latestAssetProvider.notifier).refresh();
              // Snackbar removed - silent save without popup
            }
          }
        }
      },
    );
  }
}
