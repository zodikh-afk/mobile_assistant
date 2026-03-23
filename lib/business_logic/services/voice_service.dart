import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isSpeechEnabled = false;

  Future<bool> initSpeech() async {
    _isSpeechEnabled = await _speechToText.initialize(
      onError: (val) => print('Помилка розпізнавання: $val'),
      onStatus: (val) => print('Статус мікрофона: $val'),
    );
    return _isSpeechEnabled;
  }

  void startListening(
      {required Function(String) onResult, required Function() onDone}) async {
    if (_isSpeechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: 'uk_UA',
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      );
    } else {
      print("Мікрофон не ініціалізовано.");
    }
  }

  void stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
