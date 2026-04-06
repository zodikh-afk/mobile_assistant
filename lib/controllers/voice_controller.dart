import '../business_logic/services/voice_service.dart';

class VoiceController {
  late final VoiceService _voiceService;

  VoiceController() {
    _voiceService = VoiceService();
  }

  Future<bool> initSpeech() async {
    return await _voiceService.initSpeech();
  }

  void startListening(Function(String) onResult) {
    _voiceService.startAutonomousListening(onResult: onResult);
  }

  void stopListening() {
    _voiceService.stopAutonomousListening();
  }
}
