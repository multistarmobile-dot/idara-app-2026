import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Download ki hui surtain phone mein save hoti hain (offline reading).
class QuranCache {
  Future<File> _file(String key) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/quran_cache');
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
