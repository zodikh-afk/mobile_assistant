import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Імпорт ядра Firebase
import 'UI/login_screen.dart';
import 'business_logic/services/background_app_service.dart'; // Додали імпорт

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Ініціалізуємо конфігурацію фонового сервісу
  final bgService = BackgroundAppService();
  await bgService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Voice Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
