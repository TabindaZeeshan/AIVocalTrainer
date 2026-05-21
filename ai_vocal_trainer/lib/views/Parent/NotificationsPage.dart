import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'student_progress_view.dart';

class NotificationsPage extends StatelessWidget {
  final String? studentId;   // Made optional for backward compatibility

  const NotificationsPage({
    super.key,
    this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: softPink,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getNotificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No notifications yet", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;

              return GestureDetector(
                onTap: () {
                  // Mark as read
                  notifications[index].reference.update({'isRead': true});

                  if (data['studentId'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentProgressView(
                          studentName: data['studentName'] ?? "Student",
                          studentId: data['studentId'],
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  color: isRead ? Colors.white : const Color(0xFFFFF0F5),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: softPink.withOpacity(0.1),
                      child: Icon(Icons.check_circle, color: softPink),
                    ),
                    title: Text(data['title'] ?? "Progress Updated"),
                    subtitle: Text(data['body'] ?? ""),
                    trailing: Text(
                      _getTimeAgo(data['createdAt']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Returns correct stream based on whether studentId is provided
  Stream<QuerySnapshot> _getNotificationStream() {
    if (studentId != null && studentId!.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      // Fallback: show all notifications (if needed)
      return FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    final date = (timestamp as Timestamp).toDate();
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) return "${difference.inDays}d ago";
    if (difference.inHours > 0) return "${difference.inHours}h ago";
    if (difference.inMinutes > 0) return "${difference.inMinutes}m ago";
    return "Just now";
  }
}