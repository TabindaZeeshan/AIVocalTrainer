import 'package:flutter/material.dart';

class VocalEchoResultPage extends StatelessWidget {
  final String studentName;
  final List<String> targetWords;
  final int totalAttempts;
  final int correctAnswers;
  final List<Map<String, dynamic>> results;
  final String className;
  final String studentId;

  const VocalEchoResultPage({
    super.key,
    required this.studentName,
    required this.targetWords,
    required this.totalAttempts,
    required this.correctAnswers,
    required this.results,
    required this.className,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFF6B9D);
    final Color lightPinkBg = const Color(0xFFFFF0F5);

    final accuracy =
        targetWords.isEmpty ? 0 : (correctAnswers / targetWords.length) * 100;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Result"),
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
            children: [
              // 🟣 HEADER (same style theme)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Text(
                    "Great job, $studentName",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // 📊 STATS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _statCard("Words", targetWords.length.toString(), Icons.menu_book, softPink, lightPinkBg),
                    _statCard("Attempts", totalAttempts.toString(), Icons.mic, softPink, lightPinkBg),
                    _statCard("Correct", correctAnswers.toString(), Icons.check_circle, softPink, lightPinkBg),
                    _statCard("Accuracy", "${accuracy.toStringAsFixed(1)}%", Icons.star, softPink, lightPinkBg),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Detailed Results",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    final correct = item["correct"] == true;

                    return _resultCard(item, correct, softPink);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // BACK BUTTON (theme style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: softPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Back"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📦 STAT CARD (matching your theme)
  Widget _statCard(String title, String value, IconData icon, Color softPink, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bg,
            child: Icon(icon, color: softPink),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // 📄 RESULT CARD (matching theme style)
  Widget _resultCard(Map<String, dynamic> item, bool correct, Color softPink) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: correct ? Colors.green : Colors.red,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["word"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "You said: ${item["spoken"]}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Text(
            "${(item["score"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: softPink,
            ),
          ),
        ],
      ),
    );
  }
}