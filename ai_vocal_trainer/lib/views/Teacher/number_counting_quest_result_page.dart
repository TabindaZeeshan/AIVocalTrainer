import 'package:ai_vocal_trainer/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'student_practice_activites_page.dart';

class NumberCountingQuestResultPage extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String className;
  final List<int> targetSequence;
  final int totalAttempts;
  final int correctAnswers;
  final List<Map<String, dynamic>> results;
  final Map<String, dynamic>? plan;
  final int level;

  const NumberCountingQuestResultPage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.className,
    required this.targetSequence,
    required this.totalAttempts,
    required this.correctAnswers,
    required this.results,
    this.plan,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);

    WidgetsBinding.instance.addPostFrameCallback((_) => _saveToFirestore());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Activity Result"),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                child: Text(
                  "Great Job, $studentName! ",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: softPink),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Detailed Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: results.length,
                  itemBuilder: (context, index) => _resultCard(results[index], softPink),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.replay),
                        label: const Text("Repeat"),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showVerifyDialog(context),
                        icon: const Icon(Icons.check),
                        label: const Text("Verify Result"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softPink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CONFIRMATION DIALOG ====================
  void _showVerifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Verify Result"),
        content: const Text("Are you sure you want to verify this result and continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyAndContinue(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D)),
            child: const Text("Yes, Verify", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('practice_sessions')
          .add({
        'studentId': studentId,
        'studentName': studentName,
        'className': className,
        'activityType': 'number_counting_quest',
        'targetSequence': targetSequence,
        'level': level,
        'totalAttempts': totalAttempts,
        'correctAnswers': correctAnswers,
        'results': results,
        'plan': plan,
        'recordedAt': FieldValue.serverTimestamp(),
      });
      print("Number Counting Quest Results Saved!");
    } catch (e) {
      print("Save failed: $e");
    }
  }

  void _verifyAndContinue(BuildContext context) async {
    try {
      await NotificationService.sendPracticeCompletedNotification(
        studentId: studentId,
        studentName: studentName,
        activityType: 'number_counting_quest',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Result Verified! Parent has been notified."),
          backgroundColor: Colors.green,
        ),
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentPracticeActivitiesPage(
              studentName: studentName,
              studentId: studentId,
              className: className,
              learningPlan: plan,
            ),
          ),
        );
      }
    } catch (e) {
      print("Verification Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verified but failed to notify: $e"),
          backgroundColor: Colors.orange,
        ),
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentPracticeActivitiesPage(
              studentName: studentName,
              studentId: studentId,
              className: className,
              learningPlan: plan,
            ),
          ),
        );
      }
    }
  }

  Widget _resultCard(Map<String, dynamic> item, Color softPink) {
    final bool correct = item['correct'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: correct ? Colors.green : Colors.red,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Attempt ${item['attempt']}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Target: ${item['target']}",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  "You said: ${item['spoken']}",
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
              ],
            ),
          ),
          Text(
            correct ? "Correct" : "Incorrect",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: correct ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}