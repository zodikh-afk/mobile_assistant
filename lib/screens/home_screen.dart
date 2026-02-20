import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini AI Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Тут пізніше додамо вихід з акаунту
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Привіт! Натисни на мікрофон, щоб поговорити",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Велика кнопка для голосу (поки що просто дизайн)
            FloatingActionButton.large(
              onPressed: () {
                print("Слухаю...");
              },
              child: const Icon(Icons.mic, size: 50),
            ),
          ],
        ),
      ),
    );
  }
}