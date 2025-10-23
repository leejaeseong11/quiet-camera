import 'package:flutter/material.dart';

/// Timer button for self-timer photo capture
/// Allows selection between Off, 3s, 5s, 10s
class TimerButton extends StatelessWidget {
  final int? timerSeconds; // null = off, 3/5/10 = timer duration
  final VoidCallback onToggle;

  const TimerButton({
    super.key,
    required this.timerSeconds,
    required this.onToggle,
  });

  IconData get _icon {
    if (timerSeconds == null) {
      return Icons.timer_off;
    }
    return Icons.timer;
  }

  String get _label {
    if (timerSeconds == null) {
      return 'OFF';
    }
    return '${timerSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: timerSeconds != null
              ? Border.all(color: const Color(0xFFFFD60A), width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              color:
                  timerSeconds != null ? const Color(0xFFFFD60A) : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(
              _label,
              style: TextStyle(
                color: timerSeconds != null
                    ? const Color(0xFFFFD60A)
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
