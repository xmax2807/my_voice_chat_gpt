import 'dart:math';
import 'dart:ui';
import 'package:bubble/bubble.dart';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chatType;
import 'package:my_voice_chat_gpt/setting_components/setting_notifier.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_widget.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_data.dart';
import 'package:my_voice_chat_gpt/shared_components/global_variables.dart';
import 'package:my_voice_chat_gpt/shared_components/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

import 'file_io.dart';

void main() async {
  var settingData = (await readJson("settings.json")) ?? SettingData();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeNotifier()),
        ChangeNotifierProvider.value(value: SettingNotifier(settingData))
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Voice and Chat with GPT',
      theme: themeNotifier.getTheme(),
      home: const MyHomePage(title: 'Voice ChatGPT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<chatType.Message> _messages = [];
  final SpeechToText _speechToText = SpeechToText();
  final bool _speechEnabled = false;
  String _lastWords = '';
  final _user = const chatType.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _bot = const chatType.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3aa');

  SettingData _settingData = SettingData();

  final TextEditingController _pauseForController =
      TextEditingController(text: '3');
  final TextEditingController _listenForController =
      TextEditingController(text: '5');
  final TextEditingController _messageTextEditController =
      TextEditingController();
  final List<LocaleName> _localeNames = [];

  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  double level = 0.0;

  Future microPhoneReq() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (await Permission.microphone.isGranted == false) {
      await Permission.microphone.request();
    }
    //WebViewMethodForCamera();
  }

  @override
  void initState() {
    super.initState();
    initSpeechState();
    _loadMessages();
  }

  void initSetting() async {
    _settingData = (await readJson("settings.json")) ?? SettingData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _saveMessages();
  }

  void _handleSendPressed(chatType.PartialText message) {
    _createTextMessage(message.text, _user);
  }

  void _createTextMessage(String text, chatType.User user) {
    final textMessage = chatType.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    _addMessage(textMessage);
    _saveMessages();
  }

  void _addMessage(chatType.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> initSpeechState() async {
    try {
      var hasSpeech = await _speechToText.initialize();
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        MyGlobalStorage.speechLocaleNames = await _speechToText.locales();
        _settingData.speechLanguage ??= await _speechToText.systemLocale();
        setState(() {});
      }
      if (!mounted) return;
    } catch (e) {}
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await microPhoneReq();
    _lastWords = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    // Note that `listenFor` is the maximum, not the minimun, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      partialResults: true,
      onSoundLevelChange: soundLevelListener,
      localeId: _settingData.speechLanguage?.localeId ?? '',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();

    _messageTextEditController.text = _lastWords;
    //_createTextMessage(_lastWords);
    setState(() {
      level = 0.0;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _messageTextEditController.text = _lastWords;
    });
  }

  void cancelListening() {
    _speechToText.cancel();
    _messageTextEditController.text = _lastWords;
    setState(() {
      level = 0.0;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void _loadMessages() async {
    final messages = await readJsonList(
      'messages.json',
      onMapping: (map) => chatType.Message.fromJson(map),
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
                onPressed: () {},
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
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline_rounded)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return !_speechToText.isAvailable
        ? const Scaffold(
            body: Center(child: Text("Loading")),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: Scaffold.of(context).openEndDrawer,
                  ),
                ),
              ],
            ),
            body: Center(
              child: SizedBox(
                width: window.physicalSize.width,
                height: window.physicalSize.height,
                child: Column(
                  children: <Widget>[
                    Flexible(
                        child: Chat(
                      bubbleBuilder: _bubbleBuilder,
                      messages: _messages,
                      onSendPressed: _handleSendPressed,
                      user: _user,
                      inputOptions: InputOptions(
                          textEditingController: _messageTextEditController),
                    )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: .26,
                                spreadRadius: level * 1.5,
                                color: Colors.black.withOpacity(.05))
                          ],
                          color: Colors.amber,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: _speechToText.isNotListening
                              ? _startListening
                              : _stopListening,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            endDrawer: SizedBox(
              width: min(window.physicalSize.width, 400),
              child: Drawer(
                child: SettingWidget(
                  settingData: _settingData,
                ),
              ),
            ));
  }
}
