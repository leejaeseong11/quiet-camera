import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Provider for the most recent gallery asset
final latestAssetProvider =
    StateNotifierProvider<LatestAssetNotifier, AssetEntity?>((ref) {
  return LatestAssetNotifier();
});

class LatestAssetNotifier extends StateNotifier<AssetEntity?> {
  LatestAssetNotifier() : super(null);

  /// Load the most recent asset from gallery
  Future<void> loadLatestAsset() async {
    try {
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth && !permitted.hasAccess) {
        state = null;
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );

      if (albums.isEmpty) {
        state = null;
        return;
      }

      // Get the most recent asset
      final recentAlbum = albums.first;
      final assets = await recentAlbum.getAssetListRange(
        start: 0,
        end: 1,
      );

      if (assets.isNotEmpty) {
        state = assets.first;
      } else {
        state = null;
      }
    } catch (e) {
      state = null;
    }
  }

  /// Refresh after taking a photo/video
  Future<void> refresh() async {
    await loadLatestAsset();
  }
}
