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
    _chatMessages.add({"role": "user", "content": message});

    final request = ChatCompleteText(
        messages: _chatMessages,
        maxToken: 200,
        model: ChatModel.ChatGptTurbo0301Model);

    final response = await openAI.onChatCompletion(request: request);

    if (response == null) return null;

    final responses = response.choices.map((e) => e.message.content).toList();
    for (var element in response.choices) {
      dev.log("data -> ${element.message.content}");
    }
    return responses;
  }

  bool _isUser(String id) => id == MyGlobalStorage.user.id;

  MyChatGPT._initialize(List<chat_type.Message> messages) {
    _chatMessages = messages
        .map((e) => Map.of({
              "role": _isUser(e.id) ? "user" : "assistant",
              "content": (e is chat_type.TextMessage) ? e.text : ''
            }))
        .toList();
    openAI = OpenAI.instance.build(
        token: dotenv.env[MyGlobalStorage.ChatAPI] ?? '{}',
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 20),
            connectTimeout: const Duration(seconds: 20)),
        isLog: true);
  }

  /// Public factory
  static Future<MyChatGPT> create(List<chat_type.Message> messages) async {
    // Call the private constructor
    var component = MyChatGPT._initialize(messages);

    // Do initialization that requires async
    //await component._complexAsyncInit();

    // Return the fully initialized object
    return component;
  }
}
