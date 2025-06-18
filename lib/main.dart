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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF00B4D8), // Azul turquesa
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF00B4D8),
            secondary: const Color(0xFF90E0EF), // Verde menta
            surface: const Color(0xFFF8F9FA), // Branco
            onPrimary: Colors.white,
            onSecondary: Colors.black87,
            onSurface: Colors.black87,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B4D8)),
            headlineMedium: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFBE0B), // Amarelo suave
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00B4D8),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFE0E0E0), // Cinza claro
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          primarySwatch: Colors.cyan,
          useMaterial3: true, // Opcional, para Material 3
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/chat': (context) => ChatScreen(),
          '/study': (context) => const StudyScreen(),
          '/content': (context) => ContentScreen(),
        },
      ),
    );
  }
}
