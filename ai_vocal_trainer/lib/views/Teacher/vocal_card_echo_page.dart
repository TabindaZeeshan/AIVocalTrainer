import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/student_voice_recorder_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vocal_echo_result_page.dart';

class VocalCardEchoPage extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String className;
  final Map<String, dynamic> plan;

  const VocalCardEchoPage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.className,
    required this.plan,
  });

  @override
  State<VocalCardEchoPage> createState() => _VocalCardEchoPageState();
}

class _VocalCardEchoPageState extends State<VocalCardEchoPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<String> targetWords;
  int currentWordIndex = 0;
  int totalAttemptsMade = 0;
  int correctCount = 0;
  List<Map<String, dynamic>> results = [];

  String feedback = "Tap Play to listen";
  bool isPlaying = false;

  String get currentWord => targetWords[currentWordIndex];
  bool get isLastWord => currentWordIndex == targetWords.length - 1;

  final Map<String, String> numberToFilename = {
    '1': 'one', '2': 'two', '3': 'three', '4': 'four', '5': 'five',
    '6': 'six', '7': 'seven', '8': 'eight', '9': 'nine', '10': 'ten',
  };

  @override
  void initState() {
    super.initState();

    // Safe extraction from Learning Plan
    List<dynamic> rawTargets = widget.plan['targetNumbers'] ?? 
                              widget.plan['targetWords'] ?? 
                              [1, 2, 3];

    targetWords = rawTargets.map((e) => e.toString()).toList();

    if (targetWords.isEmpty) {
      targetWords = ['1', '2', '3'];
    }

    print(" Loaded Targets from Plan: $targetWords");
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPrompt() async {
    if (isPlaying) return;
    setState(() { isPlaying = true; feedback = "  ${currentWord}..."; });

    try {
      String fileName = numberToFilename[currentWord] ?? currentWord.toLowerCase();
      await _audioPlayer.play(AssetSource('sounds/$fileName.mp3'));
      setState(() => feedback = "Repeat: ${currentWord}");
    } catch (e) {
      print(" Audio Error: $e");
      setState(() => feedback = " Audio missing for $currentWord");
    } finally {
      setState(() => isPlaying = false);
    }
  }

  void _startRecording(StudentVoiceRecorderViewModel vm) async {
    if (vm.isRecording || vm.isProcessing) return;
    vm.reset();
    await vm.startRecording();
    setState(() => feedback = " Recording... Speak clearly");
  }

  void _stopRecording(StudentVoiceRecorderViewModel vm) async {
    if (!vm.isRecording) return;
    await vm.stopRecording();
    _evaluate(vm);
  }

  String normalize(String text) => text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

  void _evaluate(StudentVoiceRecorderViewModel vm) {
    final spoken = normalize(vm.transcription);
    final target = normalize(currentWord);

    totalAttemptsMade++;
    double score = _similarity(spoken, target);
    bool correct = spoken.contains(target) || score >= 0.55;

    if (correct) correctCount++;

    results.add({
      "word": target,
      "spoken": spoken.isEmpty ? "(no speech detected)" : spoken,
      "score": score,
      "correct": correct,
    });

    setState(() {
      feedback = correct
          ? " Excellent! ${(score * 100).toStringAsFixed(0)}%"
          : " You said: '$spoken'  Wrong Number! Please Try Again";
    });
  }

  double _similarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    int maxLen = a.length > b.length ? a.length : b.length;
    return 1 - (_levenshtein(a, b) / maxLen);
  }

  int _levenshtein(String s1, String s2) {
    List<List<int>> dp = List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
    for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
    for (int j = 0; j <= s2.length; j++) dp[0][j] = j;
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
    }
    return dp[s1.length][s2.length];
  }

  void _next() => setState(() { currentWordIndex++; feedback = "Ready for next word"; });

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VocalEchoResultPage(
          studentName: widget.studentName,
          studentId: widget.studentId,
          className: widget.className,
          targetWords: targetWords,
          totalAttempts: totalAttemptsMade,
          correctAnswers: correctCount,
          results: results,
          activityType: "vocal_card_echo",
          plan: widget.plan,
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
               "🌸 Vocal Card Echo 🌸",
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Progress
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15)],
                        ),
                        child: Text(
                          "Word ${currentWordIndex + 1} of ${targetWords.length}",
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                              fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6B9D),
                                
                            ),
                            
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Big Target Number
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
  color: Colors.white.withOpacity(0.85),
  borderRadius: BorderRadius.circular(30),
  border: Border.all(
    color: const Color(0xFFFFB6D1),
    width: 3,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.pink.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ],
),
                        child: Text(
                          currentWord,
                          textAlign: TextAlign.center,
                         style: GoogleFonts.fredoka(
                           fontSize: 90,
                            fontWeight: FontWeight.w900,
                              color: const Color(0xFFFF4F9A),
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                      blurRadius: 10,
                                        offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Feedback
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
                        ),
                        child: Text(
                          feedback,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.baloo2(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: const Color(0xFFFF6B9D),
),
                        ),
                      ),

                      const Spacer(),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _playPrompt,
                              icon: const Icon(Icons.volume_up),
                              label: Text(
  "Play",
  style: GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B9D),
elevation: 8,
shadowColor: Colors.pinkAccent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: vm.isRecording ? () => _stopRecording(vm) : () => _startRecording(vm),
                              icon: Icon(vm.isRecording ? Icons.stop : Icons.mic),
                              label: Text(vm.isRecording ? "Stop" : "Record", style: GoogleFonts.fredoka(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: vm.isRecording ? Colors.red : softPink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (!vm.isRecording && vm.transcription.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLastWord ? _finish : _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: softPink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: Text(
                                isLastWord ? "Finish Activity" : "Next Word",
                                style: GoogleFonts.fredoka(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
),
                              ),
                            ),
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
}