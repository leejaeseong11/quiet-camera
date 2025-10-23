import 'package:flutter/material.dart';

/// Countdown display for self-timer
/// Shows large countdown number in center of screen
class TimerCountdown extends StatelessWidget {
  final int seconds;

  const TimerCountdown({
    super.key,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.7),
          border: Border.all(
            color: const Color(0xFFFFD60A),
            width: 4,
          ),
        ),
        child: Center(
          child: Text(
            seconds.toString(),
            style: const TextStyle(
              color: Color(0xFFFFD60A),
              fontSize: 64,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
            ),
          ),
        ),
      ),
    );
  }
}
