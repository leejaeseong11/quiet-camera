abstract class Failure {
  final String message;
  
  const Failure(this.message);
}

class CameraFailure extends Failure {
  const CameraFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
