import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isSpeechEnabled = false;

  bool _isAutonomousModeEnabled = false;

  Function(String)? _onResultCallback;

  Future<bool> initSpeech() async {
    _isSpeechEnabled = await _speechToText.initialize(
      onError: (val) {
        print('Помилка розпізнавання: $val');
        _restartListeningIfNeeded();
      },
      onStatus: (val) {
        print('Статус мікрофона: $val');
        if (val == 'done' || val == 'notListening') {
          _restartListeningIfNeeded();
        }
      },
    );
    return _isSpeechEnabled;
  }

  void startAutonomousListening({required Function(String) onResult}) async {
    if (!_isSpeechEnabled) {
      print("Мікрофон не ініціалізовано.");
      return;
    }

    _isAutonomousModeEnabled = true;
    _onResultCallback = onResult;
    _startListening();
  }

  void stopAutonomousListening() async {
    _isAutonomousModeEnabled = false;
    await _speechToText.stop();
  }

  void _startListening() async {
    if (_isAutonomousModeEnabled && !_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult && _onResultCallback != null) {
            _onResultCallback!(result.recognizedWords);
          }
        },
        localeId: 'uk_UA',
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  void _restartListeningIfNeeded() async {
    if (_isAutonomousModeEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      _startListening();
    }
  }

  bool get isListening => _isAutonomousModeEnabled;
}
