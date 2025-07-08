// =================================================================
// =================================================================

// main_screen/pages/profile/widgets/locked_content_placeholder.dart (NO CHANGE)
// 경로: lib/main_screen/pages/profile/widgets/locked_content_placeholder.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class LockedContentPlaceholder extends StatelessWidget {
  final String title;
  final VoidCallback onUnlock;

  const LockedContentPlaceholder({
    Key? key,
    required this.title,
    required this.onUnlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.grey.shade200.withOpacity(0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 24),
              Text(
                '$title 정보 열람하기',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '상대방의 어빌리티와 가치관을 확인하고\n더 깊이 있는 만남을 가져보세요.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.key),
                label: const Text('재화로 열람하기'),
                onPressed: onUnlock,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
