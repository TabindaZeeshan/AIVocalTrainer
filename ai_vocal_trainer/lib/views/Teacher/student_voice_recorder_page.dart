import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/student_voice_recorder_view_model.dart';
import '../../services/rule_based_speech_trainer.dart';
import '../../core/models/voice_profile.dart';
import 'learning_plan_page.dart';   // ← Important: Make sure this file exists

class StudentVoiceRecorderPage extends StatelessWidget {
  final String studentName;
  final int? studentAge;
  final String studentId;
  final String className;

  const StudentVoiceRecorderPage({
    super.key,
    required this.studentName,
    this.studentAge,
    required this.studentId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

    return ChangeNotifierProvider(
      create: (_) => StudentVoiceRecorderViewModel(
        studentName: studentName,
        studentId: studentId,
        className: className,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Record Voice"),
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
            child: Consumer<StudentVoiceRecorderViewModel>(
              builder: (context, vm, _) {
                if (vm.isProcessing) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFFF6B9D)),
                        SizedBox(height: 20),
                        Text("Analyzing pronunciation...", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }

                if (vm.transcription.isNotEmpty) {
                  return _buildResultsScreen(context, vm, softPink);
                }

                return _buildRecordingScreen(vm, softPink, lightPinkBg);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingScreen(StudentVoiceRecorderViewModel vm, Color softPink, Color lightPinkBg) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 65,
            backgroundColor: lightPinkBg,
            child: Icon(Icons.person, size: 80, color: softPink),
          ),
          const SizedBox(height: 30),
          Text(studentName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          if (studentAge != null)
            Text("$studentAge years old", style: TextStyle(fontSize: 20, color: Colors.grey[700])),
          const Spacer(),

          GestureDetector(
            onTap: vm.isRecording ? vm.stopRecording : vm.startRecording,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                color: vm.isRecording ? Colors.red.withOpacity(0.15) : softPink.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: vm.isRecording ? Colors.red : softPink,
                  width: 14,
                ),
              ),
              child: Icon(
                vm.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 110,
                color: vm.isRecording ? Colors.red : softPink,
              ),
            ),
          ),

          const SizedBox(height: 40),
          Text(
            vm.isRecording
                ? "Recording... Tap to stop"
                : "Tap to start recording\nSpeak clearly (e.g. One, Five, Ten)",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, color: Colors.grey),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ==================== RESULTS SCREEN ====================
  Widget _buildResultsScreen(BuildContext context, StudentVoiceRecorderViewModel vm, Color softPink) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pronunciation Feedback",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: softPink)),
          const SizedBox(height: 8),
          Text("Student: $studentName", style: const TextStyle(fontSize: 18)),

          const SizedBox(height: 24),

          // Transcription Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You said:", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(vm.transcription,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("Score Breakdown",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildScoreRow("Phoneme Accuracy", vm.scores['phonemeAccuracy'] ?? 0.0, softPink),
          _buildScoreRow("Intelligibility", vm.scores['intelligibility'] ?? 0.0, softPink),
          _buildScoreRow("Pitch", vm.scores['pitch'] ?? 0.0, softPink),
          _buildScoreRow("Loudness", vm.scores['loudness'] ?? 0.0, softPink),
          _buildScoreRow("Voice Quality", vm.scores['voiceQuality'] ?? 0.0, softPink),

          const SizedBox(height: 40),

          // Button to open separate Learning Plan Page
          ElevatedButton.icon(
            onPressed: () => _navigateToLearningPlan(context, vm),
            icon: const Icon(Icons.school_rounded, size: 28),
            label: const Text(
              "View Personalized Learning Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: softPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(double.infinity, 60),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.reset,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text("Record Again", style: TextStyle(color: softPink)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Done", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLearningPlan(BuildContext context, StudentVoiceRecorderViewModel vm) {
    final profile = VoiceProfile(
      phonemeAccuracy: vm.scores['phonemeAccuracy'] ?? 5.0,
      pitch: vm.scores['pitch'] ?? 5.0,
      loudness: vm.scores['loudness'] ?? 5.0,
      voiceQuality: vm.scores['voiceQuality'] ?? 5.0,
      intelligibility: vm.scores['intelligibility'] ?? 5.0,
      weakPhonemes: _extractWeakPhonemes(vm),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningPlanPage(
          studentName: studentName,
          studentAge: studentAge,
          voiceProfile: profile,
          studentId: studentId,
          className: className,
        ),
      ),
    );
  }
  Widget _buildScoreRow(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(width: 145, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(score.toStringAsFixed(1),
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Placeholder - improve later if needed
  Map<String, double> _extractWeakPhonemes(StudentVoiceRecorderViewModel vm) {
    return {};
  }
}