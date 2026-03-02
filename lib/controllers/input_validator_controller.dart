class InputValidatorController {
  // Перевірка електронної пошти за допомогою регулярного виразу (RegExp)
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return "Електронна пошта не може бути порожньою";
    }
    // Стандартний регулярний вираз для перевірки формату email
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      return "Введіть коректну електронну пошту (наприклад: user@mail.com)";
    }
    return null; // Повертаємо null, якщо помилок немає
  }

  // Перевірка пароля
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return "Пароль не може бути порожнім";
    }
    if (password.length < 6) {
      return "Пароль має містити щонайменше 6 символів"; // Вимога Firebase Auth
    }
    return null;
  }

  // Перевірка імені користувача (логіна)
  String? validateUsername(String username) {
    if (username.isEmpty) {
      return "Логін не може бути порожнім";
    }
    if (username.length < 3) {
      return "Логін має містити щонайменше 3 символи";
    }
    return null;
  }
}
