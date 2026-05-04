import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_vocal_trainer/core/models/teacher_model.dart';
import 'student_practice_activites_page.dart';

class InstructiveExercisesPage extends StatelessWidget {
  final String className;
  final TeacherModel teacher;

  const InstructiveExercisesPage({
    super.key,
    required this.className,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Instructive Exercises"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      className,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: softPink),
                    ),
                    const Text(
                      "Choose a student to practice",
                      style: TextStyle(fontSize: 17, color: Colors.grey),
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No students registered yet", style: TextStyle(fontSize: 18)),
                      );
                    }

                    final students = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final data = students[index].data() as Map<String, dynamic>;
                        final String studentName = data['name'] ?? 'Unknown';
                        final String studentId = students[index].id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFFFF0F5),
                                child: Icon(Icons.person, color: softPink, size: 32),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  studentName,
                                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _fetchPlanAndNavigate(context, studentId, studentName, className),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: softPink,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("Practice"),
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

  // Proper fetching - exactly like CustomisedLearningPathPage
  Future<void> _fetchPlanAndNavigate(
    BuildContext context,
    String studentId,
    String studentName,
    String className,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('learning_plans')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final planData = snapshot.docs.first.data();

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentPracticeActivitiesPage(
                studentName: studentName,
                studentId: studentId,
                className: className,
                learningPlan: planData,   // Real fetched plan
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No learning plan found. Generate one first from Learning Plan."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print("Error fetching learning plan: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load learning plan")),
        );
      }
    }
  }
}