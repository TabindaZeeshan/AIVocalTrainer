import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_vocal_trainer/core/models/teacher_model.dart';
import 'student_detail_page.dart';
import 'register_student_page.dart';

class ViewRegisteredStudentsPage extends StatelessWidget {
  final String className;
  final TeacherModel teacher;

  const ViewRegisteredStudentsPage({
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
        title: Text("Students - $className"),
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
                      Icon(Icons.people_outline, size: 90, color: Colors.grey[400]),
                      const SizedBox(height: 24),
                      const Text(
                        "No students registered yet",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Let's add some students to your class!",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () {
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegisterStudentPage(
                                className: className,
                                teacher: teacher,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text("Register Students Now"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                );
              }

             
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final studentData = students[index].data() as Map<String, dynamic>;
                  final docId = students[index].id;
                  final String name = studentData['name'] ?? 'Unknown Student';

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
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSmallButton(
                              icon: Icons.info_outline,
                              label: "Details",
                              color: softPink,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentDetailPage(
                                      studentData: studentData,
                                      studentId: docId,
                                      className: className,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildSmallButton(
                              icon: Icons.trending_up,
                              label: "Progress",
                              color: softPink,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Progress for $name - Coming soon"),
                                    backgroundColor: softPink,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}