import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_student_page.dart';

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final String studentId;
  final String className;

  const StudentDetailPage({
    super.key,
    required this.studentData,
    required this.studentId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

    final String name = studentData['name'] ?? 'Unknown Student';
    final String studentIdDisplay = studentData['studentId'] ?? studentId;
    final int? age = studentData['age'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _navigateToEdit(context)),
          IconButton(icon: const Icon(Icons.delete_rounded), onPressed: () => _showDeleteConfirmation(context)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6D1),
              Color(0xFFFFD6E6),
              Color(0xFFFFF0F5),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 25, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 80, color: softPink),
                        const SizedBox(height: 20),
                        Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        Text("Class: $className", style: TextStyle(fontSize: 18, color: softPink, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),


                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.badge_outlined, "Student ID", studentIdDisplay),
                      const Divider(height: 35),
                      _buildDetailRow(Icons.person_outline, "Full Name", name),
                      const Divider(height: 35),
                      _buildDetailRow(Icons.cake_outlined, "Age", age != null ? "$age years old" : "Not provided"),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Progress for $name - Coming soon"),
                          backgroundColor: softPink,        
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      elevation: 6,
                    ),
                    child: const Text("View Progress", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 30),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) async {
  final updatedData = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditStudentPage(
        studentId: studentId,
        studentData: studentData,
      ),
    ),
  );

  if (updatedData != null) {
    studentData['name'] = updatedData['name'];
    studentData['age'] = updatedData['age'];
    studentData['studentId'] = updatedData['studentId'];

    (context as Element).markNeedsBuild(); 
  }
}

  void _showDeleteConfirmation(BuildContext context) {
    final String name = studentData['name'] ?? 'this student';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete $name?\nThis action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(studentId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student deleted successfully"),
            backgroundColor: const Color(0xFFFF6B9D),  
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete student"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}