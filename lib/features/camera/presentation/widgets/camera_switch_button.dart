import 'package:flutter/material.dart';

class CameraSwitchButton extends StatelessWidget {
  const CameraSwitchButton({
    super.key,
    required this.onSwitch,
  });

  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSwitch,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.cameraswitch,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
