// lib/models/history_log_model.dart (New File)

import 'package:cloud_firestore/cloud_firestore.dart';

enum LogType {
  // 일반
  NOTICE,
  EVENT,
  // 매칭
  PROFILE_VIEW_SENT,
  PROFILE_VIEW_RECEIVED,
  LIKE_SENT,
  LIKE_RECEIVED,
  LIKE_ACCEPTED_BY_ME,
  LIKE_ACCEPTED_BY_OTHER,
  LIKE_REJECTED_BY_OTHER,
  CONTACT_VIEWED_BY_ME,
  CONTACT_VIEWED_BY_OTHER,
  CURRENCY_USED,
  // 알 수 없는 타입
  UNKNOWN
}

class HistoryLog {
  final String logId;
  final LogType logType;
  final String message;
  final String? relatedUserId;
  final String? relatedUserName;
  final bool isRead;
  final Timestamp createdAt;
  final Map<String, dynamic>? metadata;

  HistoryLog({
    required this.logId,
    required this.logType,
    required this.message,
    this.relatedUserId,
    this.relatedUserName,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory HistoryLog.fromMap(String id, Map<String, dynamic> data) {
    return HistoryLog(
      logId: id,
      logType: _stringToLogType(data['logType']),
      message: data['message'] ?? '알 수 없는 활동입니다.',
      relatedUserId: data['relatedUserId'],
      relatedUserName: data['relatedUserName'],
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
    );
  }

  static LogType _stringToLogType(String? typeStr) {
    return LogType.values.firstWhere(
          (e) => e.toString() == 'LogType.$typeStr',
      orElse: () => LogType.UNKNOWN,
    );
  }
}
