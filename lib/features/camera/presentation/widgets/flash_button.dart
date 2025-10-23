import 'package:flutter/material.dart';
import '../../../camera/domain/entities/camera_settings.dart' as domain;

class FlashButton extends StatelessWidget {
  const FlashButton({
    super.key,
    required this.flashMode,
    required this.onToggle,
  });

  final domain.FlashMode flashMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFlashIcon(),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 6),
            Text(
              _getFlashLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (flashMode) {
      case domain.FlashMode.auto:
        return Icons.flash_auto;
      case domain.FlashMode.on:
        return Icons.flash_on;
      case domain.FlashMode.off:
        return Icons.flash_off;
    }
  }

  String _getFlashLabel() {
    switch (flashMode) {
      case domain.FlashMode.auto:
        return 'Auto';
      case domain.FlashMode.on:
        return 'On';
      case domain.FlashMode.off:
        return 'Off';
    }
  }
}
