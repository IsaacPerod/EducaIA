import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/content_screen.dart';
import 'screens/study_screen.dart';
import 'screens/chat_screen.dart';
import 'services/auth_service.dart';
import 'services/content_api_service.dart';
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
  runApp(const EducaIAApp());
}

class EducaIAApp extends StatelessWidget {
  const EducaIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ContentApiService>(create: (_) => ContentApiService()),
      ],
      child: MaterialApp(
        title: 'EducaIA',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/content': (context) => ContentScreen(),
          '/study': (context) => const StudyScreen(),
          '/chat': (context) => ChatScreen(),
        },
      ),
    );
  }
}