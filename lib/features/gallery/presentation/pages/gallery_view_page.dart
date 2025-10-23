import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Gallery view page showing all photos and videos
class GalleryViewPage extends StatefulWidget {
  final int? initialIndex;

  const GalleryViewPage({
    super.key,
    this.initialIndex,
  });

  @override
  State<GalleryViewPage> createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  List<AssetEntity> _assets = [];
  bool _isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex ?? 0,
    );
    _loadAssets();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth && !permitted.hasAccess) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );

      if (albums.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get all assets from recent album
      final recentAlbum = albums.first;
      final assets = await recentAlbum.getAssetListRange(
        start: 0,
        end: 1000, // Load up to 1000 recent items
      );

      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            onPressed: _showGridView,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _assets.isEmpty
              ? const Center(
                  child: Text(
                    'No photos or videos',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    return _AssetViewer(asset: _assets[index]);
                  },
                ),
    );
  }

  void _showGridView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _GalleryGridView(assets: _assets),
      ),
    );
  }
}

/// Individual asset viewer with zoom support
class _AssetViewer extends StatelessWidget {
  final AssetEntity asset;

  const _AssetViewer({required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _buildAssetWidget(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }

  Future<Widget> _buildAssetWidget() async {
    if (asset.type == AssetType.video) {
      // For video, show thumbnail with play button
      final thumb = await asset.thumbnailDataWithSize(
        const ThumbnailSize(1080, 1920),
      );

      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (thumb != null)
              Image.memory(
                thumb,
                fit: BoxFit.contain,
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ],
        ),
      );
    } else {
      // For photos, show with pinch zoom
      final file = await asset.file;
      if (file == null) {
        return const Center(
          child: Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }
}

/// Grid view of all assets
class _GalleryGridView extends StatelessWidget {
  final List<AssetEntity> assets;

  const _GalleryGridView({required this.assets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${assets.length} items',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          return _GridThumbnail(
            asset: assets[index],
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GalleryViewPage(initialIndex: index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Grid thumbnail item
class _GridThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onTap;

  const _GridThumbnail({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Widget>(
        future: _buildThumbnail(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Widget> _buildThumbnail() async {
    final thumb = await asset.thumbnailDataWithSize(
      const ThumbnailSize(400, 400),
    );

    if (thumb == null) {
      return Container(color: Colors.grey[900]);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          thumb,
          fit: BoxFit.cover,
        ),
        // Video indicator with duration
        if (asset.type == AssetType.video)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
