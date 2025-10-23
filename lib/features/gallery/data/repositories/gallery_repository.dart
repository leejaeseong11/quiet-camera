import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../../../../core/utils/logger.dart';

class GalleryRepository {
  static const String albumName = 'Quiet Camera';

  /// Save image file to gallery
  Future<bool> saveImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        Logger.error('Image file not found: $filePath', tag: 'Gallery');
        return false;
      }

      // Request permission
      final permitted = await _requestPermission();
      if (!permitted) {
        Logger.error('Gallery permission denied', tag: 'Gallery');
        return false;
      }

      // Save to gallery
      final asset = await PhotoManager.editor.saveImageWithPath(
        filePath,
        title: _generateTitle('IMG'),
      );

      // Optionally add to album (no-op placeholder)
      await _addToAlbum(asset);

      Logger.info('Image saved to gallery: ${asset.id}', tag: 'Gallery');
      return true;
    } catch (e, st) {
      Logger.error('Error saving image to gallery',
          tag: 'Gallery', error: e, stackTrace: st);
      return false;
    }
  }

  /// Save video file to gallery
  Future<bool> saveVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        Logger.error('Video file not found: $filePath', tag: 'Gallery');
        return false;
      }

      // Request permission
      final permitted = await _requestPermission();
      if (!permitted) {
        Logger.error('Gallery permission denied', tag: 'Gallery');
        return false;
      }

      // Save to gallery
      final asset = await PhotoManager.editor.saveVideo(
        file,
        title: _generateTitle('VID'),
      );

      // Optionally add to album (no-op placeholder)
      await _addToAlbum(asset);

      Logger.info('Video saved to gallery: ${asset.id}', tag: 'Gallery');
      return true;
    } catch (e, st) {
      Logger.error('Error saving video to gallery',
          tag: 'Gallery', error: e, stackTrace: st);
      return false;
    }
  }

  /// Request photo library permission
  Future<bool> _requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth || result.hasAccess;
  }

  /// Add asset to custom album (currently no-op to avoid platform-specific API)
  Future<void> _addToAlbum(AssetEntity asset) async {
    // Implement album creation via platform channels if needed.
    return;
  }

  /// Generate unique title for media
  String _generateTitle(String prefix) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return '${prefix}_$timestamp';
  }
}
