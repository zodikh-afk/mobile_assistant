import 'package:url_launcher/url_launcher.dart';
import 'base_command.dart';

class AppCommandService implements BaseCommand {
  final Map<String, String> _apps = {
    'ютуб': 'vnd.youtube://',
    'тікток': 'tiktok://',
    'інстаграм': 'instagram://',
    'телеграм': 'tg://'
  };

  @override
  bool canHandle(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('відкрий') || lowerText.contains('запусти');
  }

  @override
  Future<String> execute(String text) async {
    final lowerText = text.toLowerCase();

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
    return "Я не знайшов такий додаток у своєму списку.";
  }
}
