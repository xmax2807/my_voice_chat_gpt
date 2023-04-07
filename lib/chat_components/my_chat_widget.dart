import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_type;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:my_voice_chat_gpt/chat_components/chat_gpt.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_notifier.dart';
import 'package:my_voice_chat_gpt/shared_components/global_variables.dart';
import 'package:my_voice_chat_gpt/speech_to_text_components/speech_to_text_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../setting_components/setting_data.dart';
import '../shared_components/dialog.dart';
import '../shared_components/theme.dart';
import 'text_to_speech.dart';

class MyChatWidget extends StatefulWidget {
  const MyChatWidget({super.key});
  @override
  State<MyChatWidget> createState() => _MyChatWidgetState();
}

class _MyChatWidgetState extends State<MyChatWidget>
    with WidgetsBindingObserver {
  SettingData get _settingData => SettingData.Instance;
  late final MyTTS _textToSpeech;
  late MyChatGPT _chatGPT;

  bool _isReady = false;

  final TextEditingController _messageTextEditController =
      TextEditingController();

  late final SettingNotifier _settingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _settingProvider = Provider.of<SettingNotifier>(context, listen: false);

      _textToSpeech = Provider.of<MyTTS>(context, listen: false);
      _initMessages();
    });
    _isReady = false;
  }

  void _handleSendPressed(chat_type.PartialText message) async {
    final chat_type.TextMessage textMessage =
        await _createTextMessage(message.text, MyGlobalStorage.user);
    if (mounted) {
      Provider.of<SpeechToTextProvider>(context).updateText('');
    }
    await _sendRequest(textMessage);
    _settingProvider.saveMessages();
  }

  Future _sendRequest(chat_type.TextMessage message) async {
    final List<String>? responses = await _chatGPT.sendRequest(message.text);
    if (responses == null) {
      if (context.mounted) {
        showAlertDialog(
          context,
          title: 'Error',
          description:
              'Request timeout. It seems like the request took longer than 40 sec. Request aborted',
          onConfirm: () => _sendRequest(message),
          onDecline: () => _removeMessage(message),
          confirmText: "Resend Message",
        );
      }
      return;
    }

    for (var response in responses) {
      await _createTextMessage(response, MyGlobalStorage.bot);
    }
  }

  Future<chat_type.TextMessage> _createTextMessage(
      String text, chat_type.User author) async {
    final textMessage = chat_type.TextMessage(
      author: author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    _chatGPT.addToHistory(textMessage);
    _addMessage(textMessage);
    return textMessage;
  }

  List<chat_type.Message> _getMessages() {
    final List<chat_type.Message> messages =
        Provider.of<SettingNotifier>(context).messages;
    if (messages.isEmpty) {
      _chatGPT.clearMessages();
    }
    return messages;
  }

  void _addMessage(chat_type.Message message) {
    setState(() {
      MyGlobalStorage.messages.insert(0, message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _shouldSpeak(message));
  }

  void _removeMessage(chat_type.Message message) {
    int index = 0;
    for (var element in MyGlobalStorage.messages) {
      if (element.id == message.id) {
        break;
      }
      index++;
    }
    setState(() {
      MyGlobalStorage.messages.removeAt(index);
    });
  }

  void _initMessages() async {
    await _settingProvider.loadMessages();
    _chatGPT = await MyChatGPT.create(MyGlobalStorage.messages);

    _isReady = true;
    setState(() {});
  }

  void _shouldSpeak(chat_type.Message lastMessage) {
    bool shouldSpeak =
        _settingData.autoTTS && MyGlobalStorage.messages.isNotEmpty;
    if (!shouldSpeak) return;

    if (lastMessage.author.id == MyGlobalStorage.user.id ||
        lastMessage is! chat_type.TextMessage) return;

    _textToSpeech.speak(lastMessage.text, lastMessage.id);
  }

  Widget _getIconState(TtsState state) {
    switch (state) {
      case TtsState.stopped:
        return const Icon(Icons.play_circle_outline_rounded);
      case TtsState.playing:
        return const Icon(Icons.stop_circle_outlined);
    }
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2.0),
      child: const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget _bubbleBuilder(
    Widget child, {
    required chat_type.Message message,
    required nextMessageInGroup,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Bubble(
            padding: const BubbleEdges.only(top: 0, bottom: 0),
            radius: const Radius.circular(30),
            color: MyGlobalStorage.user.id != message.author.id
                ? const Color(0xFF646464)
                : const Color(0xff6f61e8),
            child: child,
          ),
        ),
        if (MyGlobalStorage.user.id != message.author.id)
          Consumer<MyTTS>(builder: (context, provider, child) {
            MessageSpeechState? speechState =
                provider.getSpeechState(message.id);

            TtsState currentState = speechState == null
                ? TtsState.stopped
                : speechState.currentState;

            return IconButton(
                onPressed: () {
                  if (message is chat_type.TextMessage) {
                    _textToSpeech.speak(message.text, message.id);
                  }
                },
                icon: _getIconState(currentState));
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return !_isReady
        ? const Text("Initializing Messages")
        : Consumer<ThemeNotifier>(
            builder: (context, themeProvider, child) {
              return Chat(
                theme: themeProvider.getMode()
                    ? const DefaultChatTheme()
                    : const DarkChatTheme(),
                bubbleBuilder: _bubbleBuilder,
                messages: _getMessages(),
                onSendPressed: _handleSendPressed,
                user: MyGlobalStorage.user,
                customBottomWidget: Consumer<SpeechToTextProvider>(
                  builder: (context, speechProvider, child) {
                    _messageTextEditController.text =
                        speechProvider.speechResult;
                    return Input(
                      onSendPressed: _handleSendPressed,
                      options: InputOptions(
                          textEditingController: _messageTextEditController),
                    );
                  },
                ),

                // inputOptions: InputOptions(
                //     textEditingController: _messageTextEditController),
              );
            },
          );
  }
}
