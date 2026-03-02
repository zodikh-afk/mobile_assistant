import 'package:flutter/material.dart';
import '../controllers/auth_service.dart';
import 'home_screen.dart'; // Додано для переходу після реєстрації
import '../controllers/connectivity_controller.dart';
import '../controllers/input_validator_controller.dart';

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
  final ConnectivityController _connectivity = ConnectivityController();
  final InputValidatorController _validator = InputValidatorController();

  bool _isLoading = false;

  void _handleRegister() async {
    // 1. Збираємо текст з полів
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final username = _userController.text.trim();

    // 2. Валідація введених даних
    final emailError = _validator.validateEmail(email);
    final passError = _validator.validatePassword(password);
    final userError = _validator.validateUsername(username);

    // Якщо є хоч одна помилка, показуємо її і зупиняємо процес
    if (emailError != null || passError != null || userError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userError ?? emailError ?? passError!)),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Перевірка підключення до мережі
    bool hasInternet = await _connectivity.hasInternetConnection();
    if (!hasInternet) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Відсутнє підключення до інтернету. Перевірте мережу.")),
      );
      return;
    }

    // 4. Якщо все добре, реєструємо через Firebase
    final result = await _authService.registerUser(
      email: email,
      password: password,
      username: username,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "Успіх") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ви успішно зареєстровані!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
          mainAxisAlignment: MainAxisAlignment.center, // Центруємо елементи
          children: [
            TextField(
                controller: _userController,
                decoration:
                    const InputDecoration(labelText: "Логін (Username)")),
            TextField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: "Електронна пошта")),
            TextField(
                controller: _passController,
                decoration: const InputDecoration(labelText: "Пароль"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _handleRegister,
                child: const Text("Створити акаунт")),
            const SizedBox(height: 10),
            // Кнопка для повернення назад до логіну
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Вже є акаунт? Увійти"),
            ),
          ],
        ),
      ),
    );
  }
}
