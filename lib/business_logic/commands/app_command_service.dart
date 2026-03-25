import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'base_command.dart';

class AppCommandService implements BaseCommand {
  final Map<String, String> _apps = {
    'ютуб': 'vnd.youtube://',
    'YouTube': 'vnd.youtube://',
    'тікток': 'tiktok://',
    'tiktok': 'tiktok://',
    'інстаграм': 'instagram://',
    'телеграм': 'tg://',
    'Telegram': 'tg://'
  };

  @override
  bool canHandle(String text) {
    final lowerText = text.toLowerCase();
    // Додаємо слова-тригери для гортання
    return lowerText.contains('відкрий') ||
        lowerText.contains('запусти') ||
        lowerText.contains('гортай') ||
        lowerText.contains('наступне') ||
        lowerText.contains('далі');
  }

  @override
  Future<String> execute(String text) async {
    final lowerText = text.toLowerCase();

    // Спочатку перевіряємо, чи це команда гортання
    if (lowerText.contains('гортай') ||
        lowerText.contains('наступне') ||
        lowerText.contains('далі')) {
      try {
        const intent = AndroidIntent(
          action: 'com.example.mobile_assistant.SCROLL_UP',
        );
        // Відправляємо Broadcast, який зловить наш Kotlin-сервіс
        await intent.sendBroadcast();
        return "Гортаю...";
      } catch (e) {
        return "Не вдалося виконати жест гортання.";
      }
    }

    // Якщо це не гортання, перевіряємо чи це команда відкриття додатку
    for (var entry in _apps.entries) {
      if (lowerText.contains(entry.key)) {
        final url = Uri.parse(entry.value);

        try {
          await launchUrl(
            url,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          return "Відкриваю ${entry.key}...";
        } catch (e) {
          return "Вибач, додаток ${entry.key} не знайдено на твоєму пристрої.";
        }
      }
    }

    return "Я не зрозумів команду або не знайшов такий додаток у своєму списку.";
  }
}
