import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/camera_provider.dart';
import '../../../camera/domain/entities/camera_settings.dart' as domain;

/// A compact Photo/Video mode indicator with tap-to-switch.
class ModeSelector extends ConsumerWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: _ModeBar(current: state.captureMode),
    );
  }
}

class _ModeBar extends ConsumerWidget {
  const _ModeBar({required this.current});
  final domain.CaptureMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle style(bool active) => TextStyle(
          color: active ? Colors.yellowAccent : Colors.white70,
          fontSize: 16,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 1.2,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => ref
              .read(cameraProvider.notifier)
              .setCaptureMode(domain.CaptureMode.photo),
          child:
              Text('PHOTO', style: style(current == domain.CaptureMode.photo)),
        ),
        const SizedBox(width: 16),
        Container(width: 1, height: 18, color: Colors.white24),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => ref
              .read(cameraProvider.notifier)
              .setCaptureMode(domain.CaptureMode.video),
          child:
              Text('VIDEO', style: style(current == domain.CaptureMode.video)),
        ),
      ],
    );
  }
}
