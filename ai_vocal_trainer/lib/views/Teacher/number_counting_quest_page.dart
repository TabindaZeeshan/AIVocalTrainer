import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/student_voice_recorder_view_model.dart';
import 'number_counting_quest_result_page.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberCountingQuestPage extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String className;
  final Map<String, dynamic>? plan;

  const NumberCountingQuestPage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.className,
    this.plan,
  });

  @override
  State<NumberCountingQuestPage> createState() => _NumberCountingQuestPageState();
}

class _NumberCountingQuestPageState extends State<NumberCountingQuestPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<int> targetSequence = [];
  int maxAttempts = 4;
  String difficulty = "beginner";

  int currentAttempt = 0;
  int correctCount = 0;
  List<Map<String, dynamic>> detailedResults = [];

  String feedback = "Press Play Example then Start Recording";

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  void _loadPlan() {
    try {
      final plan = widget.plan ?? {};

      final focusNumbers = plan['focusNumbers'] as List<dynamic>?;
      if (focusNumbers != null && focusNumbers.isNotEmpty) {
        targetSequence = focusNumbers
            .map((e) => int.tryParse(e.toString()) ?? 1)
            .toList();
      } else {
        targetSequence = [1, 2, 3];
      }

      maxAttempts = (plan['maxAttempts'] as num?)?.toInt() ?? 4;
      difficulty = (plan['difficulty'] as String?) ?? "beginner";

      print("✅ Counting Quest Loaded → Target: $targetSequence | Difficulty: $difficulty | Max Attempts: $maxAttempts");
    } catch (e) {
      print("⚠️ Error loading plan: $e");
      targetSequence = [1, 2, 3];
      maxAttempts = 4;
      difficulty = "beginner";
    }
  }

  Future<void> _playPrompt() async {
    if (targetSequence.isEmpty) return;
    setState(() => feedback = "Playing example...");
    for (int num in targetSequence) {
      await _playNumber(num.toString());
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() => feedback = "Now count clearly from ${targetSequence.first} to ${targetSequence.last}");
  }

  Future<void> _playNumber(String num) async {
    final map = {
      '1': 'one', '2': 'two', '3': 'three', '4': 'four', '5': 'five',
      '6': 'six', '7': 'seven', '8': 'eight', '9': 'nine', '10': 'ten'
    };
    String fileName = map[num] ?? num.toLowerCase();
    await _audioPlayer.play(AssetSource('sounds/$fileName.mp3'));
  }

  void _startRecording(StudentVoiceRecorderViewModel vm) async {
    if (vm.isRecording) return;
    vm.reset();
    await vm.startRecording();
    setState(() => feedback = "Listening... Speak now");
  }

  void _stopRecording(StudentVoiceRecorderViewModel vm) async {
    if (!vm.isRecording) return;
    await vm.stopRecording();
    _evaluate(vm);
  }

  void _evaluate(StudentVoiceRecorderViewModel vm) {
    final spoken = vm.transcription.toLowerCase().trim();
    final targetText = targetSequence.join(" ");

    currentAttempt++;                    // ← Increment attempt
    bool isCorrect = _isGoodMatch(spoken, targetSequence);

    if (isCorrect) correctCount++;

    detailedResults.add({
      "attempt": currentAttempt,
      "spoken": spoken.isEmpty ? "(no speech detected)" : spoken,
      "target": targetText,
      "correct": isCorrect,
    });

    setState(() {
      feedback = isCorrect ? "Well Done!" : "Try again";
    });

    // Auto finish when max attempts reached
    if (currentAttempt >= maxAttempts) {
      Future.delayed(const Duration(milliseconds: 1200), _finish);
    }
  }

  bool _isGoodMatch(String spoken, List<int> targets) {
    if (spoken.isEmpty || targets.isEmpty) return false;
    String clean = spoken.replaceAll(RegExp(r'[^0-9a-z ]'), '');
    return targets.every((num) =>
        clean.contains(num.toString()) || clean.contains(_numberToWord(num)));
  }

  String _numberToWord(int num) {
    const map = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five',
                 6: 'six', 7: 'seven', 8: 'eight', 9: 'nine', 10: 'ten'};
    return map[num] ?? '';
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NumberCountingQuestResultPage(
          studentName: widget.studentName,
          studentId: widget.studentId,
          className: widget.className,
          targetSequence: targetSequence,
          totalAttempts: currentAttempt,
          correctAnswers: correctCount,
          results: detailedResults,
          plan: widget.plan,
          level: targetSequence.length <= 3 ? 0 : targetSequence.length <= 5 ? 1 : 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);

    return ChangeNotifierProvider(
      create: (_) => StudentVoiceRecorderViewModel(
        studentName: widget.studentName,
        studentId: widget.studentId,
        className: widget.className,
      ),
      child: Consumer<StudentVoiceRecorderViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
  "🌸 Counting Quest 🌸",
  style: GoogleFonts.fredoka(
    fontSize: 30,
    fontWeight: FontWeight.bold,
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
    image: AssetImage('assets/images/bg3.jpg'),
    fit: BoxFit.cover,
  ),
),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15)],
                        ),
                        child: Column(
                          children: [
                            Text("Difficulty: ${difficulty.toUpperCase()}", 
                                style: GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFF6B9D),
  ),),
                            const SizedBox(height: 8),
                            Text(
                              "Count from ${targetSequence.first} to ${targetSequence.last}",
                              style: GoogleFonts.baloo2(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFFFF6B9D),
  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Color(0xFFFFB6D1), width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.pinkAccent.withOpacity(0.2),
        blurRadius: 12,
      )
    ],
  ),
  child: Text(
    feedback,
    textAlign: TextAlign.center,
    style: GoogleFonts.luckiestGuy(
      fontSize: 17,
      color: Color(0xFFFF4F9A),
      letterSpacing: 1.5,
    ),
  ),
),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _playPrompt,
                              style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFFF6B9D),
  elevation: 8,
  shadowColor: Colors.pinkAccent,
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
),
                              child: Text("Play Example",  style: GoogleFonts.luckiestGuy(
    fontSize: 16,
    color: Colors.white,
    letterSpacing: 1.2,
  ),),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: vm.isRecording
                                  ? () => _stopRecording(vm)
                                  : () => _startRecording(vm),
                              style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFFF6B9D),
  elevation: 8,
  shadowColor: Colors.pinkAccent,
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
),
                              child: Text(vm.isRecording ? "Stop Recording" : "Start Recording", style: GoogleFonts.luckiestGuy(
    fontSize: 16,
    color: Colors.white,
    letterSpacing: 1.2,
  ),),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Text(
                        "Attempt ${currentAttempt} of $maxAttempts",
                        style: GoogleFonts.fredoka(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 6,
        color: Colors.pinkAccent,
        offset: Offset(2, 2),
      )
    ],
  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}