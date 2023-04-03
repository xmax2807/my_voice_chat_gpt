import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_voice_chat_gpt/speech_to_text_components/speech_to_text_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../setting_components/setting_data.dart';
import '../shared_components/global_variables.dart';

class SpeechToTextWidget extends StatefulWidget {
  const SpeechToTextWidget({super.key});

  @override
  State<SpeechToTextWidget> createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget> {
  SettingData get _settingData => SettingData.Instance;

  final SpeechToText _speechToText = SpeechToText();

  String _lastWords = '';
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  double level = 0.0;

  final TextEditingController _pauseForController =
      TextEditingController(text: '3');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');

  Future microPhoneReq() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (await Permission.microphone.isGranted == false) {
      await Permission.microphone.request();
    }
    //WebViewMethodForCamera();
  }

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    try {
      var hasSpeech = await _speechToText.initialize();
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        MyGlobalStorage.speechLocaleNames = await _speechToText.locales();
        _settingData.speechLanguage ??= await _speechToText.systemLocale();
        setState(() {});
      }
      if (!mounted) return;
    } catch (e) {}
  }

  void _startListening() async {
    await microPhoneReq();
    _lastWords = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    // Note that `listenFor` is the maximum, not the minimun, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      partialResults: true,
      onSoundLevelChange: soundLevelListener,
      localeId: _settingData.speechLanguage?.localeId ?? '',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();

    //_messageTextEditController.text = _lastWords;
    //_createTextMessage(_lastWords);
    setState(() {
      level = 0.0;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      Provider.of<SpeechToTextProvider>(context).updateText(_lastWords);
      //_messageTextEditController.text = _lastWords;
    });
  }

  void cancelListening() {
    _speechToText.cancel();
    Provider.of<SpeechToTextProvider>(context).updateText(_lastWords);
    setState(() {
      level = 0.0;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: !_speechToText.isAvailable
          ? const Text("Initializing Speech")
          : Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: .26,
                      spreadRadius: level * 1.5,
                      color: Colors.black.withOpacity(.05))
                ],
                //color: Colors.amber,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: _speechToText.isNotListening
                    ? _startListening
                    : _stopListening,
              ),
            ),
    );
  }
}
