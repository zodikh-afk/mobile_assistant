import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {
  // Зберігаємо вибір теми (світла/темна)
  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  // Отримуємо поточну тему
  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_dark_mode') ?? false;
  }

  // Очищення даних логіну (якщо користувач знімає галочку "Запам'ятати мене")
  Future<void> clearSavedAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }
}
