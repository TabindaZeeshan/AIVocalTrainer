import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:record/record.dart';
import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentVoiceRecorderViewModel extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  String? recordingPath;
  bool isRecording = false;
  bool isProcessing = false;

  String transcription = '';
  Map<String, dynamic> scores = {};
  List<Map<String, dynamic>> wordTimestamps = [];

  final String studentName;
  final String studentId;
  final String className;   

  StudentVoiceRecorderViewModel({
    required this.studentName,
    required this.studentId,
    required this.className,
  });

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print(" Microphone permission denied");
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    recordingPath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';

    try {
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: recordingPath!,
      );

      isRecording = true;
      transcription = '';
      scores = {};
      wordTimestamps = [];
      notifyListeners();

      print(" Recording started → $recordingPath");
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    await _recorder.stop();
    isRecording = false;
    notifyListeners();

    print("Recording stopped");

    if (recordingPath != null) {
      await _processAudioWithGoogle();
    }
  }

  Future<void> _processAudioWithGoogle() async {
    isProcessing = true;
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString(
        'assets/ai-vocal-trainer-d40d5-34c57811b188.json',
      );

      final serviceAccount = ServiceAccount.fromString(jsonString);
      final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

      final config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        sampleRateHertz: 16000,
        languageCode: 'en-US',
        model: RecognitionModel.latest_long,
        enableWordTimeOffsets: true,
        enableAutomaticPunctuation: true,
        speechContexts: [
          SpeechContext([
            "1","2","3","4","5","6","7","8","9","10"
          ]),
        ],
      );

      final bytes = await File(recordingPath!).readAsBytes();
      print(" Sending audio: ${bytes.length} bytes");

      final response = await speechToText.recognize(config, bytes);

      if (response.results.isNotEmpty && response.results.first.alternatives.isNotEmpty) {
        final alternative = response.results.first.alternatives.first;
        transcription = (alternative.transcript ?? "").trim();

        print("Transcript: '$transcription'");

        if (transcription.isNotEmpty) {
          wordTimestamps = alternative.words.map((word) {
            return {
              'word': word.word,
              'start': word.startTime.seconds.toDouble() + (word.startTime.nanos / 1e9),
              'end': word.endTime.seconds.toDouble() + (word.endTime.nanos / 1e9),
            };
          }).toList();

          final confidence = alternative.confidence ?? 0.5;
          final baseScore = (confidence * 10).clamp(3.0, 10.0);

          scores = {
            'phonemeAccuracy': (baseScore * 0.88).clamp(4.0, 10.0),
            'intelligibility': (baseScore + 1.5).clamp(0.0, 10.0),
            'pitch': baseScore.clamp(0.0, 10.0),
            'loudness': (baseScore + 1).clamp(0.0, 10.0),
            'voiceQuality': baseScore.clamp(0.0, 10.0),
          };

          await _saveScoreToFirestore();
        } else {
          transcription = "Speech detected but could not convert to text.\n\nSpeak louder and clearer.";
        }
      } else {
        transcription = "No clear speech detected.\n\nSpeak louder\nStay close to mic\nTry saying: 'one two three'";
      }
    } catch (e, stack) {
      print("Google STT Error: $e");
      print("Stack: $stack");
      transcription = "Connection error. Check internet.";
    }

    isProcessing = false;
    notifyListeners();
  }

  Future<void> _saveScoreToFirestore() async {
    try {
      print(" Attempting to save - studentId: $studentId, className: '$className'");

      if (className.isEmpty) {
        print(" WARNING: className is empty!");
      }

      final firestore = FirebaseFirestore.instance;

      final recordData = {
        'studentId': studentId,
        'studentName': studentName,
        'className': className.isNotEmpty ? className : 'Unknown Class',
        'transcription': transcription,
        'scores': scores,
        'wordTimestamps': wordTimestamps,
        'recordedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await firestore
          .collection('student_voice_records')
          .doc(studentId)
          .collection('recordings')
          .add(recordData);

      print("SUCCESS! Score saved with Document ID: ${docRef.id}");
    } catch (e, stack) {
      print("FAILED to save to Firestore: $e");
      print("Stack trace: $stack");
    }
  }

  void reset() {
    transcription = '';
    scores = {};
    wordTimestamps = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}