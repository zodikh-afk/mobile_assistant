import '../business_logic/services/profile_service.dart';
import '../repositories/profile_repository.dart';

class ProfileController {
  late final ProfileService _profileService;

  ProfileController() {
    final repository = ProfileRepository();
    _profileService = ProfileService(repository);
  }

  Future<String> getUsername() async {
    return await _profileService.getUsername();
  }
}
