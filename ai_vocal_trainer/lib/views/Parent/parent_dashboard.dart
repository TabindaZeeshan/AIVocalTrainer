import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../viewmodels/user_viewmodel.dart';
import '../../core/models/user_model.dart';
import '../User/profile_page.dart';
import 'student_progress_view.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final TextEditingController classController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();

  final UserViewModel _viewModel = UserViewModel();
  UserModel? parent;

  // Keep this if you still need it for other logic
  String? _currentStudentId;

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    final data = await _viewModel.getCurrentUserData();
    if (data is UserModel) {
      setState(() => parent = data);
    }
  }

  void _navigateToProfile() {
    if (parent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile is still loading...")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(user: parent!)),
    );
  }

  Future<void> _viewStudentProgress() async {
    final className = classController.text.trim();
    final studentId = studentIdController.text.trim();

    if (className.isEmpty || studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter both Class Name and Student ID"),
          backgroundColor: softPink,
        ),
      );
      return;
    }

    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (!studentDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student not found"), backgroundColor: Colors.red),
        );
        return;
      }

      final data = studentDoc.data() as Map<String, dynamic>;
      if (data['className']?.toString().trim() != className) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student is not in class '$className'"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final studentName = data['name'] ?? 'Student';

      setState(() => _currentStudentId = studentId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentProgressView(
            studentName: studentName,
            studentId: studentId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB6D1), Color(0xFFFFD6E6), Color(0xFFFFF0F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                Text(
                  parent?.name?.split(" ").first ?? "Parent",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Main Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: lightPinkBg,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.family_restroom_rounded,
                              size: 36,
                              color: softPink,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              "Check Student Progress",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: classController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Class Name",
                          hintText: "e.g. Class A",
                          prefixIcon: Icon(Icons.class_, color: softPink),
                          filled: true,
                          fillColor: lightPinkBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: studentIdController,
                        decoration: InputDecoration(
                          labelText: "Student ID",
                          hintText: "Enter Student ID",
                          prefixIcon: Icon(Icons.badge, color: softPink),
                          filled: true,
                          fillColor: lightPinkBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _viewStudentProgress,
                          child: const Text(
                            "View Progress",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    classController.dispose();
    studentIdController.dispose();
    super.dispose();
  }
}