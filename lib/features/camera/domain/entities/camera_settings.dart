enum FlashMode {
  auto,
  on,
  off;

  String get displayName {
    switch (this) {
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.on:
        return 'On';
      case FlashMode.off:
        return 'Off';
    }
  }
}

enum CaptureMode {
  photo,
  video;

  String get displayName {
    switch (this) {
      case CaptureMode.photo:
        return 'Photo';
      case CaptureMode.video:
        return 'Video';
    }
  }
}

enum ImageQuality {
  high, // HEIF
  medium, // JPEG high quality
  compatible; // JPEG compatible

  String get displayName {
    switch (this) {
      case ImageQuality.high:
        return 'High Efficiency (HEIF)';
      case ImageQuality.medium:
        return 'High Quality (JPEG)';
      case ImageQuality.compatible:
        return 'Most Compatible (JPEG)';
    }
  }

  int get quality {
    switch (this) {
      case ImageQuality.high:
        return 100;
      case ImageQuality.medium:
        return 95;
      case ImageQuality.compatible:
        return 85;
    }
  }
}

enum VideoResolution {
  video4K60,
  video4K30,
  video1080p60,
  video1080p30;

  String get displayName {
    switch (this) {
      case VideoResolution.video4K60:
        return '4K @ 60fps';
      case VideoResolution.video4K30:
        return '4K @ 30fps';
      case VideoResolution.video1080p60:
        return '1080p @ 60fps';
      case VideoResolution.video1080p30:
        return '1080p @ 30fps';
    }
  }

  String get resolution {
    switch (this) {
      case VideoResolution.video4K60:
      case VideoResolution.video4K30:
        return '3840x2160';
      case VideoResolution.video1080p60:
      case VideoResolution.video1080p30:
        return '1920x1080';
    }
  }

  int get fps {
    switch (this) {
      case VideoResolution.video4K60:
      case VideoResolution.video1080p60:
        return 60;
      case VideoResolution.video4K30:
      case VideoResolution.video1080p30:
        return 30;
    }
  }
}

class CameraSettings {
  final FlashMode flashMode;
  final ImageQuality imageQuality;
  final VideoResolution videoResolution;
  final bool isSilent;
  final bool recordAudio;

  const CameraSettings({
    required this.flashMode,
    required this.imageQuality,
    required this.videoResolution,
    this.isSilent = true,
    this.recordAudio = false,
  });

  factory CameraSettings.defaults() {
    return const CameraSettings(
      flashMode: FlashMode.auto,
      imageQuality: ImageQuality.high,
      videoResolution: VideoResolution.video4K60,
      isSilent: true,
      recordAudio: false,
    );
  }

  CameraSettings copyWith({
    FlashMode? flashMode,
    ImageQuality? imageQuality,
    VideoResolution? videoResolution,
    bool? isSilent,
    bool? recordAudio,
  }) {
    return CameraSettings(
      flashMode: flashMode ?? this.flashMode,
      imageQuality: imageQuality ?? this.imageQuality,
      videoResolution: videoResolution ?? this.videoResolution,
      isSilent: isSilent ?? this.isSilent,
      recordAudio: recordAudio ?? this.recordAudio,
    );
  }
}
