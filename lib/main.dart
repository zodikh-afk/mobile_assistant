import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Імпорт ядра Firebase
import 'UI/register_screen.dart'; // Твій файл з реєстрацією
import 'UI/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        useMaterial3: true, // Сучасний дизайн Android
      ),
      // Вказуємо екран реєстрації як стартовий
      home: const LoginScreen(),
    );
  }
}
