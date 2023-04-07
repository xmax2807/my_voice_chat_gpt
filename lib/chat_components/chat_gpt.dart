import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_type;

import 'package:my_voice_chat_gpt/shared_components/global_variables.dart';

class MyChatGPT {
  late OpenAI openAI;
  late List<Map<String, String>> _chatMessages;

  ///ID of the model to use. Currently, only and are supported
  ///[kChatGptTurboModel]
  ///[kChatGptTurbo0301Model]
  Future<List<String>?> sendRequest(String message) async {
    final request = ChatCompleteText(
        messages: _chatMessages,
        maxToken: 3600,
        model: ChatModel.ChatGptTurboModel);
    try {
      final response = await openAI.onChatCompletion(request: request);

      if (response == null) return null;

      final responses = response.choices.map((e) => e.message.content).toList();
      return responses;
    } catch (e) {
      return null;
    }
  }

  bool _isUser(String id) => id == MyGlobalStorage.user.id;

  MyChatGPT._initialize(List<chat_type.Message> messages) {
    updateMessages(messages);
    openAI = OpenAI.instance.build(
        token: dotenv.env[MyGlobalStorage.ChatAPI] ?? '{}',
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 40),
            connectTimeout: const Duration(seconds: 20)),
        isLog: true);
  }

  static Future<MyChatGPT> create(List<chat_type.Message> messages) async {
    var component = MyChatGPT._initialize(messages);
    return component;
  }

  void updateMessages(List<chat_type.Message> messages) {
    _chatMessages = messages
        .map((e) => Map.of({
              "role": _isUser(e.id) ? "user" : "assistant",
              "content": (e is chat_type.TextMessage) ? e.text : ''
            }))
        .toList();

    dev.log(_chatMessages.length.toString());
  }

  void clearMessages() {
    _chatMessages.clear();
    dev.log(_chatMessages.length.toString());
  }

  void addToHistory(chat_type.TextMessage message) {
    _chatMessages.add({
      "role": _isUser(message.author.id) ? "user" : "assistant",
      "content": message.text
    });
  }
}
