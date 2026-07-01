import '../core/models/voice_profile.dart';

class RuleBasedSpeechTrainer {
  static const List<int> allNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  Map<String, dynamic> generateDynamicLearningPlan({
    required VoiceProfile profile,
    required List<Map<String, dynamic>> recentResults,
    int age = 5,
  }) {
    final weakNumbers = _extractWeakNumbers(recentResults);
    final targets = _getTargets(profile, weakNumbers);

    return {
      "overallScore": profile.overallScore.toStringAsFixed(1),
      "overallPercentage": profile.overallPercentage.toStringAsFixed(0),
      "recommendedFeedback": _generateOverallFeedback(profile, weakNumbers),
      "lastUpdated": DateTime.now().toIso8601String(),
      "weakAreas": weakNumbers,
      "activities": {
        "vocal_card_echo": _generateVocalCardEchoPlan(profile, targets),
        "number_pair_sequence": _generateNumberPairPlan(profile, targets),
        "number_counting_quest": _generateCountingQuestPlan(profile, targets, weakNumbers),
      },
    };
  }

  
  List<int> _getTargets(VoiceProfile profile, List<int> weakNumbers) {
    if (weakNumbers.isNotEmpty) return weakNumbers;
    if (profile.overallScore >= 8.0) return [1, 2, 3, 4, 5, 6, 7];
    if (profile.overallScore >= 6.5) return [1, 2, 3, 4, 5, 6, 7, 8, 9];
    return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  }

  
  Map<String, dynamic> _generateVocalCardEchoPlan(
    VoiceProfile profile,
    List<int> targets,
  ) {
    return {
      "stage": "Stage1_VocalCardEcho",
      "activityType": "vocal_card_echo",
      "difficulty": profile.overallScore >= 8.0
          ? "advanced"
          : profile.overallScore >= 6.0
              ? "intermediate"
              : "beginner",
      "maxAttempts": profile.overallScore >= 8.0 ? 3 : 5,
      "timeLimitSeconds": profile.overallScore >= 8.0 ? 60 : 75,
      "targetNumbers": targets,
      "targetWords": targets.map((n) => n.toString()).toList(),
    };
  }


  Map<String, dynamic> _generateNumberPairPlan(
    VoiceProfile profile,
    List<int> targets,
  ) {
    return {
      "stage": "Stage2_NumberPairSequence",
      "activityType": "number_pair_sequence",
      "difficulty": profile.overallScore >= 8.0
          ? "advanced"
          : profile.overallScore >= 6.0
              ? "intermediate"
              : "beginner",
      "maxAttempts": profile.overallScore >= 8.0 ? 2 : 4,
      "timeLimitSeconds": profile.overallScore >= 8.0 ? 55 : 70,
      "targetPairs": _generatePairs(targets),
      "targetNumbers": targets,
    };
  }


  Map<String, dynamic> _generateCountingQuestPlan(
    VoiceProfile profile,
    List<int> targets,
    List<int> weakNumbers,
  ) {
    
    final focusList = weakNumbers.isNotEmpty ? weakNumbers : targets;

    
    String difficulty;
    int maxAttempts;
    int timeLimit;

    if (profile.overallScore >= 8.0) {
      difficulty = "advanced";
      maxAttempts = 3;
      timeLimit = 100;
    } else if (profile.overallScore >= 6.0) {
      difficulty = "intermediate";
      maxAttempts = 4;
      timeLimit = 120;
    } else {
      difficulty = "beginner";
      maxAttempts = 5;
      timeLimit = 150;
    }

    return {
      "stage": "Stage3_NumberCountingQuest",
      "activityType": "number_counting_quest",
      "difficulty": difficulty,
      "maxAttempts": maxAttempts,
      "timeLimitSeconds": timeLimit,
      "targetRange": "${focusList.first}-${focusList.last}",
      "focusNumbers": focusList,
      "recommendedSequence": focusList, // For future use
    };
  }

 
  List<int> _extractWeakNumbers(List<Map<String, dynamic>> results) {
    Map<int, int> errorCount = {};

    for (var r in results) {
      String spoken = (r['spoken'] ?? '').toString().toLowerCase();
      double score = (r['score'] ?? 0.0).toDouble();
      bool correct = r['correct'] ?? false;

      for (int num in allNumbers) {
        if (spoken.contains(num.toString()) && (!correct || score < 0.65)) {
          errorCount[num] = (errorCount[num] ?? 0) + 1;
        }
      }
    }

    var sorted = errorCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).toList();
  }

  List<String> _generatePairs(List<int> numbers) {
    List<String> pairs = [];

    for (int i = 0; i < numbers.length - 1; i++) {
      pairs.add("${numbers[i]} - ${numbers[i + 1]}");
    }

    if (numbers.length >= 4) {
      pairs.add("${numbers[0]} - ${numbers[2]}");
      pairs.add("${numbers[1]} - ${numbers[3]}");
    }

    return pairs.toSet().toList();
  }

  String _generateOverallFeedback(
    VoiceProfile profile,
    List<int> weakNumbers,
  ) {
    if (weakNumbers.isNotEmpty) {
      return "Focus on: ${weakNumbers.join(", ")}";
    }
    return "Keep practicing!";
  }
}