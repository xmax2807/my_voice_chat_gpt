import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_data.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SettingNotifier with ChangeNotifier {
  SettingData get _settingData => SettingData.Instance;

  SettingNotifier();
  bool get autoTTS => _settingData.autoTTS;

  void changeSpeechLanguage(LocaleName? locale) {
    _settingData.speechLanguage = locale;
    notifyListeners();
    _settingData.saveSetting();
  }
}
