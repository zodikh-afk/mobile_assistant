import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _userController = TextEditingController();
  final AuthService _authService = AuthService();

void _handleRegister() async {
  final result = await _authService.registerUser(
    email: _emailController.text,
    password: _passController.text,
    username: _userController.text,
  );

  // Перевірка, чи екран ще існує (щоб не було помилок з context)
  if (!mounted) return;

  if (result == "Успіх") {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ви зареєстровані!")),
    );
    // Тут логіка переходу на головний екран
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Помилка: $result")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Хмарна Реєстрація")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Логін (Username)")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Електронна пошта")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Пароль"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleRegister, child: const Text("Створити акаунт")),
          ],
        ),
      ),
    );
  }
}