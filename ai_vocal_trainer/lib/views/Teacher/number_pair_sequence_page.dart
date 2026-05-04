import 'package:flutter/material.dart';

class NumberPairSequencePage extends StatefulWidget {
  final String studentName;

  const NumberPairSequencePage({
    super.key,
    required this.studentName,
  });

  @override
  State<NumberPairSequencePage> createState() =>
      _NumberPairSequencePageState();
}

class _NumberPairSequencePageState extends State<NumberPairSequencePage> {
  final Color softPink = const Color(0xFFFF6B9D);

  final List<String> simplePairs = [
    "one - two",
    "two - three",
  ];

  final List<String> moderatePairs = [
    "three - four",
    "five - six",
  ];

  final List<String> hardPairs = [
    "five - ten",
    "one - seven",
  ];

  int level = 0; // 0 = simple, 1 = moderate, 2 = hard

  List<String> get currentPairs {
    if (level == 0) return simplePairs;
    if (level == 1) return moderatePairs;
    return hardPairs;
  }

  String get levelTitle {
    if (level == 0) return "Simple Pairs";
    if (level == 1) return "Moderate Pairs";
    return "Advanced Pairs";
  }

  String get levelRule {
    if (level == 0)
      return "4 attempts • 75 seconds";
    if (level == 1)
      return "3 attempts • 60 seconds";
    return "2 attempts • 60 seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Number Pair Sequence"),
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
                // 🟣 HEADER
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
                          color: softPink,
                          fontWeight: FontWeight.w600,
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

                // 📊 LEVEL BUTTONS
                Row(
                  children: [
                    _levelButton("Easy", 0),
                    const SizedBox(width: 10),
                    _levelButton("Medium", 1),
                    const SizedBox(width: 10),
                    _levelButton("Hard", 2),
                  ],
                ),

                const SizedBox(height: 20),

                // 📦 PAIR LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: currentPairs.length,
                    itemBuilder: (context, index) {
                      return _pairCard(currentPairs[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 LEVEL BUTTON
  Widget _levelButton(String title, int index) {
    final bool selected = level == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            level = index;
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
            title,
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

  // 📦 PAIR CARD
  Widget _pairCard(String pair) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF0F5),
            child: Icon(Icons.record_voice_over, color: softPink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pair,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.play_arrow, color: softPink),
        ],
      ),
    );
  }
}