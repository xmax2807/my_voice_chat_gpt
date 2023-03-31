import 'package:speech_to_text/speech_to_text.dart';

class SettingData {
  bool autoTTS;
  LocaleName? speechLanguage;
  SettingData({this.autoTTS = false, this.speechLanguage});
}
