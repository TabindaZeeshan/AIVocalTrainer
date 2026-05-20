import 'package:ai_vocal_trainer/views/Teacher/customised_learning_path_page.dart';


import 'package:flutter/material.dart';
import 'package:ai_vocal_trainer/core/models/teacher_model.dart';
import 'package:ai_vocal_trainer/views/Teacher/register_student_page.dart';
import 'view_registered_students_page.dart';   
import 'voice_recording_page.dart';
import 'instructive_exercises_page.dart';
import 'progress_tracking_page.dart';

class ClassDetailPage extends StatelessWidget {
  final String className;
  final TeacherModel teacher;

  const ClassDetailPage({
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
        title: Text(className),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                Text(
                  "Hi, you're all set to start teaching!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  className,
                  style: TextStyle(
                    fontSize: 22,
                    color: softPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Teacher: ${teacher.name}",
                  style: const TextStyle(fontSize: 17, color: Colors.black54),
                ),
                const SizedBox(height: 40),

             
                _buildFeatureButton(
                  icon: Icons.person_add_rounded,
                  title: "Student Registration",
                  subtitle: "Add new students to this class",
                  color: softPink,
                  lightPinkBg: lightPinkBg,
                  onTap: () {
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
                ),
                const SizedBox(height: 16),

            
                _buildFeatureButton(
                  icon: Icons.people_rounded,
                  title: "View Registered Students",
                  subtitle: "See all students in this class",
                  color: softPink,
                  lightPinkBg: lightPinkBg,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewRegisteredStudentsPage(
                          className: className,
                          teacher: teacher,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildFeatureButton(
                  icon: Icons.mic_rounded,
                  title: "Voice Recording",
                  subtitle: "Record and analyze student pronunciation",
                  color: softPink,
                  lightPinkBg: lightPinkBg,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceRecordingPage(
                          className: className,
                          teacher: teacher,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

   
               _buildFeatureButton(
  icon: Icons.psychology_rounded,
  title: "Customised Learning Path",
  subtitle: "View personalized lessons for students",
  color: softPink,
  lightPinkBg: lightPinkBg,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomisedLearningPathPage(
          className: className,
          teacher: teacher,
        ),
      ),
    );
  },
),
                const SizedBox(height: 16),

                // Instructive Exercises - NOW PROPERLY LINKED
                _buildFeatureButton(
                  icon: Icons.assignment_rounded,
                  title: "Instructive Exercises",
                  subtitle: "Interactive speaking and listening exercises",
                  color: softPink,
                  lightPinkBg: lightPinkBg,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InstructiveExercisesPage(
                          className: className,
                          teacher: teacher,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),

                _buildFeatureButton(
                  icon: Icons.trending_up_rounded,
                  title: "Progress Tracking",
                  subtitle: "Monitor student improvement over time",
                  color: softPink,
                  lightPinkBg: lightPinkBg,
                  onTap: () {
                    Navigator.push(
                      context,
                         MaterialPageRoute(
                          builder: (_) => ProgressTrackingPage(
                           className: className,
                        )
                      )
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color lightPinkBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightPinkBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}