import 'package:flutter/material.dart';
import '../business_logic/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  String _aiResponse = "Напиши мені щось!";
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Assistant")),
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
