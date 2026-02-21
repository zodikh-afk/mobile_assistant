import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';

class AIService {
  final String _apiKey = "AIzaSyBSQJOh_pd94vdau6y8gjkgc5EwOfbxluE";
  static const platform = MethodChannel('com.example.app/system_commands');

  // Використовуємо GenerativeModel? (з знаком питання), щоб уникнути помилок ініціалізації
  GenerativeModel? _model;

  AIService() {
    _initModel();
  }

  void _initModel() {
    // Спробуємо використати найбільш стабільну назву моделі
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
      systemInstruction: Content.system(
          "Ти — розумний помічник. Якщо користувач просить відкрити YouTube, "
          "твоя відповідь ПОВИННА містити слово [OPEN_YOUTUBE]. "
          "В інших випадках відповідай як зазвичай."),
    );
  }

  Future<String> getResponse(String prompt) async {
    if (_model == null) return "Модель не ініціалізована";

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text ?? "";

      if (text.contains("[OPEN_YOUTUBE]")) {
        _openYouTube();
        return "Відкриваю YouTube...";
      }

      return text;
    } catch (e) {
      // Якщо знову помилка "not found", спробуй змінити назву моделі на 'gemini-pro'
      return "Помилка зв'язку з Gemini: $e";
    }
  }

  Future<void> _openYouTube() async {
    try {
      await platform.invokeMethod('openYouTube');
    } on PlatformException catch (e) {
      print("Помилка Kotlin: ${e.message}");
    }
  }
}
