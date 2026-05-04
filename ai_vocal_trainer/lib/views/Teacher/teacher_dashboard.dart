import 'package:ai_vocal_trainer/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../core/models/teacher_model.dart';
import 'class_detail_page.dart';
import '../User/profile_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final UserViewModel _viewModel = UserViewModel();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  TeacherModel? teacher;
  List<String> classes = [];

  bool isLoading = true;
  String? errorMessage;

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final data = await _viewModel.getCurrentUserData();

    if (data is TeacherModel) {
      setState(() {
        teacher = data;
      
        classes = List<String>.from(teacher!.classes);
      });
      await _loadClasses(); 
    } else {
      errorMessage = "Access denied. Only teachers can access this dashboard.";
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadClasses() async {
    if (teacher == null) return;

    try {
      final doc = await _db.collection('users').doc(teacher!.userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data.containsKey('classes')) {
          setState(() {
            classes = List<String>.from(data['classes'] ?? []);
         
            teacher!.classes = classes;
          });
        }
      }
    } catch (e) {
      print("Error loading classes: $e");
    }
  }

  Future<void> _saveClasses() async {
    if (teacher == null) return;

    try {
      await _db.collection('users').doc(teacher!.userId).update({'classes': classes});
      
      teacher!.classes = List<String>.from(classes);
    } catch (e) {
      await _db.collection('users').doc(teacher!.userId).set(
            {'classes': classes},
            SetOptions(merge: true),
          );
      teacher!.classes = List<String>.from(classes);
    }
  }

  void _showCreateClassDialog() {
    final classNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: lightPinkBg, shape: BoxShape.circle),
              child: Icon(Icons.add_circle_outline_rounded, size: 60, color: softPink),
            ),
            const SizedBox(height: 20),
            const Text("Create New Class", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: classNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Class Name",
            hintText: "e.g. Class A, Morning Session, Yellow Group",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            filled: true,
            fillColor: lightPinkBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final className = classNameController.text.trim();
              if (className.isNotEmpty && !classes.contains(className)) {
                setState(() => classes.add(className));
                await _saveClasses();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Class '$className' created successfully!"), backgroundColor: softPink),
                );
                Navigator.pop(context);
              } else if (classes.contains(className)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This class already exists")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: softPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Create Class"),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    if (teacher == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(user: teacher!)),
    ).then((_) => _loadTeacherData());   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: _navigateToProfile,
            tooltip: "My Profile",
          ),
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : errorMessage != null
                  ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 18)))
                  : teacher == null
                      ? const Center(child: Text("Loading..."))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome,", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.95))),
                              Text(teacher!.name.split(" ").first, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 40),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Your Classes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (classes.isEmpty)
                                GestureDetector(
                                  onTap: _showCreateClassDialog,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.school_outlined, size: 80, color: softPink.withOpacity(0.7)),
                                        const SizedBox(height: 20),
                                        const Text("No classes yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text("Tap here to create your first class", style: TextStyle(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: classes.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                           builder: (_) => ClassDetailPage(
                                            className: classes[index],
                                              teacher: teacher!,        
                                            ),
                                          ),
                                        ),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(color: lightPinkBg, borderRadius: BorderRadius.circular(20)),
                                              child: Icon(Icons.school_rounded, color: softPink, size: 32),
                                            ),
                                            const SizedBox(width: 18),
                                            Expanded(child: Text(classes[index], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
                                            Icon(Icons.arrow_forward_ios_rounded, color: softPink, size: 22),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              const SizedBox(height: 40),

                              if (classes.isNotEmpty)
                                GestureDetector(
                                  onTap: _showCreateClassDialog,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    decoration: BoxDecoration(
                                      color: softPink,
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [BoxShadow(color: softPink.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.white, size: 28),
                                        SizedBox(width: 12),
                                        Text("Create Another Class", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
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