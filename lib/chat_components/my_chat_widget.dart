import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_type;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:my_voice_chat_gpt/speech_to_text_components/speech_to_text_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../file_io.dart';
import '../setting_components/setting_data.dart';
import '../shared_components/theme.dart';
import '../text_to_speech.dart';

class MyChatWidget extends StatefulWidget {
  const MyChatWidget({super.key});

  @override
  State<MyChatWidget> createState() => _MyChatWidgetState();
}

class _MyChatWidgetState extends State<MyChatWidget>
    with WidgetsBindingObserver {
  List<chat_type.Message> _messages = [];
  final _user =
      const chat_type.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _bot = const chat_type.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3aa');

  SettingData get _settingData => SettingData.Instance;
  final MyTTS _textToSpeech = MyTTS();

  final TextEditingController _messageTextEditController =
      TextEditingController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _saveMessages();
  }

  void _handleSendPressed(chat_type.PartialText message) {
    _createTextMessage(message.text, _user);
    _saveMessages();
  }

  void _createTextMessage(String text, chat_type.User user) {
    final textMessage = chat_type.TextMessage(
      author: user,
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
  }

  void _loadMessages() async {
    final messages = await readJsonList(
      'messages.json',
      onMapping: (map) => chat_type.Message.fromJson(map),
    );

    setState(() {
      _messages = messages ?? List.empty(growable: true);
    });
  }

  void _saveMessages() {
    writeJson(_messages, "messages.json");
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_user.id == message.author.id)
            IconButton(
                onPressed: () {
                  if (message is chat_type.TextMessage) {
                    _textToSpeech.speak(message.text);
                  }
                },
                icon: const Icon(Icons.play_circle_outline_rounded)),
          Flexible(
            child: Bubble(
              padding: const BubbleEdges.only(top: 0, bottom: 0),
              radius: const Radius.circular(30),
              color: _user.id != message.author.id
                  ? const Color(0xfff5f5f7)
                  : const Color(0xff6f61e8),
              child: child,
            ),
          ),
          if (_user.id != message.author.id)
            IconButton(
                onPressed: () {
                  if (message is chat_type.TextMessage) {
                    _textToSpeech.speak(message.text);
                  }
                },
                icon: const Icon(Icons.play_circle_outline_rounded)),
        ],
      );

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SpeechToTextProvider, ThemeNotifier>(
      builder: (context, speechProvider, themeProvider, child) {
        var themeProvider = Provider.of<ThemeNotifier>(context);
        _messageTextEditController.text = speechProvider.speechResult;
        return Chat(
          theme: themeProvider.getMode()
              ? const DefaultChatTheme()
              : const DarkChatTheme(),
          bubbleBuilder: _bubbleBuilder,
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          inputOptions:
              InputOptions(textEditingController: _messageTextEditController),
        );
      },
    );
  }
}
