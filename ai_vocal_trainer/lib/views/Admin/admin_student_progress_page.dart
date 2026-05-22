import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_student_progress_view.dart';

class AdminStudentProgressPage extends StatefulWidget {
  const AdminStudentProgressPage({super.key});

  @override
  State<AdminStudentProgressPage> createState() => _AdminStudentProgressPageState();
}

class _AdminStudentProgressPageState extends State<AdminStudentProgressPage> {
  final TextEditingController classController = TextEditingController();
  bool isSearching = false;

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void dispose() {
    classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("View Class Progress"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
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
                Text("Class Progress", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Enter class name to view all students", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: classController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Class Name",
                          hintText: "e.g. Class A",
                          prefixIcon: Icon(Icons.class_, color: softPink),
                          filled: true,
                          fillColor: lightPinkBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: softPink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                          onPressed: () => setState(() => isSearching = true),
                          child: const Text("Show All Students", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                if (isSearching)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .where('className', isEqualTo: classController.text.trim())
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text("No students found in '${classController.text.trim()}'", style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        );
                      }

                      final students = snapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${students.length} Students in ${classController.text.trim()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final data = students[index].data() as Map<String, dynamic>;
                              final studentId = students[index].id;
                              final studentName = data['name'] ?? 'Unknown';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminStudentProgressView(
                                        studentName: studentName,
                                        studentId: studentId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(backgroundColor: lightPinkBg, child: Icon(Icons.person, color: softPink)),
                                      const SizedBox(width: 18),
                                      Expanded(child: Text(studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                                      const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
}