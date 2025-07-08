import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/history_log_model.dart';
import '../../services/auth_service.dart';
import 'profile/profile_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // timeago 한국어 설정
    timeago.setLocaleMessages('ko', timeago.KoMessages());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('활동 로그'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '일반'),
              Tab(text: '매칭'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LogList(
              logTypes: [LogType.NOTICE, LogType.EVENT],
              emptyMessage: '표시할 일반 알림이 없습니다.',
            ),
            _LogList(
              logTypes: [
                LogType.PROFILE_VIEW_SENT, LogType.PROFILE_VIEW_RECEIVED,
                LogType.LIKE_SENT, LogType.LIKE_RECEIVED,
                LogType.LIKE_ACCEPTED_BY_ME, LogType.LIKE_ACCEPTED_BY_OTHER,
                LogType.LIKE_REJECTED_BY_OTHER,
                LogType.CONTACT_VIEWED_BY_ME, LogType.CONTACT_VIEWED_BY_OTHER,
                LogType.CURRENCY_USED,
              ],
              emptyMessage: '매칭 관련 활동 내역이 없습니다.',
            ),
          ],
        ),
      ),
    );
  }
}

// 로그 리스트를 표시하는 공통 위젯
class _LogList extends StatelessWidget {
  final List<LogType> logTypes;
  final String emptyMessage;

  const _LogList({required this.logTypes, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<List<HistoryLog>>(
      stream: authService.getHistoryLogs(logTypes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        final logs = snapshot.data!;
        return ListView.separated(
          itemCount: logs.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogTile(context, log);
          },
        );
      },
    );
  }

  // 각 로그 항목을 그리는 타일 위젯
  Widget _buildLogTile(BuildContext context, HistoryLog log) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getIconBackgroundColor(log.logType),
        child: Icon(_getIconForLogType(log.logType), color: Colors.white, size: 20),
      ),
      title: Text(log.message, style: const TextStyle(fontSize: 15)),
      subtitle: Text(
        timeago.format(log.createdAt.toDate(), locale: 'ko'),
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      onTap: () {
        if (log.relatedUserId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(userId: log.relatedUserId!)),
          );
        }
      },
    );
  }

  // 로그 타입에 따라 아이콘을 반환하는 함수
  IconData _getIconForLogType(LogType type) {
    switch (type) {
      case LogType.NOTICE:
      case LogType.EVENT:
        return Icons.campaign;
      case LogType.PROFILE_VIEW_SENT:
      case LogType.PROFILE_VIEW_RECEIVED:
        return Icons.visibility;
      case LogType.LIKE_SENT:
      case LogType.LIKE_RECEIVED:
      case LogType.LIKE_ACCEPTED_BY_ME:
      case LogType.LIKE_ACCEPTED_BY_OTHER:
        return Icons.favorite;
      case LogType.LIKE_REJECTED_BY_OTHER:
        return Icons.heart_broken;
      case LogType.CONTACT_VIEWED_BY_ME:
      case LogType.CONTACT_VIEWED_BY_OTHER:
        return Icons.phone;
      case LogType.CURRENCY_USED:
        return Icons.diamond;
      default:
        return Icons.notifications;
    }
  }

  // 로그 타입에 따라 아이콘 배경색을 반환하는 함수
  Color _getIconBackgroundColor(LogType type) {
    switch (type) {
      case LogType.NOTICE:
      case LogType.EVENT:
        return Colors.blue;
      case LogType.LIKE_SENT:
      case LogType.LIKE_RECEIVED:
      case LogType.LIKE_ACCEPTED_BY_ME:
      case LogType.LIKE_ACCEPTED_BY_OTHER:
        return Colors.pinkAccent;
      case LogType.LIKE_REJECTED_BY_OTHER:
        return Colors.grey;
      case LogType.CURRENCY_USED:
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
