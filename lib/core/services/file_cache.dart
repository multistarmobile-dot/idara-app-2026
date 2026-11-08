import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Download kiya hua data phone mein save hota hai (offline use).
class FileCache {
  Future<File> _file(String key) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/app_cache');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File('${folder.path}/$key.json');
  }

  Future<String?> read(String key) async {
    try {
      final f = await _file(key);
      if (await f.exists()) return await f.readAsString();
    } catch (_) {}
    return null;
  }

  Future<void> write(String key, String value) async {
    try {
      final f = await _file(key);
      await f.writeAsString(value);
    } catch (_) {}
  }
}
