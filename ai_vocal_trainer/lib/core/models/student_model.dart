// lib/core/models/student_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String studentId;
  final String name;
  final int age;
  final String className;
  final String teacherId;
  final DateTime createdAt;

  StudentModel({
    required this.studentId,
    required this.name,
    required this.age,
    required this.className,
    required this.teacherId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'age': age,
      'className': className,
      'teacherId': teacherId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      age: (map['age'] ?? 0) as int,
      className: map['className'] ?? '',
      teacherId: map['teacherId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}