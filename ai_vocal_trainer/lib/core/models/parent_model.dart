import 'user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentModel extends UserModel {
  List<String> childrenIds;  

  ParentModel({
    required String userId,
    required String name,
    required String username,
    required String email,
    List<String>? childrenIds,
  })  : childrenIds = childrenIds ?? [],
        super(
          userId: userId,
          name: name,
          username: username,
          email: email,
          userType: 'Parent',
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'childrenIds': childrenIds,
    });
    return map;
  }

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      childrenIds: List<String>.from(map['childrenIds'] ?? []),
    );
  }

  static Future<ParentModel?> getParent() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return null;

      final doc = await db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return ParentModel.fromMap(doc.data()!);
    } catch (e) {
      print("Error in getParent: $e");
      return null;
    }
  }


  Future<void> saveParent() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection('users').doc(userId).set(
            toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print("Error in saveParent: $e");
      rethrow;
    }
  }


  Future<void> setParent({
    List<String>? childrenIds,
  }) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final Map<String, dynamic> updates = {};

      if (childrenIds != null) updates['childrenIds'] = childrenIds;

      if (updates.isNotEmpty) {
        await db.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      print("Error in setParent: $e");
      rethrow;
    }
  }
}