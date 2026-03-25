import 'ai_service.dart';
import '../commands/base_command.dart';

class AssistantManager {
  final AIService _geminiService;
  final List<BaseCommand> _commands;

  AssistantManager(this._geminiService, this._commands);

  Future<String> processRequest(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return "Ти нічого не написав.";

    for (var command in _commands) {
      if (command.canHandle(cleanText)) {
        return await command.execute(cleanText);
      }
    }

    return await _geminiService.getResponse(cleanText);
  }
}
