// lib/pages/student/learning_plan_page.dart
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

    // ✅ Use new dynamic plan that includes all 3 activities
    final fullPlan = ruleEngine.generateDynamicLearningPlan(
      profile: voiceProfile,
      recentResults: [], // Will be populated from history in ViewModel
      age: studentAge ?? 5,
    );

    final activities = fullPlan['activities'] as Map<String, dynamic>? ?? {};

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
                // Student Info
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

                // Overall Score
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
                      Text("${fullPlan['overallScore']}/10",
                          style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: softPink)),
                      Text("(${fullPlan['overallPercentage']}%)", style: const TextStyle(fontSize: 20, color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text("Recommended Learning Path", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: softPink)),
                const SizedBox(height: 20),

                // ==================== ALL 3 ACTIVITIES ====================
                _buildActivityPlanCard(
                  title: "1. Vocal Card Echo",
                  plan: activities['vocal_card_echo'],
                  icon: Icons.record_voice_over,
                ),

                const SizedBox(height: 16),

                _buildActivityPlanCard(
                  title: "2. Number Pair Sequence",
                  plan: activities['number_pair_sequence'],
                  icon: Icons.repeat,
                ),

                const SizedBox(height: 16),

                _buildActivityPlanCard(
                  title: "3. Number Counting Quest",
                  plan: activities['number_counting_quest'],
                  icon: Icons.emoji_events,
                ),

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
                  child: Text(
                    fullPlan['recommendedFeedback'] ?? "Practice daily with clear pronunciation.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveAndGoToPractice(context, fullPlan),
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

  // ==================== NEW ACTIVITY CARD ====================
  Widget _buildActivityPlanCard({
    required String title,
    required Map<String, dynamic>? plan,
    required IconData icon,
  }) {
    final Color softPink = const Color(0xFFFF6B9D);

    if (plan == null) return const SizedBox();

    final targetText = plan['targetNumbers'] != null
        ? (plan['targetNumbers'] as List).join(" • ")
        : plan['targetPairs'] != null
            ? (plan['targetPairs'] as List).join(" • ")
            : (plan['focusNumbers'] as List?)?.join(" • ") ?? "1 - 10";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: softPink, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Difficulty", (plan['difficulty'] ?? "beginner").toString().toUpperCase()),
          _buildDetailRow("Target", targetText),
          _buildDetailRow("Max Attempts", plan['maxAttempts'].toString()),
          _buildDetailRow("Time Limit", "${plan['timeLimitSeconds']} sec"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // ==================== SAVE FULL PLAN ====================
  Future<void> _saveAndGoToPractice(BuildContext context, Map<String, dynamic> fullPlan) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('students').doc(studentId).collection('learning_plans').add({
        ...fullPlan,
        'studentName': studentName,
        'className': className,
        'phonemeAccuracy': voiceProfile.phonemeAccuracy,
        'pitch': voiceProfile.pitch,
        'loudness': voiceProfile.loudness,
        'voiceQuality': voiceProfile.voiceQuality,
        'intelligibility': voiceProfile.intelligibility,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('students').doc(studentId).update({
        'currentLearningPlan': fullPlan,
        'lastVoiceProfileScore': voiceProfile.overallScore,
        'lastPlanUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Full Learning Plan Saved Successfully!"), backgroundColor: Color(0xFFFF6B9D)),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentPracticeActivitiesPage(
              studentName: studentName,
              studentId: studentId,
              className: className,
              learningPlan: fullPlan,   // Pass full plan with all 3 activities
            ),
          ),
        );
      }
    } catch (e) {
      print("Error saving plan: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save plan"), backgroundColor: Colors.red),
        );
      }
    }
  }
}