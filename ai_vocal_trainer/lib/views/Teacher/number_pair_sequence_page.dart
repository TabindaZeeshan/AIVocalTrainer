import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/student_voice_recorder_view_model.dart';
import 'number_pair_result_page.dart';

class NumberPairSequencePage extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String className;
  final Map<String, dynamic> plan;

  const NumberPairSequencePage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.className,
    required this.plan,
  });

  @override
  State<NumberPairSequencePage> createState() => _NumberPairSequencePageState();
}

class _NumberPairSequencePageState extends State<NumberPairSequencePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<String> targetPairs;
  int currentPairIndex = 0;
  int totalAttemptsMade = 0;
  int correctCount = 0;
  List<Map<String, dynamic>> results = [];

  String feedback = "Tap Play then Record the pair";
  bool isPlaying = false;

  String get currentPair => targetPairs[currentPairIndex];
  bool get isLastPair => currentPairIndex == targetPairs.length - 1;

  @override
  void initState() {
    super.initState();

    final plan = widget.plan;
    List<String> loadedPairs = [];

    final rawPairs = plan['targetPairs'];
    if (rawPairs is List && rawPairs.isNotEmpty) {
      loadedPairs = rawPairs.map((e) => e.toString()).toList();
    } else if (plan['targetNumbers'] is List) {
      final numbers = List<int>.from(plan['targetNumbers']);
      for (int i = 0; i < numbers.length - 1; i++) {
        loadedPairs.add("${numbers[i]} - ${numbers[i + 1]}");
      }
    }

    if (loadedPairs.isEmpty) {
      loadedPairs = ["1 - 2", "2 - 3", "3 - 4"];
    }

    targetPairs = loadedPairs;

    print("Final targetPairs (${targetPairs.length}): $targetPairs");
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPrompt() async {
    if (isPlaying) return;

    setState(() {
      isPlaying = true;
      feedback = "Playing...";
    });

    try {
      final parts = currentPair.split(' - ');

      if (parts.length == 2) {
        await _playNumber(parts[0].trim());
        await Future.delayed(const Duration(milliseconds: 700));
        await _playNumber(parts[1].trim());
      }

      setState(() => feedback = "Repeat: $currentPair");
    } catch (e) {
      setState(() => feedback = "Audio error");
    } finally {
      setState(() => isPlaying = false);
    }
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
    if (vm.isRecording || vm.isProcessing) return;

    vm.reset();
    await vm.startRecording();

    setState(() => feedback = "Recording...");
  }

  void _stopRecording(StudentVoiceRecorderViewModel vm) async {
    if (!vm.isRecording) return;

    await vm.stopRecording();
    _evaluate(vm);
  }

  void _evaluate(StudentVoiceRecorderViewModel vm) {
    final spoken = vm.transcription.toLowerCase().trim();
    final target = currentPair.toLowerCase();

    totalAttemptsMade++;

    bool correct = _isCorrectMatch(spoken, target);

    if (correct) correctCount++;

    results.add({
      "pair": target,
      "spoken": spoken.isEmpty ? "(no speech detected)" : spoken,
      "correct": correct,
    });

    setState(() {
      feedback = correct ? "Correct!" : "Try again";
    });
  }

  bool _isCorrectMatch(String spoken, String target) {
    if (spoken.isEmpty) return false;

    // Exact match
    if (spoken.contains(target) || 
        spoken.replaceAll(' ', '').contains(target.replaceAll(' ', ''))) {
      return true;
    }

    // Split target (e.g. "1 - 2" -> ["1", "2"])
    final targetNumbers = target.split('-').map((e) => e.trim()).toList();

    // Check if spoken contains both numbers (as digit or word)
    return targetNumbers.every((num) => 
      spoken.contains(num) || 
      spoken.contains(_numberToWord(num))
    );
  }

  String _numberToWord(String num) {
    const map = {
      '1': 'one', '2': 'two', '3': 'three', '4': 'four', '5': 'five',
      '6': 'six', '7': 'seven', '8': 'eight', '9': 'nine', '10': 'ten'
    };
    return map[num] ?? '';
  }

  void _next() {
    setState(() {
      if (currentPairIndex < targetPairs.length - 1) {
        currentPairIndex++;
      }
      feedback = "Next pair";
    });
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NumberPairResultPage(
          studentName: widget.studentName,
          studentId: widget.studentId,
          className: widget.className,
          targetPairs: targetPairs,
          totalAttempts: totalAttemptsMade,
          correctAnswers: correctCount,
          results: results,
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
              title: const Text("Number Pair Sequence"),
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
                    children: [
                      Text(
                        "Pair ${currentPairIndex + 1} of ${targetPairs.length}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          currentPair,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: softPink),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(feedback),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _playPrompt,
                              style: ElevatedButton.styleFrom(backgroundColor: softPink),
                              child: const Text("Play"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: vm.isRecording
                                  ? () => _stopRecording(vm)
                                  : () => _startRecording(vm),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: vm.isRecording ? Colors.red : softPink),
                              child: Text(vm.isRecording ? "Stop" : "Record"),
                            ),
                          ),
                        ],
                      ),

                      if (vm.transcription.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                            onPressed: isLastPair ? _finish : _next,
                            child: Text(isLastPair ? "Finish" : "Next"),
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