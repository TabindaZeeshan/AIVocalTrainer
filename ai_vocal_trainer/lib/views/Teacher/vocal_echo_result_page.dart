import 'package:ai_vocal_trainer/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'student_practice_activites_page.dart';
import 'package:google_fonts/google_fonts.dart';


class VocalEchoResultPage extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String className;
  final List<String> targetWords;
  final int totalAttempts;
  final int correctAnswers;
  final List<Map<String, dynamic>> results;
  final String activityType;
  final Map<String, dynamic>? plan;

  const VocalEchoResultPage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.className,
    required this.targetWords,
    required this.totalAttempts,
    required this.correctAnswers,
    required this.results,
    required this.activityType,
    this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);

    WidgetsBinding.instance.addPostFrameCallback((_) => _saveToFirestore());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
  "🌸 Activity Result 🌸",
  style: GoogleFonts.fredoka(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: Colors.white,
  ),
),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/bg1.jpg'),
    fit: BoxFit.cover,
  ),
),
        child: SafeArea(
          child: Column(
            children: [
             Container(
  margin: const EdgeInsets.symmetric(horizontal: 24),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(30),
    border: Border.all(
      color: const Color(0xFFFFB6D1),
      width: 3,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.pink.withOpacity(0.25),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Column(
    children: [
      Text(
        "Great Job!",
        style: GoogleFonts.fredoka(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF4F9A),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        studentName,
        textAlign: TextAlign.center,
        style: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFF6B9D),
        ),
      ),
      const SizedBox(height: 12),
     
    ],
  ),
),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
  "🌸 Detailed Results",
  style: GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFFF6B9D),
  ),
),),
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
                        label: Text(
  "Repeat",
  style: GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
                        style: OutlinedButton.styleFrom(
  foregroundColor: softPink,
  side: BorderSide(
    color: softPink,
    width: 2,
  ),
  padding: const EdgeInsets.symmetric(vertical: 18),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showVerifyDialog(context),
                        icon: const Icon(Icons.check),
                        label: Text(
  "Verify Result",
  style: GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
                        style: ElevatedButton.styleFrom(
  backgroundColor: softPink,
  elevation: 8,
  shadowColor: Colors.pinkAccent,
  padding: const EdgeInsets.symmetric(vertical: 18),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
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
              _verifyAndContinue(context);   // Fixed calling
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
        'activityType': activityType,
        'targetWords': targetWords,
        'totalAttempts': totalAttempts,
        'correctAnswers': correctAnswers,
        'results': results,
        'plan': plan,
        'recordedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Save failed: $e");
    }
  }

  // ==================== FIXED NAVIGATION ====================
void _verifyAndContinue(BuildContext context) async {
  try {
    // Send simplified notification
    await NotificationService.sendPracticeCompletedNotification(
      studentId: studentId,
      studentName: studentName,
      activityType: activityType,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Result Verified! Parent has been notified."),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to activities
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

    // Still navigate
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
                Text(item['word'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("You said: ${item['spoken']}", style: TextStyle(color: Colors.grey[700], fontSize: 15)),
              ],
            ),
          ),
          Text(
            "${(item['score'] * 100).toStringAsFixed(0)}%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: softPink),
          ),
        ],
      ),
    );
  }
}