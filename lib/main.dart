import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_voice_chat_gpt/chat_components/my_chat_widget.dart';
import 'package:my_voice_chat_gpt/chat_components/text_to_speech.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_notifier.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_widget.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_data.dart';
import 'package:my_voice_chat_gpt/shared_components/theme.dart';
import 'package:my_voice_chat_gpt/speech_to_text_components/speech_to_text_provider.dart';
import 'package:my_voice_chat_gpt/speech_to_text_components/speech_to_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//import 'dart:developer' as dev;

Future<void> _ensureScreenSize(window) async {
  return window.viewConfiguration.geometry.isEmpty
      ? Future.delayed(
          const Duration(milliseconds: 10), () => _ensureScreenSize(window))
      : Future.value();
}

void main() async {
  final window = WidgetsFlutterBinding.ensureInitialized().window;
  await _ensureScreenSize(window);
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyTTS()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => SettingNotifier()),
        ChangeNotifierProvider(create: (context) => SpeechToTextProvider()),
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

class _MyHomePageState extends State<MyHomePage> {
  SettingData get _settingData => SettingData.Instance;
  @override
  void initState() {
    super.initState();
    SettingData.initialize().whenComplete(() {
      Provider.of<ThemeNotifier>(context, listen: false)
          .switchTheme(_settingData.appLightTheme);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return !SettingData.isInitialized
        ? const Scaffold(
            body: Text("Loading Setting"),
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
                  children: const <Widget>[
                    Flexible(
                      child: MyChatWidget(),
                    ),
                    SpeechToTextWidget()
                  ],
                ),
              ),
            ),
            endDrawer: SizedBox(
              width: min(window.physicalSize.width, 400),
              child: const Drawer(
                child: SettingWidget(),
              ),
            ));
  }
}
