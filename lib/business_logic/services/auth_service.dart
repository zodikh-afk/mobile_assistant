import '../../repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  Future<UserModel?> register(
      String email, String password, String username) async {
    return await _repository.register(email, password, username);
  }

  Future<UserModel?> login(String email, String password) async {
    return await _repository.login(email, password);
  }

  Future<void> logout() async {
    await _repository.logout();
  }
}
