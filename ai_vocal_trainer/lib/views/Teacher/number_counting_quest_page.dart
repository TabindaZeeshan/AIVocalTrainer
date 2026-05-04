import 'package:flutter/material.dart';

class NumberCountingQuestPage extends StatefulWidget {
  final String studentName;

  const NumberCountingQuestPage({
    super.key,
    required this.studentName,
  });

  @override
  State<NumberCountingQuestPage> createState() =>
      _NumberCountingQuestPageState();
}

class _NumberCountingQuestPageState extends State<NumberCountingQuestPage> {
  final Color softPink = const Color(0xFFFF6B9D);

  int level = 0; // 0 = 1-3, 1 = 1-5, 2 = 1-10

  int attemptsLeft = 4;
  int timeLeft = 90;

  List<int> get numberSequence {
    if (level == 0) return [1, 2, 3];
    if (level == 1) return [1, 2, 3, 4, 5];
    return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  }

  String get levelTitle {
    if (level == 0) return "Beginner Quest";
    if (level == 1) return "Intermediate Quest";
    return "Advanced Quest";
  }

  String get levelRule {
    if (level == 0) return "4 attempts • 90 seconds";
    if (level == 1) return "3 attempts • 90 seconds";
    return "2 attempts • 120 seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Number Counting Quest"),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 🟣 HEADER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    children: [
                      Text(
                        "Hello ${widget.studentName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        levelTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: softPink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        levelRule,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 📊 LEVEL SELECTOR
                Row(
                  children: [
                    _levelButton("1–3", 0),
                    const SizedBox(width: 10),
                    _levelButton("1–5", 1),
                    const SizedBox(width: 10),
                    _levelButton("1–10", 2),
                  ],
                ),

                const SizedBox(height: 20),

                // ⏱ TIMER + ATTEMPTS
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        "Time Left",
                        "$timeLeft sec",
                        Icons.timer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        "Attempts",
                        "$attemptsLeft left",
                        Icons.refresh,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔢 NUMBER SEQUENCE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: numberSequence
                        .map(
                          (n) => CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFFFF0F5),
                            child: Text(
                              "$n",
                              style: TextStyle(
                                color: softPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // 🎤 ACTION BUTTON
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic),
                  label: const Text("Start Counting"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softPink,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Speak the numbers clearly in order",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 LEVEL BUTTON
  Widget _levelButton(String text, int index) {
    final bool selected = level == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            level = index;

            if (level == 0) {
              attemptsLeft = 4;
              timeLeft = 90;
            } else if (level == 1) {
              attemptsLeft = 3;
              timeLeft = 90;
            } else {
              attemptsLeft = 2;
              timeLeft = 120;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? softPink : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              )
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 📦 INFO CARD
  Widget _infoCard(String title, String value, IconData icon) {
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
            backgroundColor: const Color(0xFFFFF0F5),
            child: Icon(icon, color: softPink),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}