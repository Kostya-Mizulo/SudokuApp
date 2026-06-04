import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Manages the `active_session.json` file in the app's local storage.
///
/// The file stores a single active (unfinished) game session as JSON.
/// It is created on first write; there is no bundled asset to copy.
class ActiveSessionStorageService {
  static const String _fileName = 'active_session.json';

  static Future<File> getFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_fileName');
  }
}
