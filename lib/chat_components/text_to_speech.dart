import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class MyTTS {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  MyTTS() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      //_getDefaultVoice();
    }
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<dynamic> getDefaultVoice() async {
    return await flutterTts.getDefaultVoice;
  }

  Future _waitWhile(bool Function() test,
      [Duration pollInterval = Duration.zero]) {
    var completer = Completer();
    check() {
      if (!test()) {
        completer.complete();
      } else {
        Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  Future speak(String text, String? localVoice) async {
    await _waitWhile(() => !isStopped);

    if (!isWindows) {
      await flutterTts
          .setLanguage(localVoice ?? flutterTts.getDefaultVoice as String);
    }
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text.isNotEmpty) {
      ttsState = TtsState.playing;
      await flutterTts.speak(text);
      ttsState = TtsState.stopped;
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future stop() async {
    await flutterTts.stop();
  }

  Future pause() async {
    var result = await flutterTts.pause();
  }

  void destroyTTS() {
    flutterTts.stop();
  }
}