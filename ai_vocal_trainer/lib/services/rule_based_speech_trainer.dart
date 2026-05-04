import '../core/models/voice_profile.dart';

class RuleBasedSpeechTrainer {
  static const double PASS_PHONEME_ACCURACY = 8.0;
  static const double PASS_PITCH_LOUDNESS = 7.0;
  static const double PASS_VOICE_QUALITY = 6.5;
  static const double PASS_INTELLIGIBILITY = 7.0;

  Map<String, dynamic> generateInitialPlan(VoiceProfile profile, int age) {
    final score = profile.overallScore;

    String stage = "Stage1_VocalCardEcho";
    String difficulty = "beginner";
    int maxAttempts = 5;
    int timeLimitSeconds = 75;
    List<String> targetWords = ["one", "two"];

    if (score >= 8.0) {
      difficulty = "advanced";
      maxAttempts = 3;
      timeLimitSeconds = 60;
      targetWords = ["one", "five", "ten", "two", "three"];
    } else if (score >= 6.0) {
      difficulty = "intermediate";
      maxAttempts = 4;
      timeLimitSeconds = 60;
      targetWords = ["one", "two", "three", "four", "five"];
    } else {
      targetWords = ["one", "two"];
    }

    return {
      "stage": stage,
      "difficulty": difficulty,
      "maxAttempts": maxAttempts,
      "timeLimitSeconds": timeLimitSeconds,
      "targetWords": targetWords,
      "voiceProfileScore": profile.overallScore.toStringAsFixed(1),
      "voiceProfilePercentage": profile.overallPercentage.toStringAsFixed(0),
      "recommendedFeedback": _generateFeedback(profile),
    };
  }

  String _generateFeedback(VoiceProfile profile) {
    final List<String> tips = [];

    if (profile.phonemeAccuracy < 8.0) {
      tips.add("• Work on clearer pronunciation of difficult sounds.");
    }
    if (profile.pitch < 7.0) {
      tips.add("• Keep your tone steady.");
    }
    if (profile.loudness < 7.0) {
      tips.add("• Speak a bit louder.");
    }
    if (profile.voiceQuality < 6.5) {
      tips.add("• Try to relax your voice.");
    }
    if (profile.intelligibility < 7.0) {
      tips.add("• Pronounce words more clearly and separately.");
    }

    return tips.isEmpty
        ? "Great voice profile! Keep practicing every day."
        : tips.join("\n");
  }
}