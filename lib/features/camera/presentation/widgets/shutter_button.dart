import 'package:flutter/material.dart';

class ShutterButton extends StatelessWidget {
  const ShutterButton(
      {super.key, required this.onTap, this.isRecording = false});
  final VoidCallback onTap;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isRecording ? Colors.red : Colors.white,
            width: 4,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? 28 : 56,
            height: isRecording ? 28 : 56,
            decoration: BoxDecoration(
              shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isRecording ? BorderRadius.circular(4) : null,
              color: isRecording ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
