import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressTrackingPage extends StatefulWidget {
  final String className;
  final String teacherId; // optional

  const ProgressTrackingPage({
    super.key,
    required this.className,
    this.teacherId = '',
  });

  @override
  State<ProgressTrackingPage> createState() => _ProgressTrackingPageState();
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {
  final Color softPink = const Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Progress - ${widget.className}"),
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
                .where('className', isEqualTo: widget.className)
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
                      Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No students found in ${widget.className}",
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final students = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index].data() as Map<String, dynamic>;
                  final studentId = students[index].id;
                  final studentName = student['name'] ?? student['studentName'] ?? 'Unknown';

                  return _buildStudentProgressCard(
                    studentId: studentId,
                    studentName: studentName,
                    studentData: student,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStudentProgressCard({
    required String studentId,
    required String studentName,
    required Map<String, dynamic> studentData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFFFF0F5),
                  child: Text(
                    studentName.isNotEmpty ? studentName[0].toUpperCase() : "?",
                    style: TextStyle(fontSize: 24, color: softPink, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("ID: $studentId", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                _buildOverallScore(studentData),
              ],
            ),

            const Divider(height: 32),

            // Recent Activity Stats
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .doc(studentId)
                  .collection('practice_sessions')
                  .orderBy('recordedAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, sessionSnapshot) {
                if (!sessionSnapshot.hasData) {
                  return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                }

                final sessions = sessionSnapshot.data!.docs;
                final totalSessions = sessions.length;

                // Calculate stats
                int totalCorrect = 0;
                int totalAttempts = 0;
                Map<String, int> activityCount = {};

                for (var doc in sessions) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalCorrect += (data['correctAnswers'] ?? 0) as int;
                  totalAttempts += (data['totalAttempts'] ?? 0) as int;

                  final type = data['activityType']?.toString() ?? 'unknown';
                  activityCount[type] = (activityCount[type] ?? 0) + 1;
                }

                final accuracy = totalAttempts > 0
                    ? (totalCorrect / totalAttempts * 100).toStringAsFixed(1)
                    : "0.0";

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("Sessions", totalSessions.toString()),
                        _buildStatColumn("Accuracy", "$accuracy%"),
                        _buildStatColumn("Activities", activityCount.length.toString()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Last Activity
                    if (sessions.isNotEmpty)
                      _buildLastActivity(sessions.first.data() as Map<String, dynamic>),

                    const SizedBox(height: 16),

                    // Quick View of Activities
                    Wrap(
                      spacing: 8,
                      children: activityCount.entries.map((entry) {
                        return Chip(
                          label: Text(_formatActivityName(entry.key)),
                          backgroundColor: softPink.withOpacity(0.1),
                          labelStyle: TextStyle(color: softPink),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScore(Map<String, dynamic> studentData) {
    final score = (studentData['lastVoiceProfileScore'] ?? 0.0).toDouble();
    final percentage = (score * 10).toInt();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: score / 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(softPink),
                strokeWidth: 8,
              ),
            ),
            Text(
              "$percentage",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Text("Score", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLastActivity(Map<String, dynamic> session) {
    final timestamp = session['recordedAt'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(date);

    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text("Last activity: $formattedDate",
            style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  String _formatActivityName(String type) {
    switch (type) {
      case 'vocal_card_echo':
        return 'Vocal Echo';
      case 'number_pair_sequence':
        return 'Number Pairs';
      case 'number_counting_quest':
        return 'Counting Quest';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }
}