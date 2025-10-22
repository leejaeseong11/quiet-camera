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

      if (asset == null) {
        Logger.error('Failed to save image to gallery', tag: 'Gallery');
        return false;
      }

      // Add to custom album
      await _addToAlbum(asset);

      Logger.info('Image saved to gallery: ${asset.id}', tag: 'Gallery');
      return true;
    } catch (e, st) {
      Logger.error('Error saving image to gallery', tag: 'Gallery', error: e, stackTrace: st);
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

      if (asset == null) {
        Logger.error('Failed to save video to gallery', tag: 'Gallery');
        return false;
      }

      // Add to custom album
      await _addToAlbum(asset);

      Logger.info('Video saved to gallery: ${asset.id}', tag: 'Gallery');
      return true;
    } catch (e, st) {
      Logger.error('Error saving video to gallery', tag: 'Gallery', error: e, stackTrace: st);
      return false;
    }
  }

  /// Request photo library permission
  Future<bool> _requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth || result.hasAccess;
  }

  /// Add asset to custom album
  Future<void> _addToAlbum(AssetEntity asset) async {
    try {
      // Get or create album
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        filterOption: FilterOptionGroup(
          containsPathModified: true,
        ),
      );

      AssetPathEntity? targetAlbum;
      for (final album in albums) {
        if (await album.name == albumName) {
          targetAlbum = album;
          break;
        }
      }

      // Create album if it doesn't exist (iOS)
      if (targetAlbum == null) {
        if (Platform.isIOS) {
          await PhotoManager.editor.iOS.createAlbum(
            albumName,
            assets: [asset],
          );
        }
      } else {
        // Add to existing album (iOS only, Android doesn't support custom albums)
        if (Platform.isIOS) {
          await PhotoManager.editor.iOS.addToAlbum(
            [asset],
            targetAlbum,
          );
        }
      }
    } catch (e, st) {
      Logger.error('Error adding to album', tag: 'Gallery', error: e, stackTrace: st);
      // Non-critical error, continue
    }
  }

  /// Generate unique title for media
  String _generateTitle(String prefix) {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return '${prefix}_$timestamp';
  }
}
