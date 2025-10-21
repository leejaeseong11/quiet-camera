class CameraException implements Exception {
  final String message;
  final String? code;
  
  CameraException(this.message, {this.code});
  
  @override
  String toString() => 'CameraException: $message ${code != null ? '($code)' : ''}';
}

class PermissionException implements Exception {
  final String message;
  
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}

class PlatformException implements Exception {
  final String message;
  final String? code;
  
  PlatformException(this.message, {this.code});
  
  @override
  String toString() => 'PlatformException: $message ${code != null ? '($code)' : ''}';
}
