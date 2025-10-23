import 'package:flutter/services.dart';
import '../core/error/exceptions.dart' as app_exceptions;
import '../core/utils/logger.dart';

class SilentShutterNative {
  static const MethodChannel _channel = MethodChannel('com.quietcamera/silent');

  /// Capture a photo silently
  Future<String> capturePhoto({
    required int quality,
    required String flashMode,
    String? resolution,
  }) async {
    try {
      Logger.debug('Calling native capturePhoto', tag: 'SilentShutter');

      final result = await _channel.invokeMethod<String>(
        'takeSilentPhoto',
        {
          'quality': quality,
          'flashMode': flashMode,
          'resolution': resolution,
        },
      );

      if (result == null) {
        throw app_exceptions.CameraException('No result from native capture');
      }

      Logger.info('Photo captured: $result', tag: 'SilentShutter');
      return result;
    } on PlatformException catch (e) {
      Logger.error(
        'Platform exception during photo capture',
        tag: 'SilentShutter',
        error: e,
      );
      throw app_exceptions.CameraException(
        'Failed to capture photo: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      Logger.error(
        'Unknown error during photo capture',
        tag: 'SilentShutter',
        error: e,
      );
      throw app_exceptions.CameraException('Failed to capture photo: $e');
    }
  }

  /// Start recording video silently
  Future<String> startSilentVideo({
    required String resolution,
    required int fps,
    required bool recordAudio,
  }) async {
    try {
      Logger.debug('Calling native startSilentVideo', tag: 'SilentShutter');

      final result = await _channel.invokeMethod<String>(
        'startSilentVideo',
        {
          'resolution': resolution,
          'fps': fps,
          'recordAudio': recordAudio,
        },
      );

      if (result == null) {
        throw app_exceptions.CameraException(
            'No result from native video start');
      }

      Logger.info('Video recording started: $result', tag: 'SilentShutter');
      return result;
    } on PlatformException catch (e) {
      Logger.error(
        'Platform exception during video start',
        tag: 'SilentShutter',
        error: e,
      );
      throw app_exceptions.CameraException(
        'Failed to start video: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      Logger.error(
        'Unknown error during video start',
        tag: 'SilentShutter',
        error: e,
      );
      throw app_exceptions.CameraException('Failed to start video: $e');
    }
  }

  /// Stop recording video
  Future<String> stopSilentVideo() async {
    try {
      Logger.debug('Calling native stopSilentVideo', tag: 'SilentShutter');

      final result = await _channel.invokeMethod<String>('stopSilentVideo');

      if (result == null) {
        throw app_exceptions.CameraException(
            'No result from native video stop');
      }

      Logger.info('Video recording stopped: $result', tag: 'SilentShutter');
      return result;
    } on PlatformException catch (e) {
      Logger.error(
        'Platform exception during video stop',
        tag: 'SilentShutter',
        error: e,
      );
      throw app_exceptions.CameraException(
        'Failed to stop video: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      Logger.error(
        'Unknown error during video stop',
        tag: 'SilentShutter',
        error: e,
      );
      throw app_exceptions.CameraException('Failed to stop video: $e');
    }
  }

  /// Test the platform channel connection
  Future<bool> testConnection() async {
    try {
      final result = await _channel.invokeMethod<bool>('testConnection');
      return result ?? false;
    } catch (e) {
      Logger.error('Failed to test connection', tag: 'SilentShutter', error: e);
      return false;
    }
  }

  /// Mute system sounds before capture (Android only)
  Future<void> muteSystemSounds() async {
    try {
      Logger.debug('Muting system sounds', tag: 'SilentShutter');
      await _channel.invokeMethod<void>('muteSystemSounds');
    } on PlatformException catch (e) {
      Logger.warning('Failed to mute sounds: ${e.message}',
          tag: 'SilentShutter');
      // Non-critical, continue anyway
    } catch (e) {
      Logger.warning('Failed to mute sounds: $e', tag: 'SilentShutter');
    }
  }

  /// Restore system sounds after capture (Android only)
  Future<void> restoreSystemSounds() async {
    try {
      Logger.debug('Restoring system sounds', tag: 'SilentShutter');
      await _channel.invokeMethod<void>('restoreSystemSounds');
    } on PlatformException catch (e) {
      Logger.warning('Failed to restore sounds: ${e.message}',
          tag: 'SilentShutter');
      // Non-critical, continue anyway
    } catch (e) {
      Logger.warning('Failed to restore sounds: $e', tag: 'SilentShutter');
    }
  }
}
