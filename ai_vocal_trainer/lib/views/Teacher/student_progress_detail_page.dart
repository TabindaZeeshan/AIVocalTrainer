import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentProgressDetailPage extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String className;

  const StudentProgressDetailPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.className,
  });

  final Color softPink = const Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("$studentName's Progress"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
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

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_outlined, size: 90, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text("No practice sessions yet", style: TextStyle(fontSize: 20, color: Colors.grey[700])),
                      const Text("Start practicing to see progress here", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              final sessions = snapshot.data!.docs;

              int totalCorrect = 0;
              int totalAttempts = 0;
              Map<String, int> activityCount = {};

              for (var doc in sessions) {
                final data = doc.data() as Map<String, dynamic>;
                totalCorrect += (data['correctAnswers'] ?? 0) as int;
                totalAttempts += (data['totalAttempts'] ?? 0) as int;

                final type = data['activityType']?.toString() ?? 'other';
                activityCount[type] = (activityCount[type] ?? 0) + 1;
              }

              final overallAccuracy = totalAttempts > 0
                  ? (totalCorrect / totalAttempts * 100).toStringAsFixed(1)
                  : "0.0";

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
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
                        Text("$overallAccuracy%", 
                            style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: softPink)),
                        Text("Average Accuracy", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem("Total Sessions", sessions.length.toString()),
                            _buildSummaryItem("Activities", activityCount.length.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text("Recent Activities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ...sessions.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildSessionCard(data);
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final timestamp = session['recordedAt'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(date);

    final accuracy = session['totalAttempts'] != null && session['totalAttempts'] > 0
        ? ((session['correctAnswers'] ?? 0) / session['totalAttempts'] * 100).toStringAsFixed(1)
        : "0.0";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatActivity(session['activityType'] ?? ''), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: softPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("$accuracy%", 
                style: TextStyle(fontWeight: FontWeight.bold, color: softPink)),
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