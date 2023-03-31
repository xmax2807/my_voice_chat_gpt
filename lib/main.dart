import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chatType;
import 'package:my_voice_chat_gpt/setting_components/setting_component.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice and Chat with GPT',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
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
  final SettingData _settingData = SettingData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  messages: const [],
                  onSendPressed: (send) {},
                  user: const chatType.User(id: "1"),
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
                            color: Colors.black.withOpacity(.05))
                      ],
                      color: Colors.amber,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: IconButton(
                        icon: const Icon(Icons.mic), onPressed: () {}),
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
