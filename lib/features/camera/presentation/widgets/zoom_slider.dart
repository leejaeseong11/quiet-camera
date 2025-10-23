import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact zoom slider that auto-hides when not in use
/// Shows only when actively zooming (pinch or slider interaction)
class ZoomSlider extends ConsumerStatefulWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;
  final bool isVisible;

  const ZoomSlider({
    super.key,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
    this.isVisible = false,
  });

  @override
  ConsumerState<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends ConsumerState<ZoomSlider>
    with SingleTickerProviderStateMixin {
  double _sliderValue = 1.0;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentZoom;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isVisible ? 1.0 : 0.0, // Initialize based on visibility
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ZoomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.currentZoom != oldWidget.currentZoom) {
      setState(() {
        _sliderValue = widget.currentZoom;
      });
    }

    // Handle visibility animation
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getZoomLabel(double zoom) {
    if (zoom < 1.0) {
      return '${zoom.toStringAsFixed(1)}x';
    } else if (zoom >= 10.0) {
      return '${zoom.toStringAsFixed(0)}x';
    } else {
      return '${zoom.toStringAsFixed(1)}x';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate effective max zoom (up to 8x for good quality)
    final effectiveMaxZoom = widget.maxZoom.clamp(widget.minZoom, 8.0);

    // Don't render if not visible (optimization)
    if (!widget.isVisible && _animationController.value == 0.0) {
      return const SizedBox.shrink();
    }

    // If camera doesn't support zoom, show a message
    if (widget.minZoom >= widget.maxZoom ||
        effectiveMaxZoom <= widget.minZoom) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Zoom not available',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'SF Pro',
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Min label
              Text(
                _getZoomLabel(widget.minZoom),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontFamily: 'SF Pro',
                ),
              ),
              const SizedBox(width: 8),

              // Compact horizontal slider
              SizedBox(
                width: 140,
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFFFFD60A),
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    overlayColor: const Color(0xFFFFD60A).withOpacity(0.2),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: widget.minZoom,
                    max: effectiveMaxZoom,
                    divisions: null,
                    onChangeStart: (value) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                      widget.onZoomChanged(value);
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Current zoom value
              SizedBox(
                width: 36,
                child: Text(
                  _getZoomLabel(_sliderValue),
                  style: const TextStyle(
                    color: Color(0xFFFFD60A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
