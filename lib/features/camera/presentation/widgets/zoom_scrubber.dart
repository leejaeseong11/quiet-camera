import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/camera_provider.dart';

/// A horizontal slider-like zoom control with a draggable thumb.
/// Wide track, plus/minus at ends, and a slide button (thumb) to adjust.
class ZoomScrubber extends ConsumerStatefulWidget {
  const ZoomScrubber({super.key, this.onInteract});

  /// Called when user interacts so parent can keep it visible
  final VoidCallback? onInteract;

  @override
  ConsumerState<ZoomScrubber> createState() => _ZoomScrubberState();
}

class _ZoomScrubberState extends ConsumerState<ZoomScrubber> {
  double _trackWidth = 0;
  static const double _leftInset = 24; // matches track left padding

  // For drag gestures on the track/thumb
  void _onDragStart(DragStartDetails d) {
    widget.onInteract?.call();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final state = ref.read(cameraProvider);
    final localX = (d.localPosition.dx - _leftInset).clamp(0.0, _trackWidth);
    final fraction = _trackWidth == 0 ? 0.0 : (localX / _trackWidth);
    final newZoom = state.minZoom + (state.maxZoom - state.minZoom) * fraction;
    ref.read(cameraProvider.notifier).setZoom(newZoom);
    widget.onInteract?.call();
  }

  void _onTapDown(TapDownDetails d) {
    final state = ref.read(cameraProvider);
    final localX = (d.localPosition.dx - _leftInset).clamp(0.0, _trackWidth);
    final fraction = _trackWidth == 0 ? 0.0 : (localX / _trackWidth);
    final newZoom = state.minZoom + (state.maxZoom - state.minZoom) * fraction;
    ref.read(cameraProvider.notifier).setZoom(newZoom);
    widget.onInteract?.call();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.85; // wider: 85% of screen width

    // Normalize current zoom to 0..1
    final fraction = (state.currentZoom - state.minZoom) /
        (state.maxZoom - state.minZoom == 0
            ? 1
            : state.maxZoom - state.minZoom);

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: barWidth, height: 56),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackHeight = 8.0;
          final thumbSize = 28.0;
          _trackWidth = constraints.maxWidth - 48; // padding for icons
          final thumbX = 24 + (_trackWidth * fraction).clamp(0.0, _trackWidth);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTapDown,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Minus icon
                  const Positioned(
                    left: 6,
                    child: Icon(Icons.remove, size: 20, color: Colors.white70),
                  ),
                  // Plus icon
                  const Positioned(
                    right: 6,
                    child: Icon(Icons.add, size: 20, color: Colors.white70),
                  ),
                  // Track
                  Positioned(
                    left: 24,
                    right: 24,
                    child: Container(
                      height: trackHeight,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Thumb (slide button)
                  Positioned(
                    left: thumbX - (thumbSize / 2),
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${state.currentZoom.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
