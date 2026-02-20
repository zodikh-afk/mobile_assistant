import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();

  void _handleLogin() async {
    final result = await _authService.loginUser(
      email: _emailController.text,
      password: _passController.text,
    );

    if (!mounted) return;

    if (result == "Успіх") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка входу: $result")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Вхід у систему")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Електронна пошта")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Пароль"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleLogin, child: const Text("Увійти")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
              child: const Text("Немає акаунта? Зареєструватися"),
            ),
          ],
        ),
      ),
    );
  }
}