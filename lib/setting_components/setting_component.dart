import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:my_voice_chat_gpt/setting_components/setting_data.dart';

import '../shared_components/global_variables.dart';
import '../shared_components/text_with_tooltip.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key, required this.settingData});
  final SettingData settingData;
  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  SettingData get _settingData => widget.settingData;
  var speechLocaleNames = MyGlobalStorage.speechLocaleNames;
  Widget buildSwitchButton(Function() toggleButtonClicked) {
    return FlutterSwitch(
      activeColor: Colors.black54,
      width: 40,
      height: 20,
      borderRadius: 25.0,
      toggleSize: 15,
      padding: 4.0,
      value: _settingData.autoTTS,
      onToggle: (bool value) {
        setState(toggleButtonClicked);
      },
    );
  }

  late List<DropdownMenuItem<String>> cacheDropdownItems;
  @override
  void initState() {
    super.initState();
    cacheDropdownItems = speechLocaleNames
        .map((e) => DropdownMenuItem<String>(
              value: e.localeId,
              child: Text(e.name),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: FractionallySizedBox(
            heightFactor: 0.8,
            widthFactor: 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWithTooltip(
                      text: "Auto TTS",
                      tooltip: "Auto speak the message for you",
                    ),
                    buildSwitchButton(
                        () => _settingData.autoTTS = !_settingData.autoTTS),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextWithTooltip(
                        text: "Speech Language",
                        tooltip:
                            "Choose a lanaguage to communicate with ChatGPT",
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      speechLocaleNames.isEmpty
                          ? const Text("No Langauge supported")
                          : Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                onChanged: (selectedVal) {
                                  setState(() {
                                    _settingData.speechLanguage =
                                        speechLocaleNames.firstWhere(
                                            (element) =>
                                                element.localeId ==
                                                selectedVal);
                                  });
                                },
                                value: _settingData.speechLanguage?.localeId,
                                items: cacheDropdownItems,
                                hint: const Text('Select a language'),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}