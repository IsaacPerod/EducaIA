import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _currentQuestion = 0;
  int? _selectedOption;
  List<Map<String, dynamic>> _filteredQuestions = [];
  bool _isLoading = true;
  String? _errorMessage;
  final List<String> _interests = ['Python', 'Matemática', 'Lógica'];

  final List<Map<String, dynamic>> _questions = [
    // Python
    {
      'question': 'O que é uma variável em Python?',
      'options': ['Um loop', 'Um valor armazenado', 'Uma função'],
      'correct': 1,
      'topic': 'Python',
    },
    {
      'question': 'Qual é a sintaxe correta para um if em Python?',
      'options': ['if x = 5:', 'if x == 5:', 'if x 5:'],
      'correct': 1,
      'topic': 'Python',
    },
    {
      'question': 'O que faz print("Hello") em Python?',
      'options': ['Exibe Hello', 'Salva Hello', 'Cria uma variável'],
      'correct': 0,
      'topic': 'Python',
    },
    // Matemática
    {
      'question': 'Qual é o valor de 2 + 2 * 3?',
      'options': ['12', '8', '10'],
      'correct': 1,
      'topic': 'Matemática',
    },
    {
      'question': 'O que é um número primo?',
      'options': [
        'Um número divisível por 1 e ele mesmo',
        'Um número par',
        'Um número divisível por 3'
      ],
      'correct': 0,
      'topic': 'Matemática',
    },
    {
      'question': 'Qual é a derivada de x²?',
      'options': ['2x', 'x', 'x²'],
      'correct': 0,
      'topic': 'Matemática',
    },
    // Lógica
    {
      'question': 'O que é uma proposição lógica?',
      'options': [
        'Uma equação matemática',
        'Uma afirmação que pode ser verdadeira ou falsa',
        'Um loop'
      ],
      'correct': 1,
      'topic': 'Lógica',
    },
    {
      'question': 'Qual é o resultado de A ∧ ¬A?',
      'options': ['Verdadeiro', 'Falso', 'Indeterminado'],
      'correct': 1,
      'topic': 'Lógica',
    },
    {
      'question': 'O que é um silogismo?',
      'options': [
        'Um tipo de variável',
        'Um argumento lógico com premissas e conclusão',
        'Uma função'
      ],
      'correct': 1,
      'topic': 'Lógica',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInterest();
  }

  Future<void> _loadUserInterest() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      print('User UID: ${user.uid}');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _errorMessage = 'Documento do usuário não encontrado';
          _isLoading = false;
        });
        return;
      }

      final interests = userDoc.data()?['interests'] as List<dynamic>?;
      print('Interesses: $interests');

      if (interests != null && interests.isNotEmpty) {
        final interest = interests[0] as String;
        if (_interests.contains(interest)) {
          setState(() {
            _filteredQuestions = _questions
                .where((question) => question['topic'] == interest)
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Interesse inválido: $interest';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Nenhum interesse encontrado';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar interesse: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar interesse: $e';
        _isLoading = false;
      });
    }
  }

  void _answer(int selected) {
    if (_filteredQuestions.isEmpty) return;

    setState(() {
      _selectedOption = selected;
    });

    if (selected == _filteredQuestions[_currentQuestion]['correct']) {
      _score++;
    }
    if (_currentQuestion < _filteredQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (_filteredQuestions.isEmpty) {
      Navigator.pushReplacementNamed(context, '/recommendations');
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final level = _score <= 1
        ? 'beginner'
        : _score == 2
            ? 'intermediate'
            : 'advanced';

    final answers = _filteredQuestions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      return {
        'question': question['question'],
        'topic': question['topic'],
        'difficulty': level,
        'correct': _selectedOption == question['correct'],
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('histories')
        .doc('quiz${DateTime.now().millisecondsSinceEpoch}')
        .set({
      'answers': answers,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'level': level});

    Navigator.pushReplacementNamed(context, '/recommendations');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Inicial')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_filteredQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Inicial')),
        body: const Center(
            child: Text('Nenhuma questão disponível para o interesse')),
      );
    }

    final question = _filteredQuestions[_currentQuestion];
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Inicial')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(question['question'], style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ...question['options'].asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return RadioListTile<int>(
                value: index,
                groupValue: _selectedOption,
                onChanged: (value) {
                  print('Selecionado: $value');
                  _answer(value!);
                },
                title: Text(option),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
