import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> getFile(String fileName) async {
  final path = await _localPath;
  return File('$path/$fileName');
}

Future<File> writeJson<T>(T object, String fileName) async {
  final file = await getFile(fileName);
  String json = jsonEncode(object);
  // Write the file
  return file.writeAsString(json);
}

Future<T?> readJson<T>(String fileName) async {
  try {
    final file = await getFile(fileName);

    // Read the file
    final contents = await file.readAsString();

    return jsonDecode(contents);
  } catch (e) {
    // If encountering an error, return 0
    return null;
  }
}

Future<List<T>?> readJsonList<T>(String fileName,
    {required T Function(Map<String, dynamic>) onMapping}) async {
  try {
    final file = await getFile(fileName);
    final contents = await file.readAsString();

    final listJson = jsonDecode(contents) as List;
    return listJson.map((e) => onMapping(e as Map<String, dynamic>)).toList();
  } catch (e) {
    return null;
  }
}
