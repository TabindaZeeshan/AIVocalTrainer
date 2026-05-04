import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_vocal_trainer/core/models/teacher_model.dart';
import 'package:ai_vocal_trainer/core/models/voice_profile.dart';
import 'learning_plan_page.dart';   

class CustomisedLearningPathPage extends StatelessWidget {
  final String className;
  final TeacherModel teacher;

  const CustomisedLearningPathPage({
    super.key,
    required this.className,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Customised Learning Path"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customised Learning Plans",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      className,
                      style: TextStyle(fontSize: 20, color: softPink, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .where('className', isEqualTo: className)
                      .where('teacherId', isEqualTo: teacher.userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: softPink));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final students = snapshot.data?.docs ?? [];

                    if (students.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 24),
                            const Text("No students found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Register students first", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final studentData = students[index].data() as Map<String, dynamic>;
                        final studentId = students[index].id;
                        final String name = studentData['name'] ?? 'Unknown';
                        final int? age = studentData['age'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
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
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: lightPinkBg,
                                child: Icon(Icons.person, size: 36, color: softPink),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                                    ),
                                    if (age != null)
                                      Text("$age years old", style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              
                              GestureDetector(
                                onTap: () => _viewStudentPlan(context, studentId, name, age),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: softPink.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "View Plan",
                                    style: TextStyle(
                                      color: softPink,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   void _viewStudentPlan(BuildContext context, String studentId, String studentName, int? age) {
    FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('learning_plans')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final planData = snapshot.docs.first.data();

            final voiceProfile = VoiceProfile.fromMap(planData);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LearningPlanPage(
                  studentName: studentName,
                  studentAge: age,
                  voiceProfile: voiceProfile,
                  studentId: studentId,
                  className: className,   // Now passing real className
                ),
              ),
            );
          } else {
            // No plan exists yet
            final defaultProfile = VoiceProfile(
              phonemeAccuracy: 5.0,
              pitch: 5.0,
              loudness: 5.0,
              voiceQuality: 5.0,
              intelligibility: 5.0,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LearningPlanPage(
                  studentName: studentName,
                  studentAge: age,
                  voiceProfile: defaultProfile,
                  studentId: studentId,
                  className: className,
                ),
              ),
            );
          }
        })
        .catchError((e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error loading plan: $e")),
            );
          }
        });
  }
}