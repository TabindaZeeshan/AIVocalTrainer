// lib/pages/student/learning_plan_page.dart
import 'package:ai_vocal_trainer/views/Teacher/student_practice_activites_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/voice_profile.dart';
import '../../services/rule_based_speech_trainer.dart';
import 'student_practice_activites_page.dart';

class LearningPlanPage extends StatelessWidget {
  final String studentName;
  final int? studentAge;
  final VoiceProfile voiceProfile;
  final String studentId;
  final String className;

  const LearningPlanPage({
    super.key,
    required this.studentName,
    this.studentAge,
    required this.voiceProfile,
    required this.studentId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

    final ruleEngine = RuleBasedSpeechTrainer();
    final plan = ruleEngine.generateInitialPlan(voiceProfile, studentAge ?? 4);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Personalized Learning Plan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6D1),
              Color(0xFFFFD6E6),
              Color(0xFFFFF0F5),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: lightPinkBg,
                      child: Icon(Icons.person, size: 40, color: softPink),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(studentName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          if (studentAge != null)
                            Text("$studentAge years old", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      const Text("Voice Profile Score", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Text("${plan['voiceProfileScore']}/10", style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: softPink)),
                      Text("(${plan['voiceProfilePercentage']}%)", style: const TextStyle(fontSize: 20, color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text("Recommended Learning Path", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: softPink)),
                const SizedBox(height: 20),

                _buildPlanCard("Stage", plan['stage'] ?? "Stage 1 - Vocal Card Echo", Icons.flag_rounded),
                _buildPlanCard("Difficulty", (plan['difficulty'] ?? "Beginner").toString().toUpperCase(), Icons.speed_rounded),
                _buildPlanCard("Target Words", (plan['targetWords'] as List?)?.join(" • ") ?? "one, two", Icons.record_voice_over_rounded),
                _buildPlanCard("Maximum Attempts", plan['maxAttempts'].toString(), Icons.repeat_rounded),
                _buildPlanCard("Time Limit", "${plan['timeLimitSeconds']} seconds", Icons.timer_rounded),

                const SizedBox(height: 32),

                Text("Recommended Tips", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: softPink)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Text(plan['recommendedFeedback'] ?? "Practice daily with clear pronunciation.", style: const TextStyle(fontSize: 16, height: 1.5)),
                ),

                const SizedBox(height: 50),

                // FIXED BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveAndGoToPractice(context, plan),
                    icon: const Icon(Icons.school_rounded, size: 28),
                    label: const Text("Save & Start Practice", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: softPink),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("Back", style: TextStyle(color: softPink, fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FIXED NAVIGATION ====================
  Future<void> _saveAndGoToPractice(BuildContext context, Map<String, dynamic> plan) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final learningPlanData = {
        'studentId': studentId,
        'studentName': studentName,
        'className': className,
        'phonemeAccuracy': voiceProfile.phonemeAccuracy,
        'pitch': voiceProfile.pitch,
        'loudness': voiceProfile.loudness,
        'voiceQuality': voiceProfile.voiceQuality,
        'intelligibility': voiceProfile.intelligibility,
        'voiceProfileScore': voiceProfile.overallScore,
        'overallPercentage': voiceProfile.overallPercentage,
        'stage': plan['stage'],
        'difficulty': plan['difficulty'],
        'targetWords': plan['targetWords'] ?? [],
        'maxAttempts': plan['maxAttempts'],
        'timeLimitSeconds': plan['timeLimitSeconds'],
        'recommendedFeedback': plan['recommendedFeedback'],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firestore.collection('students').doc(studentId).collection('learning_plans').add(learningPlanData);

      await firestore.collection('students').doc(studentId).update({
        'currentStage': plan['stage'],
        'lastVoiceProfileScore': voiceProfile.overallScore,
        'lastPlanUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plan saved! Starting practice..."), backgroundColor: Color(0xFFFF6B9D)),
        );

        // This is the most important line
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentPracticeActivitiesPage(
              studentName: studentName,
              studentId: studentId,
              className: className,
              learningPlan: plan,        // ← Passing the actual plan
            ),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save plan"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildPlanCard(String title, String value, IconData icon) {
    final Color softPink = const Color(0xFFFF6B9D);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Icon(icon, color: softPink, size: 30),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}