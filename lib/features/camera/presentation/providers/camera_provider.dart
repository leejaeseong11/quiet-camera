import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/logger.dart';
import '../../../../platform/silent_shutter_native.dart';
import '../../../camera/domain/entities/camera_settings.dart' as domain;
import '../../../gallery/data/repositories/gallery_repository.dart';

// Sentinel class for nullable parameter handling in copyWith
class _Sentinel {
  const _Sentinel();
}

class CameraState {
  final bool isInitialized;
  final bool hasPermission;
  final bool isRecording;
  final domain.CaptureMode captureMode;
  final CameraDescription? description;
  final CameraController? controller;
  final String? lastCapturePath;
  final String? error;
  final domain.FlashMode flashMode;
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final int? timerSeconds; // null = off, 3/5/10 = timer duration
  final int? countdownSeconds; // current countdown value
  final bool isZoomUIVisible; // controls visibility of zoom scrubber

  const CameraState({
    required this.isInitialized,
    required this.hasPermission,
    required this.isRecording,
    this.captureMode = domain.CaptureMode.photo,
    this.description,
    this.controller,
    this.lastCapturePath,
    this.error,
    this.flashMode = domain.FlashMode.off,
    this.currentZoom = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
    this.timerSeconds,
    this.countdownSeconds,
    this.isZoomUIVisible = false,
  });

  CameraState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    bool? isRecording,
    domain.CaptureMode? captureMode,
    CameraDescription? description,
    CameraController? controller,
    String? lastCapturePath,
    String? error,
    domain.FlashMode? flashMode,
    double? currentZoom,
    double? minZoom,
    double? maxZoom,
    Object? timerSeconds = const _Sentinel(),
    Object? countdownSeconds = const _Sentinel(),
    bool? isZoomUIVisible,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      isRecording: isRecording ?? this.isRecording,
      captureMode: captureMode ?? this.captureMode,
      description: description ?? this.description,
      controller: controller ?? this.controller,
      lastCapturePath: lastCapturePath ?? this.lastCapturePath,
      error: error,
      flashMode: flashMode ?? this.flashMode,
      currentZoom: currentZoom ?? this.currentZoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      timerSeconds: timerSeconds == const _Sentinel()
          ? this.timerSeconds
          : timerSeconds as int?,
      countdownSeconds: countdownSeconds == const _Sentinel()
          ? this.countdownSeconds
          : countdownSeconds as int?,
      isZoomUIVisible: isZoomUIVisible ?? this.isZoomUIVisible,
    );
  }

  static CameraState initial() => const CameraState(
        isInitialized: false,
        hasPermission: false,
        isRecording: false,
        captureMode: domain.CaptureMode.photo,
        flashMode: domain.FlashMode.off,
        isZoomUIVisible: false,
      );
}

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(CameraState.initial());

  final _silent = SilentShutterNative();
  final _gallery = GalleryRepository();

  Future<void> requestPermissions() async {
    // Request sequentially to ensure iOS shows all prompts reliably
    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    // On iOS 14+, photosAddOnly may be needed for saving only
    PermissionStatus photosStatus = await Permission.photos.request();
    if (!photosStatus.isGranted && Platform.isIOS) {
      photosStatus = await Permission.photosAddOnly.request();
    }

    final has = cam.isGranted;
    state = state.copyWith(hasPermission: has);
    Logger.debug(
      'Permissions -> camera: ${cam.isGranted}, mic: ${mic.isGranted}, photos: ${photosStatus.isGranted}',
      tag: 'Permissions',
    );
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
        imageFormatGroup:
            ImageFormatGroup.jpeg, // Ensure JPEG format for compatibility
      );
      await controller.initialize();

      // Configure camera for optimal image quality
      try {
        // Set exposure mode to auto for better brightness
        await controller.setExposureMode(ExposureMode.auto);
        // Set focus mode to auto
        await controller.setFocusMode(FocusMode.auto);
      } catch (e) {
        Logger.warning('Failed to set camera modes: $e', tag: 'Camera');
      }

      // Get zoom capabilities and enforce our limits (0.5x to 15x)
      final deviceMinZoom = await controller.getMinZoomLevel();
      final deviceMaxZoom = await controller.getMaxZoomLevel();

      // Clamp to our desired range: 0.5x minimum, 15x maximum
      final minZoom = (deviceMinZoom > 0.5) ? deviceMinZoom : 0.5;
      final maxZoom = (deviceMaxZoom < 15.0) ? deviceMaxZoom : 15.0;

      Logger.info(
          'Camera zoom: device=($deviceMinZoom-$deviceMaxZoom), clamped=($minZoom-$maxZoom)',
          tag: 'Camera');

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
        imageFormatGroup:
            ImageFormatGroup.jpeg, // Ensure JPEG format for compatibility
      );
      await controller.initialize();

      // Configure camera for optimal image quality
      try {
        // Set exposure mode to auto for better brightness
        await controller.setExposureMode(ExposureMode.auto);
        // Set focus mode to auto
        await controller.setFocusMode(FocusMode.auto);
      } catch (e) {
        Logger.warning('Failed to set camera modes: $e', tag: 'Camera');
      }

      // Get zoom capabilities and enforce our limits (0.5x to 15x)
      final deviceMinZoom = await controller.getMinZoomLevel();
      final deviceMaxZoom = await controller.getMaxZoomLevel();

      // Clamp to our desired range: 0.5x minimum, 15x maximum
      final minZoom = (deviceMinZoom > 0.5) ? deviceMinZoom : 0.5;
      final maxZoom = (deviceMaxZoom < 15.0) ? deviceMaxZoom : 15.0;

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

      // Apply flash mode to camera controller before capture
      final controller = state.controller!;
      try {
        switch (state.flashMode) {
          case domain.FlashMode.off:
            await controller.setFlashMode(FlashMode.off);
            break;
          case domain.FlashMode.on:
            await controller.setFlashMode(FlashMode.always);
            break;
          case domain.FlashMode.auto:
            await controller.setFlashMode(FlashMode.auto);
            break;
        }
      } catch (e) {
        Logger.warning('Failed to set flash mode: $e', tag: 'Camera');
      }

      // Mute system sounds before capture (Android only)
      await _silent.muteSystemSounds();

      // Optionally lock capture orientation to preserve orientation in EXIF
      try {
        await controller.lockCaptureOrientation();
      } catch (_) {}

      // Use Flutter camera plugin to take picture with high quality settings
      final image = await controller.takePicture();

      // Unlock orientation after capture
      try {
        await controller.unlockCaptureOrientation();
      } catch (_) {}

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

  void setCaptureMode(domain.CaptureMode mode) {
    if (state.isRecording) return; // don't allow switching during recording
    state = state.copyWith(captureMode: mode);
  }

  void toggleCaptureMode() {
    if (state.isRecording) return;
    final next = state.captureMode == domain.CaptureMode.photo
        ? domain.CaptureMode.video
        : domain.CaptureMode.photo;
    state = state.copyWith(captureMode: next);
  }

  Future<String?> startVideo(domain.CameraSettings settings) async {
    try {
      if (!state.isInitialized ||
          state.isRecording ||
          state.controller == null) {
        Logger.warning(
            'Cannot start video: initialized=${state.isInitialized}, recording=${state.isRecording}',
            tag: 'Camera');
        return null;
      }

      Logger.debug('Starting video recording', tag: 'Camera');

      // Apply settings to camera controller before recording
      final controller = state.controller!;
      try {
        switch (state.flashMode) {
          case domain.FlashMode.off:
            await controller.setFlashMode(FlashMode.off);
            break;
          case domain.FlashMode.on:
            await controller.setFlashMode(FlashMode.torch);
            break;
          case domain.FlashMode.auto:
            await controller.setFlashMode(FlashMode.auto);
            break;
        }
      } catch (e) {
        Logger.warning('Failed to set flash mode for video: $e', tag: 'Camera');
      }

      // Mute system sounds (Android only)
      await _silent.muteSystemSounds();

      // Lock orientation during recording to maintain consistent orientation
      try {
        await controller.lockCaptureOrientation();
      } catch (_) {}

      // Start recording with Flutter camera plugin
      await controller.startVideoRecording();

      state = state.copyWith(isRecording: true);
      Logger.info('Video recording started successfully', tag: 'Camera');
      return 'recording'; // Placeholder path until we stop
    } catch (e, st) {
      Logger.error('Failed to start video recording',
          tag: 'Camera', error: e, stackTrace: st);

      // Restore sounds on error
      await _silent.restoreSystemSounds();

      state = state.copyWith(error: 'Failed to start video: $e');
      return null;
    }
  }

  Future<String?> stopVideo() async {
    try {
      if (!state.isRecording || state.controller == null) {
        Logger.warning('Cannot stop video: recording=${state.isRecording}',
            tag: 'Camera');
        return null;
      }

      Logger.debug('Stopping video recording', tag: 'Camera');

      // Stop recording
      final video = await state.controller!.stopVideoRecording();

      // Unlock orientation after recording
      try {
        await state.controller!.unlockCaptureOrientation();
      } catch (_) {}

      // Restore system sounds
      await _silent.restoreSystemSounds();

      Logger.info('Video saved: ${video.path}', tag: 'Camera');

      // Save to gallery in background to avoid blocking UI
      try {
        await _gallery.saveVideo(video.path);
        Logger.info('Video saved to gallery successfully', tag: 'Camera');
      } catch (e) {
        Logger.error('Failed to save video to gallery: $e', tag: 'Camera');
        // Don't fail the whole operation if gallery save fails
      }

      state = state.copyWith(isRecording: false, lastCapturePath: video.path);
      return video.path;
    } catch (e, st) {
      Logger.error('Failed to stop video recording',
          tag: 'Camera', error: e, stackTrace: st);

      // Ensure sounds are restored
      await _silent.restoreSystemSounds();

      state = state.copyWith(
        isRecording: false,
        error: 'Failed to stop video: $e',
      );
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
      if (!state.isInitialized || state.controller == null) {
        Logger.info('Cannot set zoom: camera not initialized', tag: 'Camera');
        return;
      }

      // Clamp zoom to valid range
      final clampedZoom = zoom.clamp(state.minZoom, state.maxZoom);

      Logger.info(
          'Setting zoom: $clampedZoom (requested: $zoom, range: ${state.minZoom}-${state.maxZoom})',
          tag: 'Camera');

      // Apply zoom to camera controller
      await state.controller!.setZoomLevel(clampedZoom);

      state = state.copyWith(currentZoom: clampedZoom);

      Logger.info('Zoom set successfully to $clampedZoom', tag: 'Camera');
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

  /// Control visibility of zoom UI
  void setZoomUIVisible(bool visible) {
    if (state.isZoomUIVisible == visible) return;
    state = state.copyWith(isZoomUIVisible: visible);
  }

  /// Toggle timer between Off -> 3s -> 5s -> 10s -> Off
  void toggleTimer() {
    final int? nextTimer;
    switch (state.timerSeconds) {
      case null:
        nextTimer = 3;
        break;
      case 3:
        nextTimer = 5;
        break;
      case 5:
        nextTimer = 10;
        break;
      case 10:
      default:
        nextTimer = null;
        break;
    }
    state = state.copyWith(timerSeconds: nextTimer);
    Logger.info('Timer set to: ${nextTimer ?? "OFF"}', tag: 'Camera');
  }

  /// Start timer countdown and capture photo
  Future<String?> capturePhotoWithTimer(domain.CameraSettings settings) async {
    if (state.timerSeconds == null) {
      // No timer, capture immediately
      return capturePhoto(settings);
    }

    // Start countdown
    var countdown = state.timerSeconds!;
    while (countdown > 0) {
      state = state.copyWith(countdownSeconds: countdown);
      await Future.delayed(const Duration(seconds: 1));
      countdown--;
    }

    // Clear countdown and capture
    state = state.copyWith(countdownSeconds: null);
    return capturePhoto(settings);
  }
}

final cameraProvider =
    StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  final notifier = CameraNotifier();
  // Lazy init; UI will call initialize()
  return notifier;
});
