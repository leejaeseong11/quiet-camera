import 'dart:async';
import 'package:flutter/material.dart';

/// Recording timer widget that shows elapsed time during video recording
class RecordingTimer extends StatefulWidget {
  final bool isRecording;

  const RecordingTimer({
    super.key,
    required this.isRecording,
  });

  @override
  State<RecordingTimer> createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<RecordingTimer> {
  Timer? _timer;
  int _seconds = 0;
  bool _showDot = true;

  @override
  void initState() {
    super.initState();
    if (widget.isRecording) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(RecordingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startTimer();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 0;
    _showDot = true;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (timer.tick % 2 == 0) {
            _seconds++;
          }
          _showDot = !_showDot;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _seconds = 0;
      _showDot = true;
    });
  }

  String _formatTime() {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blinking red dot
          AnimatedOpacity(
            opacity: _showDot ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 500),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Timer text
          Text(
            _formatTime(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }
}
