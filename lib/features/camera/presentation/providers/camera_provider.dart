import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
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

  const CameraState({
    required this.isInitialized,
    required this.hasPermission,
    required this.isRecording,
    this.description,
    this.controller,
    this.lastCapturePath,
    this.error,
    this.flashMode = domain.FlashMode.auto,
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
    final statuses = await [Permission.camera, Permission.microphone, Permission.photos].request();
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
      state = state.copyWith(
        description: back,
        controller: controller,
        isInitialized: true,
      );
    } catch (e, st) {
      Logger.error('Camera init failed', tag: 'Camera', error: e, stackTrace: st);
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
      final currentLens = state.description?.lensDirection ?? CameraLensDirection.back;
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

      state = state.copyWith(
        description: targetCamera,
        controller: controller,
        isInitialized: true,
      );
    } catch (e, st) {
      Logger.error('Camera switch failed', tag: 'Camera', error: e, stackTrace: st);
      state = state.copyWith(error: 'Camera switch failed: $e');
    }
  }

  Future<String?> capturePhoto(domain.CameraSettings settings) async {
    try {
      if (!state.isInitialized) return null;
      // Use native silent capture; preview stays from camera plugin
      final path = await _silent.capturePhoto(
        quality: _mapQuality(settings.quality),
        flashMode: _mapFlash(settings.flashMode),
        resolution: _mapResolution(settings.resolution),
      );
      
      // Save to gallery
      if (path.isNotEmpty) {
        await _gallery.saveImage(path);
      }
      
      state = state.copyWith(lastCapturePath: path);
      return path;
    } on CameraException catch (e) {
      state = state.copyWith(error: e.message);
      return null;
    }
  }

  Future<String?> startVideo(domain.CameraSettings settings) async {
    try {
      if (!state.isInitialized || state.isRecording) return null;
      final path = await _silent.startSilentVideo(
        resolution: _mapResolution(settings.resolution),
        fps: 30,
        recordAudio: true,
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
    final modes = domain.FlashMode.values;
    final currentIndex = modes.indexOf(state.flashMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    state = state.copyWith(flashMode: modes[nextIndex]);
  }

  void setFlashMode(domain.FlashMode mode) {
    state = state.copyWith(flashMode: mode);
  }

  // Mapping helpers
  int _mapQuality(domain.ImageQuality q) {
    switch (q) {
      case domain.ImageQuality.heif:
        return 100; // native decides format; we request max quality
      case domain.ImageQuality.jpeg:
        return 95;
    }
  }

  String _mapFlash(domain.FlashMode m) {
    switch (m) {
      case domain.FlashMode.auto:
        return 'auto';
      case domain.FlashMode.on:
        return 'on';
      case domain.FlashMode.off:
        return 'off';
    }
  }

  String _mapResolution(domain.VideoResolution r) {
    switch (r) {
      case domain.VideoResolution.k4_60:
        return '3840x2160@60';
      case domain.VideoResolution.k4_30:
        return '3840x2160@30';
      case domain.VideoResolution.p1080_60:
        return '1920x1080@60';
      case domain.VideoResolution.p1080_30:
        return '1920x1080@30';
    }
  }
}

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  final notifier = CameraNotifier();
  // Lazy init; UI will call initialize()
  return notifier;
});
