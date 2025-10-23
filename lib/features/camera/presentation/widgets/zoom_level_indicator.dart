import 'package:flutter/material.dart';

/// Displays the current zoom level in the center of the screen
/// Automatically hides after 2 seconds
class ZoomLevelIndicator extends StatefulWidget {
  final double zoomLevel;

  const ZoomLevelIndicator({
    super.key,
    required this.zoomLevel,
  });

  @override
  State<ZoomLevelIndicator> createState() => _ZoomLevelIndicatorState();
}

class _ZoomLevelIndicatorState extends State<ZoomLevelIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _scheduleHide();
  }

  @override
  void didUpdateWidget(ZoomLevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoomLevel != oldWidget.zoomLevel) {
      // Reset timer when zoom changes
      _controller.forward();
      _scheduleHide();
    }
  }

  void _scheduleHide() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.zoomLevel.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
            ),
          ),
        ),
      ),
    );
  }
}
