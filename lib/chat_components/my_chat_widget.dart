import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_type;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:my_voice_chat_gpt/chat_components/chat_gpt.dart';
import 'package:my_voice_chat_gpt/shared_components/global_variables.dart';
import 'package:my_voice_chat_gpt/speech_to_text_components/speech_to_text_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../file_io.dart';
import '../setting_components/setting_data.dart';
import '../shared_components/theme.dart';
import 'text_to_speech.dart';

class MyChatWidget extends StatefulWidget {
  const MyChatWidget({super.key});
  @override
  State<MyChatWidget> createState() => _MyChatWidgetState();
}

class _MyChatWidgetState extends State<MyChatWidget>
    with WidgetsBindingObserver {
  List<chat_type.Message> _messages = [];

  SettingData get _settingData => SettingData.Instance;
  final MyTTS _textToSpeech = MyTTS();
  late MyChatGPT _chatGPT;

  bool _isReady = false;

  final TextEditingController _messageTextEditController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _isReady = false;
    _loadMessages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _saveMessages();
  }

  void _handleSendPressed(chat_type.PartialText message) async {
    _createTextMessage(message.text, MyGlobalStorage.user);

    final List<String>? responses = await _chatGPT.sendRequest(message.text);
    if (responses == null) return;

    for (var response in responses) {
      await _createTextMessage(response, MyGlobalStorage.bot);
    }
    _saveMessages();
  }

  Future _createTextMessage(String text, chat_type.User author) async {
    final textMessage = chat_type.TextMessage(
      author: author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    _addMessage(textMessage);
  }

  void _addMessage(chat_type.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _shouldSpeak());
  }

  void _loadMessages() async {
    final messages = await readJsonList(
      'messages.json',
      onMapping: (map) => chat_type.Message.fromJson(map),
    );
    _messages = messages ?? List.empty(growable: true);

    _chatGPT = await MyChatGPT.create(_messages);

    _isReady = true;
    setState(() {});
  }

  void _saveMessages() {
    writeJson(_messages, "messages.json");
  }

  void _shouldSpeak() {
    if (!_settingData.autoTTS || _messages.isEmpty) return;

    chat_type.Message message = _messages.last;

    if (message.author == MyGlobalStorage.user ||
        message is! chat_type.TextMessage) return;

    _textToSpeech.speak(message.text,
        _settingData.speechLanguage?.localeId.replaceAll('_', '-'));
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (MyGlobalStorage.user.id == message.author.id)
            IconButton(
                onPressed: () {
                  if (message is chat_type.TextMessage) {
                    _textToSpeech.speak(
                        message.text,
                        _settingData.speechLanguage?.localeId
                            .replaceAll('_', '-'));
                  }
                },
                icon: const Icon(Icons.play_circle_outline_rounded)),
          Flexible(
            child: Bubble(
              padding: const BubbleEdges.only(top: 0, bottom: 0),
              radius: const Radius.circular(30),
              color: MyGlobalStorage.user.id != message.author.id
                  ? const Color(0xfff5f5f7)
                  : const Color(0xff6f61e8),
              child: child,
            ),
          ),
          if (MyGlobalStorage.user.id != message.author.id)
            IconButton(
                onPressed: () {
                  if (message is chat_type.TextMessage) {
                    _textToSpeech.speak(
                        message.text,
                        _settingData.speechLanguage?.localeId
                            .replaceAll('_', '-'));
                  }
                },
                icon: const Icon(Icons.play_circle_outline_rounded)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return !_isReady
        ? const Text("Initializing Messages")
        : Consumer2<SpeechToTextProvider, ThemeNotifier>(
            builder: (context, speechProvider, themeProvider, child) {
              _messageTextEditController.text = speechProvider.speechResult;
              return Chat(
                theme: themeProvider.getMode()
                    ? const DefaultChatTheme()
                    : const DarkChatTheme(),
                bubbleBuilder: _bubbleBuilder,
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: MyGlobalStorage.user,
                inputOptions: InputOptions(
                    textEditingController: _messageTextEditController),
              );
            },
          );
  }
}
