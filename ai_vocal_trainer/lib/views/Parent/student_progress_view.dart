import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentProgressView extends StatelessWidget {
  final String studentName;
  final String studentId;

  const StudentProgressView({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("$studentName's Progress"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          // Notification Bell
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('studentId', isEqualTo: studentId)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 28),
                    onPressed: () => _showNotificationsBottomSheet(context),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB6D1), Color(0xFFFFD6E6), Color(0xFFFFF0F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('students')
                .doc(studentId)
                .collection('practice_sessions')
                .orderBy('recordedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_outlined, size: 90, color: Colors.grey[400]),
                      const SizedBox(height: 24),
                      Text("No practice sessions yet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                      const Text("Progress will appear after practice", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              final sessions = snapshot.data!.docs;
              int totalCorrect = 0;
              int totalAttempts = 0;

              for (var doc in sessions) {
                final data = doc.data() as Map<String, dynamic>;
                totalCorrect += (data['correctAnswers'] ?? 0) as int;
                totalAttempts += (data['totalAttempts'] ?? 0) as int;
              }

              final overallAccuracy = totalAttempts > 0
                  ? (totalCorrect / totalAttempts * 100).toStringAsFixed(1)
                  : "0.0";

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  Text("$studentName's", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.95))),
                  const Text("Progress", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 40),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15)],
                    ),
                    child: Column(
                      children: [
                        Text("Overall Performance", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                        const SizedBox(height: 12),
                        Text("$overallAccuracy%", style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: softPink)),
                        Text("Average Accuracy", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text("Recent Activities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ...sessions.map((doc) => _buildSessionCard(doc.data() as Map<String, dynamic>)).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ====================== NOTIFICATIONS BOTTOM SHEET ======================
  void _showNotificationsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('studentId', isEqualTo: studentId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No notifications yet", style: TextStyle(fontSize: 18)),
                          Text("New notifications will appear here", 
                               style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final data = notifications[index].data() as Map<String, dynamic>;
                      final isRead = data['isRead'] ?? false;

                      return Card(
                        color: isRead ? Colors.white : const Color(0xFFFFF0F5),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: softPink.withOpacity(0.1),
                            child: const Icon(Icons.check_circle, color: Colors.green),
                          ),
                          title: Text(data['title'] ?? "Progress Updated"),
                          subtitle: Text(data['body'] ?? "Student completed an activity"),
                          trailing: Text(
                            _getTimeAgo(data['createdAt']),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () {
                            notifications[index].reference.update({'isRead': true});
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
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

  // Existing methods
  Widget _buildSessionCard(Map<String, dynamic> session) {
    final timestamp = session['recordedAt'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(date);

    final accuracy = session['totalAttempts'] != null && session['totalAttempts'] > 0
        ? ((session['correctAnswers'] ?? 0) / session['totalAttempts'] * 100).toStringAsFixed(1)
        : "0.0";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatActivity(session['activityType'] ?? ''), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                const SizedBox(height: 6),
                Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: softPink.withOpacity(0.12), borderRadius: BorderRadius.circular(30)),
            child: Text("$accuracy%", style: TextStyle(fontWeight: FontWeight.bold, color: softPink)),
          ),
        ],
      ),
    );
  }

  String _formatActivity(String type) {
    switch (type) {
      case 'vocal_card_echo': return 'Vocal Card Echo';
      case 'number_pair_sequence': return 'Number Pair Sequence';
      case 'number_counting_quest': return 'Number Counting Quest';
      default: return type.replaceAll('_', ' ').toUpperCase();
    }
  }
}