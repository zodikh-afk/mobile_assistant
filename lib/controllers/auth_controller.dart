import '../domain/view_models/register_view_model.dart';
import '../repositories/auth_repository.dart';
import '../domain/view_models/login_view_model.dart';

class AuthController {
  final AuthRepository _repository;

  AuthController(this._repository);

  Future<String> handleRegistration(RegisterViewModel viewModel) async {
    try {
      await _repository.register(
          viewModel.email, viewModel.password, viewModel.username);

      return "Успіх";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> handleLogin(LoginViewModel viewModel) async {
    try {
      await _repository.login(viewModel.email, viewModel.password);
      return "Успіх";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> handleLogout() async {
    try {
      await _repository.logout();
    } catch (e) {
      print("Помилка при виході: $e");
    }
  }
}
