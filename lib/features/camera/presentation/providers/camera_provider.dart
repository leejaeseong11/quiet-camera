import 'dart:async';

import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/logger.dart';
import '../../../../platform/silent_shutter_native.dart';
import '../../../camera/domain/entities/camera_settings.dart' as domain;
import '../../../gallery/data/repositories/gallery_repository.dart';

class CameraState {
  final bool isInitialized;
  final bool hasPermission;
  final bool isRecording;
  final CameraDescription? description;
  final CameraController? controller;
  final String? lastCapturePath;
  final String? error;
  final domain.FlashMode flashMode;
  final double currentZoom;
  final double minZoom;
  final double maxZoom;

  const CameraState({
    required this.isInitialized,
    required this.hasPermission,
    required this.isRecording,
    this.description,
    this.controller,
    this.lastCapturePath,
    this.error,
    this.flashMode = domain.FlashMode.auto,
    this.currentZoom = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
  });

  CameraState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    bool? isRecording,
    CameraDescription? description,
    CameraController? controller,
    String? lastCapturePath,
    String? error,
    domain.FlashMode? flashMode,
    double? currentZoom,
    double? minZoom,
    double? maxZoom,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      isRecording: isRecording ?? this.isRecording,
      description: description ?? this.description,
      controller: controller ?? this.controller,
      lastCapturePath: lastCapturePath ?? this.lastCapturePath,
      error: error,
      flashMode: flashMode ?? this.flashMode,
      currentZoom: currentZoom ?? this.currentZoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
    );
  }

  static CameraState initial() => const CameraState(
        isInitialized: false,
        hasPermission: false,
        isRecording: false,
        flashMode: domain.FlashMode.auto,
      );
}

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(CameraState.initial());

  final _silent = SilentShutterNative();
  final _gallery = GalleryRepository();

  Future<void> requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos
    ].request();
    final has = statuses[Permission.camera]?.isGranted == true;
    state = state.copyWith(hasPermission: has);
  }

  Future<void> initialize() async {
    try {
      await requestPermissions();
      if (!state.hasPermission) return;

      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.max,
        enableAudio: true,
      );
      await controller.initialize();

      // Get zoom capabilities
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();

      state = state.copyWith(
        description: back,
        controller: controller,
        isInitialized: true,
        minZoom: minZoom,
        maxZoom: maxZoom,
        currentZoom: 1.0,
      );
    } catch (e, st) {
      Logger.error('Camera init failed',
          tag: 'Camera', error: e, stackTrace: st);
      state = state.copyWith(error: 'Camera init failed: $e');
    }
  }

  Future<void> disposeController() async {
    await state.controller?.dispose();
    state = CameraState.initial();
  }

  Future<void> switchCamera() async {
    try {
      if (!state.isInitialized) return;

      // Dispose current controller
      await state.controller?.dispose();

      // Get available cameras
      final cameras = await availableCameras();

      // Toggle lens direction
      final currentLens =
          state.description?.lensDirection ?? CameraLensDirection.back;
      final targetLens = currentLens == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      // Find camera with target lens
      final targetCamera = cameras.firstWhere(
        (c) => c.lensDirection == targetLens,
        orElse: () => cameras.first,
      );

      // Create new controller
      final controller = CameraController(
        targetCamera,
        ResolutionPreset.max,
        enableAudio: true,
      );
      await controller.initialize();

      // Get zoom capabilities
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();

      state = state.copyWith(
        description: targetCamera,
        controller: controller,
        isInitialized: true,
        minZoom: minZoom,
        maxZoom: maxZoom,
        currentZoom: 1.0,
      );
    } catch (e, st) {
      Logger.error('Camera switch failed',
          tag: 'Camera', error: e, stackTrace: st);
      state = state.copyWith(error: 'Camera switch failed: $e');
    }
  }

  Future<String?> capturePhoto(domain.CameraSettings settings) async {
    try {
      if (!state.isInitialized || state.controller == null) return null;

      Logger.debug('Starting photo capture', tag: 'Camera');

      // Mute system sounds before capture (Android only)
      await _silent.muteSystemSounds();

      // Use Flutter camera plugin to take picture
      final image = await state.controller!.takePicture();

      // Restore system sounds after capture
      await _silent.restoreSystemSounds();

      Logger.info('Photo captured: ${image.path}', tag: 'Camera');

      // Save to gallery
      await _gallery.saveImage(image.path);

      state = state.copyWith(lastCapturePath: image.path);
      return image.path;
    } catch (e, st) {
      Logger.error('Photo capture failed',
          tag: 'Camera', error: e, stackTrace: st);

      // Ensure sounds are restored even on error
      await _silent.restoreSystemSounds();

      state = state.copyWith(error: 'Failed to capture photo: $e');
      return null;
    }
  }

  Future<String?> startVideo(domain.CameraSettings settings) async {
    try {
      if (!state.isInitialized || state.isRecording) return null;
      final path = await _silent.startSilentVideo(
        resolution: _mapResolution(settings.videoResolution),
        fps: settings.videoResolution.fps,
        recordAudio: settings.recordAudio,
      );
      state = state.copyWith(isRecording: true, lastCapturePath: path);
      return path;
    } catch (e) {
      state = state.copyWith(error: 'Failed to start video: $e');
      return null;
    }
  }

  Future<String?> stopVideo() async {
    try {
      if (!state.isRecording) return null;
      final path = await _silent.stopSilentVideo();

      // Save to gallery
      if (path.isNotEmpty) {
        await _gallery.saveVideo(path);
      }

      state = state.copyWith(isRecording: false, lastCapturePath: path);
      return path;
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop video: $e');
      return null;
    }
  }

  void toggleFlashMode() {
    const modes = domain.FlashMode.values;
    final currentIndex = modes.indexOf(state.flashMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    state = state.copyWith(flashMode: modes[nextIndex]);
  }

  void setFlashMode(domain.FlashMode mode) {
    state = state.copyWith(flashMode: mode);
  }

  /// Set zoom level with smooth animation
  Future<void> setZoom(double zoom) async {
    try {
      if (!state.isInitialized || state.controller == null) return;

      // Clamp zoom to valid range
      final clampedZoom = zoom.clamp(state.minZoom, state.maxZoom);

      // Apply zoom to camera controller
      await state.controller!.setZoomLevel(clampedZoom);

      state = state.copyWith(currentZoom: clampedZoom);
    } catch (e, st) {
      Logger.error('Failed to set zoom',
          tag: 'Camera', error: e, stackTrace: st);
    }
  }

  /// Handle pinch gesture zoom
  void onScaleUpdate(double scale) {
    if (!state.isInitialized) return;

    // Calculate new zoom based on scale
    final newZoom =
        (state.currentZoom * scale).clamp(state.minZoom, state.maxZoom);
    setZoom(newZoom);
  }

  // Mapping helpers
  String _mapResolution(domain.VideoResolution r) => '${r.resolution}@${r.fps}';
}

final cameraProvider =
    StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  final notifier = CameraNotifier();
  // Lazy init; UI will call initialize()
  return notifier;
});
