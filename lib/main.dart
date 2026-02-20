import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Імпорт ядра Firebase
import 'screens/register_screen.dart'; // Твій файл з реєстрацією

void main() async {
  // 1. Це обов'язковий рядок для ініціалізації плагінів
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Ініціалізація Firebase
  
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
      home: RegisterScreen(), 
    );
  }
}