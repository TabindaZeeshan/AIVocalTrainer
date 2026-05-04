import 'user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminModel extends UserModel {
  String? adminLevel;   

  AdminModel({
    required String userId,
    required String name,
    required String username,
    required String email,
    this.adminLevel,
  }) : super(
          userId: userId,
          name: name,
          username: username,
          email: email,
          userType: 'Admin',
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    if (adminLevel != null) {
      map['adminLevel'] = adminLevel;
    }
    return map;
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      adminLevel: map['adminLevel'],
    );
  }

  // ====================== Similar to ParentModel ======================

  static Future<AdminModel?> getAdmin() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return null;

      final doc = await db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return AdminModel.fromMap(doc.data()!);
    } catch (e) {
      print("Error in getAdmin: $e");
      return null;
    }
  }

  Future<void> saveAdmin() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection('users').doc(userId).set(
            toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print("Error in saveAdmin: $e");
      rethrow;
    }
  }

  Future<void> setAdmin({
    String? adminLevel,
  }) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final Map<String, dynamic> updates = {};

      if (adminLevel != null) updates['adminLevel'] = adminLevel;

      if (updates.isNotEmpty) {
        await db.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      print("Error in setAdmin: $e");
      rethrow;
    }
  }
}