import '../../repositories/profile_repository.dart';

class ProfileService {
  final ProfileRepository _repository;

  ProfileService(this._repository);

  Future<String> getUsername() async {
    final name = await _repository.fetchUsername();
    // Бізнес-логіка: якщо імені немає, повертаємо дефолтне значення
    return name ?? "Користувач";
  }
}
