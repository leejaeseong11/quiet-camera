import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Thumbnail preview widget showing the most recent photo
/// Positioned at bottom-left corner of camera view
class GalleryThumbnail extends StatelessWidget {
  final VoidCallback onTap;
  final AssetEntity? latestAsset;

  const GalleryThumbnail({
    super.key,
    required this.onTap,
    this.latestAsset,
  });

  @override
  Widget build(BuildContext context) {
    if (latestAsset == null) {
      // Show placeholder if no photos
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.photo_library_outlined,
            color: Colors.white.withOpacity(0.7),
            size: 30,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: FutureBuilder<Widget>(
            future: _buildThumbnail(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Widget> _buildThumbnail() async {
    final thumb = await latestAsset!.thumbnailDataWithSize(
      const ThumbnailSize(200, 200),
    );

    if (thumb == null) {
      return Container(color: Colors.grey[800]);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          thumb,
          fit: BoxFit.cover,
        ),
        // Video indicator
        if (latestAsset!.type == AssetType.video)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}
