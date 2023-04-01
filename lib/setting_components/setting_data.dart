import 'package:speech_to_text/speech_to_text.dart';

class SettingData {
  bool autoTTS;
  bool appLightTheme;
  LocaleName? speechLanguage;
  SettingData(
      {this.appLightTheme = false, this.autoTTS = false, this.speechLanguage});
}
