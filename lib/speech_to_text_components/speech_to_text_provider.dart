import 'package:flutter/cupertino.dart';

class SpeechToTextProvider with ChangeNotifier {
  String _speechResult = '';
  String get speechResult => _speechResult;

  void updateText(String text) {
    _speechResult = text;
    notifyListeners();
  }
}
