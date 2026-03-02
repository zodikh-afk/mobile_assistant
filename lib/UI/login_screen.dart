import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_service.dart';
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

  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Завантажуємо збережені дані при відкритті екрану
  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('saved_email') ?? '';
        _passController.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.loginUser(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "Успіх") {
      // Логіка збереження даних, якщо галочка стоїть
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passController.text.trim());
      } else {
        await prefs.setBool('remember_me', false);
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Електронна пошта",
                    prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 10),
            TextField(
                controller: _passController,
                decoration: const InputDecoration(
                    labelText: "Пароль", prefixIcon: Icon(Icons.lock)),
                obscureText: true),
            const SizedBox(height: 10),

            // Чекбокс "Запам'ятати мене"
            CheckboxListTile(
              title: const Text("Запам'ятати мене"),
              value: _rememberMe,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),

            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child:
                        const Text("Увійти", style: TextStyle(fontSize: 18))),
            TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen())),
              child: const Text("Немає акаунта? Зареєструватися"),
            ),
          ],
        ),
      ),
    );
  }
}
