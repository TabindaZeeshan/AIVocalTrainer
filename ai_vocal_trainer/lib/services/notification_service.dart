import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<void> sendPracticeCompletedNotification({
    required String studentId,
    required String studentName,
    required String activityType,
  }) async {
    try {
      String formattedActivity = _formatActivity(activityType);

      await FirebaseFirestore.instance.collection('notifications').add({
        'studentId': studentId,
        'studentName': studentName,
        'title': 'Practice Completed ✓',
        'body': '$studentName successfully completed $formattedActivity',
        'type': 'practice_completed',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Notification Error: $e");
    }
  }

  static String _formatActivity(String type) {
    switch (type) {
      case 'vocal_card_echo':
        return 'Vocal Card Echo';
      case 'number_pair_sequence':
        return 'Number Pair Sequence';
      case 'number_counting_quest':
        return 'Number Counting Quest';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }
}