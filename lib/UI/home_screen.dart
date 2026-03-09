import 'package:flutter/material.dart';
import '../business_logic/ai_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();

  late final AuthController _authController;

  String _aiResponse = "Напиши мені щось!";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepository();
    _authController = AuthController(authRepository);
  }

  void _askGemini() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _aiService.getResponse(_controller.text);

    setState(() {
      _aiResponse = response;
      _isLoading = false;
      _controller.clear();
    });
  }

  void _handleLogout() async {
    await _authController.handleLogout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Assistant")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Меню Assistant',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Налаштування'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Вийти', style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(_aiResponse, style: const TextStyle(fontSize: 18)),
              ),
            ),
            if (_isLoading) const CircularProgressIndicator(),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Запитай щось...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _askGemini,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
