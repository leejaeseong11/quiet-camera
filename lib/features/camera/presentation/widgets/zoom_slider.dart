import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zoom slider widget with preset buttons (.5x, 1x, 2x)
/// Follows iPhone native camera design
class ZoomSlider extends ConsumerStatefulWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;

  const ZoomSlider({
    super.key,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
  });

  @override
  ConsumerState<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends ConsumerState<ZoomSlider> {
  // Preset zoom levels
  static const List<double> _presetZooms = [0.5, 1.0, 2.0];

  bool _isSliderVisible = false;
  double _sliderValue = 1.0;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentZoom;
  }

  @override
  void didUpdateWidget(ZoomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentZoom != oldWidget.currentZoom) {
      _sliderValue = widget.currentZoom;
    }
  }

  void _selectZoom(double zoom) {
    setState(() {
      _sliderValue = zoom;
    });
    widget.onZoomChanged(zoom);
  }

  void _showSlider() {
    setState(() {
      _isSliderVisible = true;
    });
  }

  void _hideSlider() {
    setState(() {
      _isSliderVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Continuous zoom slider (shown on long press)
        if (_isSliderVisible) _buildContinuousSlider(),

        const SizedBox(height: 8),

        // Preset zoom buttons
        _buildPresetButtons(),
      ],
    );
  }

  Widget _buildPresetButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _presetZooms.map((zoom) {
          final isActive = (_sliderValue - zoom).abs() < 0.1;
          final isAvailable = zoom >= widget.minZoom && zoom <= widget.maxZoom;

          return GestureDetector(
            onTap: isAvailable ? () => _selectZoom(zoom) : null,
            onLongPressStart: isAvailable ? (_) => _showSlider() : null,
            onLongPressEnd: isAvailable ? (_) => _hideSlider() : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFFD60A) // Yellow for active
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                zoom == 0.5 ? '.5' : zoom.toInt().toString(),
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContinuousSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom level display
          Text(
            '${_sliderValue.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Color(0xFFFFD60A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
            ),
          ),
          const SizedBox(height: 8),

          // Slider
          SizedBox(
            width: 200,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFFFFD60A),
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: const Color(0xFFFFD60A),
                overlayColor: const Color(0xFFFFD60A).withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 3,
              ),
              child: Slider(
                value: _sliderValue,
                min: widget.minZoom,
                max: widget.maxZoom.clamp(widget.minZoom, 10.0),
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                  widget.onZoomChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
