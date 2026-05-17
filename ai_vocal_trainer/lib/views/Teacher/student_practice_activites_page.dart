// lib/pages/student/student_practice_activites_page.dart
import 'package:flutter/material.dart';
import 'vocal_card_echo_page.dart';
import 'number_pair_sequence_page.dart';
import 'number_counting_quest_page.dart';

class StudentPracticeActivitiesPage extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String className;
  final Map<String, dynamic>? learningPlan;

  const StudentPracticeActivitiesPage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.className,
    this.learningPlan,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);

    final fullPlan = learningPlan ?? {};

    // === CRITICAL: Extract the specific activity plan ===
    final Map<String, dynamic> vocalPlan = 
        (fullPlan['activities'] as Map<String, dynamic>?)?['vocal_card_echo'] ?? fullPlan;

    // Get targets for display
    final List<String> targetWords = List<String>.from(
      vocalPlan['targetWords'] ?? 
      vocalPlan['targetNumbers']?.map((e) => e.toString()) ?? 
      ['1', '2', '3']
    );

   final Map<String, dynamic> pairPlan = 
        (fullPlan['activities'] as Map<String, dynamic>?)?['number_pair_sequence'] 
        ?? fullPlan;   // ←←← This is the key change

    print("🔍 Pair Plan Loaded: $pairPlan");
    print("🔍 Has targetPairs? ${pairPlan.containsKey('targetPairs')}");
    print("🔍 Has targetNumbers? ${pairPlan.containsKey('targetNumbers')}");

    print(" Targets being passed to Vocal Card Echo: $targetWords"); // Debug
    print("🔍 Pair Plan Loaded: $pairPlan"); // Added for debugging

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(studentName),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Practice Activities", 
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: softPink)),
                const SizedBox(height: 8),
                Text("Choose an activity for $studentName", 
                    style: const TextStyle(fontSize: 17, color: Colors.grey)),
                const SizedBox(height: 40),

                _buildActivityCard(
                  title: "1. Vocal Card Echo",
                  subtitle: "Target: ${targetWords.join(" • ")}",
                  icon: Icons.record_voice_over,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VocalCardEchoPage(
                          studentName: studentName,
                          studentId: studentId,
                          className: className,
                          plan: vocalPlan,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Number Pair Sequence
                _buildActivityCard(
                  title: "2. Number Pair Sequence",
                  subtitle: "Practice listening and repeating pairs",
                  icon: Icons.repeat,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NumberPairSequencePage(
                          studentName: studentName,
                          studentId: studentId,
                          className: className,
                          plan: pairPlan,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                _buildActivityCard(
                  title: "3. Number Counting Quest",
                  subtitle: "Count numbers in sequence",
                  icon: Icons.emoji_events,
                  onTap: () { /* TODO */ },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildActivityCard remains unchanged...
  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final Color softPink = const Color(0xFFFF6B9D);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: softPink),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(fontSize: 14.5, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: softPink, size: 20),
          ],
        ),
      ),
    );
  }
}