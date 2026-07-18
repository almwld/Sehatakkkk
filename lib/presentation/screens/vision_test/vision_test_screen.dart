import 'package:flutter/material.dart';

class VisionTestScreen extends StatefulWidget {
  const VisionTestScreen({super.key});

  @override
  State<VisionTestScreen> createState() => _VisionTestScreenState();
}

class _VisionTestScreenState extends State<VisionTestScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _isFinished = false;

  final List<Map<String, dynamic>> _questions = [
    {'q': 'ما هو الرمز الذي تراه؟', 'ans': ['E', 'F', 'P', 'T'], 'correct': 0},
    {'q': 'اختر الحرف الصحيح', 'ans': ['L', 'O', 'V', 'E'], 'correct': 2},
    {'q': 'ما هو الرقم الذي تراه؟', 'ans': ['3', '5', '8', '9'], 'correct': 1},
  ];

  void _answer(int index) {
    if (_questions[_currentQuestion]['correct'] == index) {
      _score++;
    }
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار النظر'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isFinished
            ? _buildResult()
            : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentQuestion];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السؤال ${_currentQuestion + 1}/${_questions.length}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          q['q'],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        ...(q['ans'] as List).asMap().entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _answer(e.key),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,  // ✅ إصلاح: استخدام Colors.black87 بدلاً من AppColors.dark
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(
                e.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _score >= 3 ? Icons.check_circle : Icons.warning,
          size: 80,
          color: _score >= 3 ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 20),
        Text(
          'نتيجة الاختبار',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$_score من ${_questions.length}',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _score >= 3 ? 'رؤيتك جيدة ✅' : 'يُنصح بزيارة طبيب عيون 👁️',
          style: TextStyle(
            fontSize: 18,
            color: _score >= 3 ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentQuestion = 0;
              _score = 0;
              _isFinished = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          child: const Text('إعادة الاختبار'),
        ),
      ],
    );
  }
}
