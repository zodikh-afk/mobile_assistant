import 'base_command.dart';
import 'package:intl/intl.dart'; // Пакет для форматування часу

class TimeCommandService implements BaseCommand {
  @override
  bool canHandle(String text) {
    final t = text.toLowerCase();
    return t.contains("час") || t.contains("година") || t.contains("дата");
  }

  @override
  Future<String> execute(String text) async {
    final now = DateTime.now();

    if (text.toLowerCase().contains("дата")) {
      return "Сьогодні ${DateFormat('dd.MM.yyyy').format(now)}";
    }

    return "Зараз ${DateFormat('HH:mm').format(now)}";
  }
}
