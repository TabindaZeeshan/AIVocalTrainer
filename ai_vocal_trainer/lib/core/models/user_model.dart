import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String name;
  String username;
  String email;
  String userType;

  UserModel({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
    required this.userType,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'username': username,
      'email': email,
      'userType': userType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? '',
    );
  }

  bool get isTeacher => userType == 'Teacher';
  bool get isParent => userType == 'Parent';
  bool get isAdmin => userType == 'Admin';
}