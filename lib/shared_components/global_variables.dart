import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_type;

class MyGlobalStorage {
  static const String messagePath = "messages.json";
  static const String settingPath = "setting.json";
  static List<LocaleName> speechLocaleNames = [];
  static const String ChatAPI = 'CHAT_API';
  static const user =
      chat_type.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  static const bot = chat_type.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3aa');
  static List<chat_type.Message> messages = [];
}
