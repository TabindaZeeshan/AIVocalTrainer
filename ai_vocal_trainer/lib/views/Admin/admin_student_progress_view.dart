// TODO Implement this library.import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminStudentProgressView extends StatelessWidget {
  final String studentName;
  final String studentId;

  const AdminStudentProgressView({
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
                      const Text("No practice sessions yet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
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

              final overallAccuracy = totalAttempts > 0 ? (totalCorrect / totalAttempts * 100).toStringAsFixed(1) : "0.0";

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  Text("$studentName's", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.95))),
                  const Text("Progress", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 40),

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
                  const SizedBox(height: 16),

                  ...sessions.map((doc) => _buildSessionCard(doc.data() as Map<String, dynamic>)).toList(),
                ],
              );
            },
          ),
        ),
      ),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
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