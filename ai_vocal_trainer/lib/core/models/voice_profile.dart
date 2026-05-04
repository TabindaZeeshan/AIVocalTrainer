// lib/core/models/voice_profile.dart

class VoiceProfile {
  final double phonemeAccuracy;   // 0-10
  final double pitch;             // 0-10
  final double loudness;          // 0-10
  final double voiceQuality;      // 0-10
  final double intelligibility;   // 0-10
  final Map<String, double> weakPhonemes;

  final double overallScore;       // Average score out of 10
  final double overallPercentage;  // 0-100 for display

  VoiceProfile({
    required this.phonemeAccuracy,
    required this.pitch,
    required this.loudness,
    required this.voiceQuality,
    required this.intelligibility,
    this.weakPhonemes = const {},
  })  : overallScore = (phonemeAccuracy + pitch + loudness + voiceQuality + intelligibility) / 5,
        overallPercentage = ((phonemeAccuracy + pitch + loudness + voiceQuality + intelligibility) / 5) * 10;

  // Factory to recreate exact same profile from Firestore data
  factory VoiceProfile.fromMap(Map<String, dynamic> map) {
    return VoiceProfile(
      phonemeAccuracy: (map['phonemeAccuracy'] ?? 5.0).toDouble(),
      pitch: (map['pitch'] ?? 5.0).toDouble(),
      loudness: (map['loudness'] ?? 5.0).toDouble(),
      voiceQuality: (map['voiceQuality'] ?? 5.0).toDouble(),
      intelligibility: (map['intelligibility'] ?? 5.0).toDouble(),
      weakPhonemes: Map<String, double>.from(map['weakPhonemes'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phonemeAccuracy': phonemeAccuracy,
      'pitch': pitch,
      'loudness': loudness,
      'voiceQuality': voiceQuality,
      'intelligibility': intelligibility,
      'weakPhonemes': weakPhonemes,
      'overallScore': overallScore,
      'overallPercentage': overallPercentage,
    };
  }
}