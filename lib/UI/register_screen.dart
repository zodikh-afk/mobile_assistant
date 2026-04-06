import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../controllers/connectivity_controller.dart';
import '../controllers/input_validator_controller.dart';
import '../controllers/auth_controller.dart';

import '../domain/view_models/register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _userController = TextEditingController();

  final ConnectivityController _connectivity = ConnectivityController();
  final InputValidatorController _validator = InputValidatorController();

  late final AuthController _authController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  void _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final username = _userController.text.trim();

    final emailError = _validator.validateEmail(email);
    final passError = _validator.validatePassword(password);
    final userError = _validator.validateUsername(username);

    if (emailError != null || passError != null || userError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userError ?? emailError ?? passError!)),
      );
      return;
    }

    setState(() => _isLoading = true);

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

    final viewModel = RegisterViewModel(
      username: username,
      email: email,
      password: password,
    );

    final result = await _authController.handleRegistration(viewModel);

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
          mainAxisAlignment: MainAxisAlignment.center,
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
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text("Створити акаунт")),
            const SizedBox(height: 10),
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
