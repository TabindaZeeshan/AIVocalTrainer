import 'user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherModel extends UserModel {
  String gradeLevel;
  String gradeName;
  List<String> classes;

  TeacherModel({
    required String userId,
    required String name,
    required String username,
    required String email,
    required this.gradeLevel,
    required this.gradeName,
    List<String>? classes,
  })  : classes = classes ?? [],
        super(
          userId: userId,
          name: name,
          username: username,
          email: email,
          userType: 'Teacher',
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'gradeLevel': gradeLevel,
      'gradeName': gradeName,
      'classes': classes,
    });
    return map;
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      gradeLevel: map['gradeLevel'] ?? 'Kindergarten',
      gradeName: map['gradeName'] ?? '',
      classes: List<String>.from(map['classes'] ?? []),
    );
  }


  static Future<TeacherModel?> getTeacher() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;   

      if (user == null) return null;

      final doc = await db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return TeacherModel.fromMap(doc.data()!);
    } catch (e) {
      print("Error in getTeacher: $e");
      return null;
    }
  }


  Future<void> saveTeacher() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection('users').doc(userId).set(
            toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print("Error in saveTeacher: $e");
      rethrow;
    }
  }

  Future<void> setTeacher({
    String? gradeName,
    List<String>? classes,
  }) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final Map<String, dynamic> updates = {};

      if (gradeName != null) updates['gradeName'] = gradeName;
      if (classes != null) updates['classes'] = classes;

      if (updates.isNotEmpty) {
        await db.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      print("Error in setTeacher: $e");
      rethrow;
    }
  }

 
  void addClass(String className) {
    if (!classes.contains(className)) {
      classes.add(className);
    }
  }
}