class CameraConstants {
  // Resolution Presets
  static const int maxPhotoQuality = 100;
  static const int defaultPhotoQuality = 95;
  
  // Video Settings
  static const int video4K60Bitrate = 100000000; // 100 Mbps
  static const int video4K30Bitrate = 50000000;  // 50 Mbps
  static const int video1080p60Bitrate = 25000000; // 25 Mbps
  static const int video1080p30Bitrate = 15000000; // 15 Mbps
  
  // Zoom Levels
  static const double minZoomLevel = 0.5;
  static const double maxZoomLevel = 10.0;
  static const List<double> presetZoomLevels = [0.5, 1.0, 2.0];
  
  // Camera Modes
  static const String modePhoto = 'photo';
  static const String modeVideo = 'video';
  static const String modePortrait = 'portrait';
  
  // Flash Modes
  static const String flashAuto = 'auto';
  static const String flashOn = 'on';
  static const String flashOff = 'off';
  
  // Performance
  static const int targetFps = 60;
  static const int maxMemoryMB = 200;
  static const Duration shutterDelay = Duration(milliseconds: 200);
}
