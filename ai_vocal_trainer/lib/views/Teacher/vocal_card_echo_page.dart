import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/student_voice_recorder_view_model.dart';
import 'vocal_echo_result_page.dart';

class VocalCardEchoPage extends StatefulWidget {
  final String studentName;
  final List<String> targetWords;
  final String className;
  final String studentId;

  const VocalCardEchoPage({
    super.key,
    required this.studentName,
    required this.targetWords,
    required this.className,
    required this.studentId,
  });

  @override
  State<VocalCardEchoPage> createState() => _VocalCardEchoPageState();
}

class _VocalCardEchoPageState extends State<VocalCardEchoPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentWordIndex = 0;
  int totalAttemptsMade = 0;
  int correctCount = 0;

  String feedback = "Tap Play then Record";
  bool isPlaying = false;
  bool hasEvaluated = false;

  List<Map<String, dynamic>> results = [];

  String get currentWord => widget.targetWords[currentWordIndex];
  bool get isLastWord => currentWordIndex == widget.targetWords.length - 1;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 🔹 TEXT CLEANING (UNCHANGED)
  String cleanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\d+'), '')
        .trim();
  }

  String normalize(String text) {
    return cleanText(text)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .join(' ');
  }

  // 🔊 PLAY AUDIO (UNCHANGED)
  Future<void> _playPrompt() async {
    if (isPlaying) return;

    setState(() {
      isPlaying = true;
      feedback = "Playing...";
    });

    try {
      final path = 'assets/sounds/${currentWord.toLowerCase()}.mp3';
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();

      setState(() {
        feedback = "Say: ${currentWord.toUpperCase()}";
      });
    } catch (e) {
      setState(() => feedback = "Audio not found");
    } finally {
      setState(() => isPlaying = false);
    }
  }

  // 🎤 RECORDING (UNCHANGED)
  void _startRecording(StudentVoiceRecorderViewModel vm) async {
    if (vm.isRecording || vm.isProcessing) return;

    vm.reset();
    hasEvaluated = false;

    await vm.startRecording();

    setState(() {
      feedback = "Recording...";
    });
  }

  void _stopRecording(StudentVoiceRecorderViewModel vm) async {
    if (!vm.isRecording) return;

    await vm.stopRecording();

    if (!hasEvaluated) {
      hasEvaluated = true;
      _evaluate(vm);
    }
  }

  // 🧠 SIMILARITY (UNCHANGED)
  double _similarity(String a, String b) {
    int maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 1;

    int distance = _levenshtein(a, b);
    return 1 - (distance / maxLen);
  }

  int _levenshtein(String s1, String s2) {
    List<List<int>> dp = List.generate(
      s1.length + 1,
      (_) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
    for (int j = 0; j <= s2.length; j++) dp[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;

        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[s1.length][s2.length];
  }

  // 🧠 EVALUATION (UNCHANGED)
  void _evaluate(StudentVoiceRecorderViewModel vm) {
    final spoken = normalize(vm.transcription);
    final target = cleanText(currentWord);

    totalAttemptsMade++;

    double score = _similarity(spoken, target);
    bool correct = spoken.contains(target) || score >= 0.5;

    if (correct) correctCount++;

    results.add({
      "word": target,
      "spoken": spoken,
      "score": score,
      "correct": correct,
    });

    setState(() {
      feedback = correct
          ? "Correct! ${(score * 100).toStringAsFixed(0)}%"
          : "You said: $spoken (${(score * 100).toStringAsFixed(0)}%)";
    });
  }

  void _next() {
    setState(() {
      currentWordIndex++;
      feedback = "Next word";
    });
  }

  void _finish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocalEchoResultPage(
          studentName: widget.studentName,
          targetWords: widget.targetWords,
          totalAttempts: totalAttemptsMade,
          correctAnswers: correctCount,
          results: results,
          className: widget.className,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

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
              title: const Text("Vocal Echo"),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),

            body: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 📊 PROGRESS CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Text(
                          "Word ${currentWordIndex + 1} / ${widget.targetWords.length}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 🟣 WORD CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Text(
                          currentWord,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: softPink,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 💬 FEEDBACK CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Text(
                          feedback,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🔘 BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _playPrompt,
                              icon: const Icon(Icons.volume_up),
                              label: const Text("Play"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: softPink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: vm.isRecording
                                  ? () => _stopRecording(vm)
                                  : () => _startRecording(vm),
                              icon: Icon(
                                  vm.isRecording ? Icons.stop : Icons.mic),
                              label: Text(
                                  vm.isRecording ? "Stop" : "Record"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: vm.isRecording
                                    ? Colors.red
                                    : softPink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // NEXT / FINISH
                      if (!vm.isRecording &&
                          vm.transcription.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLastWord ? _finish : _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: softPink,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(isLastWord ? "Finish" : "Next"),
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