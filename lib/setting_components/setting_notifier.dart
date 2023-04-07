import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_data.dart';
import 'package:my_voice_chat_gpt/shared_components/global_variables.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_type;

import '../file_io.dart';

class SettingNotifier with ChangeNotifier {
  SettingData get _settingData => SettingData.Instance;

  bool get autoTTS => _settingData.autoTTS;

  get messages => MyGlobalStorage.messages;

  void changeSpeechLanguage(LocaleName? locale) {
    _settingData.speechLanguage = locale;
    notifyListeners();
    _settingData.saveSetting();
  }

  void deleteMessages() {
    MyGlobalStorage.messages.clear();
    notifyListeners();
    saveMessages();
  }

  Future<dynamic> loadMessages() async {
    final messages = await readJsonList(
      MyGlobalStorage.messagePath,
      onMapping: (map) => chat_type.Message.fromJson(map),
    );

    MyGlobalStorage.messages = messages ?? [];

    return MyGlobalStorage.messages;
  }

  void saveMessages() {
    writeJson(MyGlobalStorage.messages, MyGlobalStorage.messagePath);
  }
}
