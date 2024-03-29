import 'package:my_voice_chat_gpt/file_io.dart';
import 'package:my_voice_chat_gpt/shared_components/global_variables.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SettingData {
  late bool autoTTS;
  late bool appLightTheme;
  late LocaleName? speechLanguage;

  static SettingData? _instance;
  static SettingData get Instance {
    return _instance!;
  }

  static bool get isInitialized => _instance != null;
  static Future initialize() async {
    var json = await readJson<SettingData>("setting.json");
    _instance = json == null ? SettingData._() : SettingData.fromJson(json);
  }

  SettingData._() {
    autoTTS = false;
    appLightTheme = true;
    speechLanguage = null;
  }

  SettingData.fromJson(Map<String, dynamic> json) {
    autoTTS = json['autoTTS'];
    appLightTheme = json['appLightTheme'];
    speechLanguage =
        LocaleName(json['speechLocaleId'], json['speechLocaleName']);
  }

  Map<String, dynamic> toJson() => {
        'autoTTS': autoTTS,
        'appLightTheme': appLightTheme,
        'speechLocaleId': speechLanguage?.localeId ?? '',
        'speechLocaleName': speechLanguage?.name ?? '',
      };

  void saveSetting() {
    writeJson(Instance, MyGlobalStorage.settingPath);
  }
}
