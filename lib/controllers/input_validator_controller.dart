class InputValidatorController {
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return "Електронна пошта не може бути порожньою";
    }
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      return "Введіть коректну електронну пошту (наприклад: user@mail.com)";
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return "Пароль не може бути порожнім";
    }
    if (password.length < 6) {
      return "Пароль має містити щонайменше 6 символів";
    }
    return null;
  }

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
