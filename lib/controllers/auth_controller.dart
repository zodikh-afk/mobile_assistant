import '../domain/view_models/register_view_model.dart';
import '../domain/view_models/login_view_model.dart';
import '../business_logic/services/auth_service.dart';
import '../repositories/auth_repository.dart';

class AuthController {
  late final AuthService _authService;

  // Конструктор без аргументів — сам створює все необхідне
  AuthController() {
    final authRepository = AuthRepository();
    _authService = AuthService(authRepository);
  }

  Future<String> handleRegistration(RegisterViewModel viewModel) async {
    try {
      await _authService.register(
          viewModel.email, viewModel.password, viewModel.username);
      return "Успіх";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> handleLogin(LoginViewModel viewModel) async {
    try {
      await _authService.login(viewModel.email, viewModel.password);
      return "Успіх";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> handleLogout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print("Помилка при виході: $e");
    }
  }
}
