import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

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
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex ?? 0,
    );
    _currentIndex = widget.initialIndex ?? 0;
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
          // Single item delete
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _assets.isEmpty ? null : _deleteCurrent,
          ),
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
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return _AssetViewer(asset: _assets[index]);
                  },
                ),
    );
  }

  Future<void> _deleteCurrent() async {
    if (_assets.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        content: const Text('이 항목을 삭제합니다. 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final index = _currentIndex.clamp(0, _assets.length - 1);
      final id = _assets[index].id;
      await PhotoManager.editor.deleteWithIds([id]);

      setState(() {
        _assets.removeAt(index);
        if (_assets.isEmpty) {
          Navigator.of(context).pop();
          return;
        }
        // Stay on same index (which now points to next item), or move back if at end
        final newIndex = index >= _assets.length ? _assets.length - 1 : index;
        _currentIndex = newIndex;
        _pageController.jumpToPage(newIndex);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
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
class _AssetViewer extends StatefulWidget {
  final AssetEntity asset;

  const _AssetViewer({required this.asset});

  @override
  State<_AssetViewer> createState() => _AssetViewerState();
}

class _AssetViewerState extends State<_AssetViewer> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  Widget build(BuildContext context) {
    return widget.asset.type == AssetType.video
        ? _buildVideoPlayer()
        : _buildImageViewer();
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder<void>(
      future: _initializeVideo(),
      builder: (context, snapshot) {
        if (!_isVideoInitialized || _videoController == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            // Play/pause button
            Positioned(
              bottom: 60,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeVideo() async {
    if (_isVideoInitialized) return;

    final file = await widget.asset.file;
    if (file == null) return;

    _videoController = VideoPlayerController.file(file);
    await _videoController!.initialize();
    _videoController!.setLooping(true);

    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  Widget _buildImageViewer() {
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
    // For photos, show with pinch zoom
    final file = await widget.asset.file;
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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}

/// Grid view of all assets
class _GalleryGridView extends StatefulWidget {
  final List<AssetEntity> assets;

  const _GalleryGridView({required this.assets});

  @override
  State<_GalleryGridView> createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<_GalleryGridView> {
  bool _isEditing = false;
  final Set<int> _selected = {};

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
          _isEditing
              ? (_selected.isEmpty ? '항목 선택' : '${_selected.length}개 선택')
              : '${widget.assets.length} 항목',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _selected.isEmpty ? null : _deleteSelected,
            )
          else
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('편집', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.assets.length,
        itemBuilder: (context, index) {
          final isSelected = _selected.contains(index);
          return GestureDetector(
            onTap: _isEditing
                ? () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(index);
                      } else {
                        _selected.add(index);
                      }
                    });
                  }
                : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            GalleryViewPage(initialIndex: index),
                      ),
                    );
                  },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _GridThumbnail(asset: widget.assets[index], onTap: () {}),
                if (_isEditing)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.circle,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선택 항목 삭제'),
        content: Text('${_selected.length}개 항목을 삭제합니다. 계속할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ids = _selected.map((i) => widget.assets[i].id).toList();
      await PhotoManager.editor.deleteWithIds(ids);

      setState(() {
        final sorted = _selected.toList()..sort((a, b) => b.compareTo(a));
        for (final i in sorted) {
          widget.assets.removeAt(i);
        }
        _selected.clear();
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
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
