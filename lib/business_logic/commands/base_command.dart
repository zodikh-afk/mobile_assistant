abstract class BaseCommand {
  bool canHandle(String text);
  Future<String> execute(String text);
}
