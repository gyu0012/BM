// models/like_model.dart (NEW FILE)
// 경로: lib/models/like_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum LikeStatus { sent, accepted }

class Like {
  final String id;
  final String fromUserId;
  final String toUserId;
  final List<String> reasons;
  final LikeStatus status;
  final Timestamp createdAt;

  Like({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.reasons,
    required this.status,
    required this.createdAt,
  });

  factory Like.fromMap(String id, Map<String, dynamic> data) {
    return Like(
      id: id,
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      reasons: List<String>.from(data['reasons']),
      status: data['status'] == 'accepted' ? LikeStatus.accepted : LikeStatus.sent,
      createdAt: data['createdAt'],
    );
  }
}