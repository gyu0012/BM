import 'dart:async';
import 'package:balancematch/main_screen/pages/profile/profile_page.dart';
import 'package:balancematch/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visibility_detector/visibility_detector.dart';


class ProfileCardWithTimer extends StatefulWidget {
  final Recommendation recommendation;
  const ProfileCardWithTimer({Key? key, required this.recommendation, required bool isBlocked}) : super(key: key);

  @override
  State<ProfileCardWithTimer> createState() => _ProfileCardWithTimerState();
}

class _ProfileCardWithTimerState extends State<ProfileCardWithTimer> {
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    // 다음 주 월요일 오전 11시 계산
    int daysUntilNextMonday = (8 - now.weekday) % 7;
    if (daysUntilNextMonday == 0) daysUntilNextMonday = 7; // 오늘이 월요일이면 다음주 월요일로

    final nextMonday = DateTime(now.year, now.month, now.day + daysUntilNextMonday, 11);
    final expiresAt = DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 10, 59, 59);

    final remaining = expiresAt.difference(now);

    if (mounted) {
      setState(() {
        _remainingTime = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return "기간 만료";
    int days = duration.inDays;
    if (days > 0) return "D-$days";

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.recommendation.user;
    final firstPhoto = user.profileImageUrls?.isNotEmpty == true ? user.profileImageUrls![0] : null;

    return VisibilityDetector(
      key: Key(user.uid),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5) {
          _calculateRemainingTime();
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: user.uid))),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Positioned.fill(
                child: firstPhoto != null
                    ? Image.network(firstPhoto, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 80, color: Colors.grey))
                    : Container(color: Colors.grey.shade300, child: const Icon(Icons.person, size: 80, color: Colors.grey)),
              ),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(_formatDuration(_remainingTime), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nickname ?? '이름 없음', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${user.residenceArea ?? ''}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
