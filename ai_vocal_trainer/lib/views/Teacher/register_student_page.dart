import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/teacher_model.dart';

class RegisterStudentPage extends StatefulWidget {
  final String className;
  final TeacherModel teacher;

  const RegisterStudentPage({
    super.key,
    required this.className,
    required this.teacher,
  });

  @override
  State<RegisterStudentPage> createState() => _RegisterStudentPageState();
}

class _RegisterStudentPageState extends State<RegisterStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _studentIdController = TextEditingController();

  bool _isLoading = false;

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();

    _studentIdController.text = _generateStudentId();
  }

  String _generateStudentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
    final classPrefix = widget.className
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase()
        .substring(0, 3);
    return "$classPrefix$timestamp";
  }

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final student = StudentModel(
        studentId: _studentIdController.text.trim(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        className: widget.className,
        teacherId: widget.teacher.userId,
      );

      final db = FirebaseFirestore.instance;

      await db.collection('students').doc(student.studentId).set(student.toMap());

      
      await db.collection('users').doc(widget.teacher.userId).set({
        'classes': {
          widget.className: {
            'students': FieldValue.arrayUnion([student.studentId]),
          }
        }
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.name} has been registered successfully!'),
            backgroundColor: softPink,
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Register Student"),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.person_add_rounded, size: 72, color: softPink),
                          const SizedBox(height: 16),
                          const Text(
                            "Adding student to",
                            style: TextStyle(fontSize: 17, color: Colors.grey),
                          ),
                          Text(
                            widget.className,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: softPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                 
                  _buildInputField(
                    controller: _nameController,
                    label: "Student's Full Name",
                    hint: "e.g. Aisyah binti Rahman",
                    icon: Icons.person_outline,
                    validator: (v) => v!.trim().isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _ageController,
                    label: "Age",
                    hint: "e.g. 5",
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.trim().isEmpty) return "Age is required";
                      final age = int.tryParse(v);
                      if (age == null || age < 3 || age > 12) {
                        return "Age must be 3–12 years";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _studentIdController,
                    label: "Student ID",
                    hint: "Auto-generated",
                    icon: Icons.badge_outlined,
                    validator: (v) => v!.trim().isEmpty ? "Student ID required" : null,
                  ),

                  const SizedBox(height: 50),

                  
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: softPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 6,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Register Student",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: softPink),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}