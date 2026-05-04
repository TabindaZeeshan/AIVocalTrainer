import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStudentPage extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const EditStudentPage({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController studentIdController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.studentData['name'] ?? '');
    ageController = TextEditingController(text: widget.studentData['age']?.toString() ?? '');
    studentIdController = TextEditingController(text: widget.studentData['studentId'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  Future<void> _updateStudent() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Name cannot be empty"),
          backgroundColor: const Color(0xFFFF6B9D),   // ← Pink
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('students').doc(widget.studentId).update({
        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()) ?? widget.studentData['age'],
        'studentId': studentIdController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Student updated successfully!"),
            backgroundColor: const Color(0xFFFF6B9D),  
          ),
        );
        Navigator.pop(context, {
  'name': nameController.text.trim(),
  'age': int.tryParse(ageController.text.trim()),
  'studentId': studentIdController.text.trim(),
});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to update student"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Student"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
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
                        Icon(Icons.edit_rounded, size: 80, color: softPink),
                        const SizedBox(height: 20),
                        const Text("Editing Student", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          hintText: "e.g. Aisyah binti Rahman",
                          prefixIcon: Icon(Icons.person_outline, color: softPink),
                          filled: true,
                          fillColor: lightPinkBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Age",
                          hintText: "e.g. 6",
                          prefixIcon: Icon(Icons.cake_outlined, color: softPink),
                          filled: true,
                          fillColor: lightPinkBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: studentIdController,
                        decoration: InputDecoration(
                          labelText: "Student ID",
                          prefixIcon: Icon(Icons.badge_outlined, color: softPink),
                          filled: true,
                          fillColor: lightPinkBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _updateStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      elevation: 6,
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}