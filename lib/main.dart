import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/content_screen.dart';
import 'screens/study_screen.dart';
import 'screens/chat_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCp4iuohhFOtEGBe5hhvOSZlQDlMwyL9LM",
        authDomain: "educaia-c5064.firebaseapp.com",
        projectId: "educaia-c5064",
        storageBucket: "educaia-c5064.firebasestorage.app",
        messagingSenderId: "736887639270",
        appId: "1:736887639270:web:533f533667ecd33735bf27",
        measurementId: "G-21B2NN9RC3",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Popular contents
  await populateContents();

  runApp(const EducaIAApp());
}

Future<void> populateContents() async {
  final firestore = FirebaseFirestore.instance;
  final contents = [
    {
      'id': 'python101',
      'title': 'Introdução ao Python',
      'type': 'video',
      'difficulty': 'beginner',
      'url': 'https://www.youtube.com/watch?v=rfscVS0vtbw',
      'topics': ['Python', 'Programação'],
    },
    {
      'id': 'python201',
      'title': 'Funções em Python',
      'type': 'article',
      'difficulty': 'intermediate',
      'url': 'https://realpython.com/defining-your-own-python-function/',
      'topics': ['Python', 'Programação'],
    },
    {
      'id': 'python301',
      'title': 'Programação Orientada a Objetos em Python',
      'type': 'video',
      'difficulty': 'advanced',
      'url': 'https://www.youtube.com/watch?v=Ej_02ICOIgs',
      'topics': ['Python', 'Programação'],
    },
    {
      'id': 'math101',
      'title': 'Introdução à Álgebra',
      'type': 'video',
      'difficulty': 'beginner',
      'url': 'https://www.youtube.com/watch?v=LwCRRUa8yTU',
      'topics': ['Matemática'],
    },
    {
      'id': 'math201',
      'title': 'Cálculo Diferencial',
      'type': 'article',
      'difficulty': 'intermediate',
      'url': 'https://www.khanacademy.org/math/calculus-1',
      'topics': ['Matemática'],
    },
    {
      'id': 'math301',
      'title': 'Álgebra Linear Avançada',
      'type': 'video',
      'difficulty': 'advanced',
      'url': 'https://www.youtube.com/watch?v=8o5Cmfpeo6g',
      'topics': ['Matemática'],
    },
    {
      'id': 'logic101',
      'title': 'Lógica para Iniciantes',
      'type': 'article',
      'difficulty': 'beginner',
      'url': 'https://www.intrologic.com/what-is-logic/',
      'topics': ['Lógica'],
    },
    {
      'id': 'logic201',
      'title': 'Tabelas Verdade',
      'type': 'video',
      'difficulty': 'intermediate',
      'url': 'https://www.youtube.com/watch?v=Ln2pvEPVTK0',
      'topics': ['Lógica'],
    },
    {
      'id': 'logic301',
      'title': 'Lógica Formal Avançada',
      'type': 'article',
      'difficulty': 'advanced',
      'url': 'https://plato.stanford.edu/entries/logic-classical/',
      'topics': ['Lógica'],
    },
  ];

  for (var content in contents) {
    final docRef =
        firestore.collection('contents').doc(content['id'] as String);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      await docRef.set({
        'title': content['title'],
        'type': content['type'],
        'difficulty': content['difficulty'],
        'url': content['url'],
        'topics': content['topics'],
      });
      print('Conteúdo adicionado: ${content['id']}');
    } else {
      print('Conteúdo já existe: ${content['id']}');
    }
  }
}

class EducaIAApp extends StatelessWidget {
  const EducaIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'EducaIA',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => CadastroScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/recommendations': (context) => RecommendationsScreen(),
          '/content': (context) => ContentScreen(),
          '/study': (context) => StudyScreen(),
          '/chat': (context) => ChatScreen(),
        },
      ),
    );
  }
}
