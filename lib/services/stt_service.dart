import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttService {
  final Map<String, STTServiceHandler> _subscribers =
      <String, STTServiceHandler>{};

  final SpeechToText _speechToText = SpeechToText();
  String? _textHolder = "";
  bool _isInitialize = false;
  bool onListen = false;
  bool withResult = true;

  void addSttSubscriber(String name, STTServiceHandler handler) {
    if (hasSubscriber(name)) {
      return;
    }
    _subscribers[name] = handler;
  }

  bool hasSubscriber(String name) {
    return _subscribers.containsKey(name);
  }

  void removeSttSubscriber(String name) {
    if (!hasSubscriber(name)) {
      return;
    }
    _subscribers.remove(name);
  }

  bool get isInitialize => _isInitialize;

  Future<void> init() async {
    try {
      _isInitialize = await _speechToText.initialize(
        onStatus: (String status) {
          switch (status) {
            case 'listening':
              _subscribers.forEach((_, value) {
                value.onListen();
              });
              break;

            case 'notListening':
              _subscribers.forEach((_, value) {
                value.onDone();
              });
              onListen = false;
              break;

            case 'done':
              onListen = false;

              if (!withResult) return;
              _subscribers.forEach((_, value) {
                value.onResult(_textHolder ?? "");
              });

              break;

            default:
              _subscribers.forEach((_, value) {
                value.onListen();
              });
              break;
          }
        },
        onError: (SpeechRecognitionError errorNotification) {
          _subscribers.forEach((_, value) {
            value.onError(
              Exception(errorNotification.errorMsg),
              StackTrace.empty,
            );
          });
        },
      );
      //
    } on Exception catch (ex, stack) {
      _subscribers.forEach((_, value) {
        value.onError(ex, stack);
      });
    }
  }

  Future<void> stopSttAndReceive() async {
    if (!_isInitialize) {
      return;
    }
    withResult = true;
    await _speechToText.stop();
  }

  Future<void> stopStt() async {
    if (!_isInitialize) {
      return;
    }
    withResult = false;
    await _speechToText.stop();
  }

  void dispose() async {
    stopStt();
    _subscribers.clear();
  }

  void listenStt({Locale? local, ListenMode? listenMode}) async {
    if (!_isInitialize) {
      return;
    }
    try {
      _textHolder = "";

      withResult = true;
      onListen = true;

      await _speechToText.listen(
        listenMode: listenMode ?? ListenMode.dictation,
        localeId: local?.languageCode,
        onResult: (SpeechRecognitionResult result) {
          _textHolder = result.recognizedWords;

          _subscribers.forEach((_, value) {
            value.onPartialResult(result.recognizedWords);
          });
        },
        onSoundLevelChange: (level) {
          if (!onListen) return;

          _subscribers.forEach((_, value) {
            value.onSoundChange(level);
          });
        },
      );

      //
    } on Exception catch (ex, stack) {
      _subscribers.forEach((_, value) {
        value.onError(ex, stack);
      });
    }
  }
}

abstract class STTServiceHandler {
  void onListen();
  void onDone();
  void onResult(String text);
  void onPartialResult(String text);
  void onSoundChange(double level);
  void onError(Exception e, StackTrace t);
}
