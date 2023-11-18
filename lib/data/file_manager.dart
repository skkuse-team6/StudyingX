import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studyingx/views/pages/note_page.dart';
import 'package:studyingx/data/prefs.dart';
import 'package:studyingx/views/molecules/preview_card.dart';

/// A collection of cross-platform utility functions for working with a virtual file system.
class FileManager {
  // disable constructor
  FileManager._();

  static final log = Logger('FileManager');

  static const String appRootDirectoryPrefix = 'StudyingX';
  @visibleForTesting
  static Future<String> get documentsDirectory async =>
      '${(await getApplicationDocumentsDirectory()).path}/$appRootDirectoryPrefix';

  static final StreamController<FileOperation> fileWriteStream =
      StreamController.broadcast(
    onListen: () => _fileWriteStreamIsListening = true,
    onCancel: () => _fileWriteStreamIsListening = false,
  );
  static bool _fileWriteStreamIsListening = false;

  static String _sanitisePath(String path) => File(path).path;

  static Future<void> init() async {
    await watchRootDirectory();
  }

  @visibleForTesting
  static Future<void> watchRootDirectory() async {
    Directory rootDir = Directory(await documentsDirectory);
    await rootDir.create(recursive: true);
    rootDir.watch(recursive: true).listen((FileSystemEvent event) {
      final type = event.type == FileSystemEvent.create ||
              event.type == FileSystemEvent.modify ||
              event.type == FileSystemEvent.move
          ? FileOperationType.write
          : FileOperationType.delete;
      String path =
          event.path.replaceAll('\\', '/').replaceFirst(rootDir.path, '');
      broadcastFileWrite(type, path);
    });
  }

  @visibleForTesting
  static void broadcastFileWrite(FileOperationType type, String path) async {
    if (!_fileWriteStreamIsListening) return;

    fileWriteStream.add(FileOperation(type, path));
  }

  /// Returns the contents of the file at [filePath].
  static Future<Uint8List?> readFile(String filePath, {int retries = 3}) async {
    filePath = _sanitisePath(filePath);

    Uint8List? result;
    final File file = File(await documentsDirectory + filePath);
    if (file.existsSync()) {
      result = await file.readAsBytes();
      if (result.isEmpty) result = null;
    } else {
      retries = 0; // don't retry if the file doesn't exist
    }

    // If result is null, try again in case the file was locked.
    if (result == null && retries > 0) {
      await Future.delayed(const Duration(milliseconds: 100));
      return readFile(filePath, retries: retries - 1);
    }
    return result;
  }

  /// Writes [toWrite] to [filePath].
  static Future<void> writeFile(String filePath, List<int> toWrite,
      {bool awaitWrite = false}) async {
    filePath = _sanitisePath(filePath);
    log.fine('Writing to $filePath');

    await _saveFileAsRecentlyAccessed(filePath);

    final documentsDirectory = await FileManager.documentsDirectory;
    final File file = File('$documentsDirectory$filePath');
    await _createFileDirectory(filePath);
    Future writeFuture = Future.wait([
      file.writeAsBytes(toWrite),
    ]);

    void afterWrite() {
      broadcastFileWrite(FileOperationType.write, filePath);
    }

    writeFuture = writeFuture.then((_) => afterWrite());
    if (awaitWrite) await writeFuture;
  }

  static Future<String> moveFile(String fromPath, String toPath,
      [bool replaceExistingFile = false]) async {
    fromPath = _sanitisePath(fromPath);
    toPath = _sanitisePath(toPath);

    if (!toPath.contains('/')) {
      toPath = fromPath.substring(0, fromPath.lastIndexOf('/') + 1) + toPath;
    }

    if (!replaceExistingFile) {
      toPath = await suffixFilePathToMakeItUnique(toPath, fromPath);
    }

    if (fromPath == toPath) return toPath;

    final File fromFile = File(await documentsDirectory + fromPath);
    final File toFile = File(await documentsDirectory + toPath);
    await _createFileDirectory(toPath);
    if (fromFile.existsSync()) {
      await fromFile.rename(toFile.path);
    } else {
      log.warning('Tried to move non-existent file from $fromPath to $toPath');
    }

    _renameReferences(fromPath, toPath);
    broadcastFileWrite(FileOperationType.delete, fromPath);
    broadcastFileWrite(FileOperationType.write, toPath);

    return toPath;
  }

  static Future deleteFile(String filePath) async {
    filePath = _sanitisePath(filePath);

    final File file = File(await documentsDirectory + filePath);
    if (!file.existsSync()) return;
    await file.delete();

    _removeReferences(filePath);
    broadcastFileWrite(FileOperationType.delete, filePath);
  }

  static Future<List<String>> getRecentlyAccessed() async {
    await Prefs.recentFiles.waitUntilLoaded();
    return Prefs.recentFiles.value.map((String filePath) {
      if (filePath.endsWith(NotePage.extension)) {
        return filePath.substring(
            0, filePath.length - NotePage.extension.length);
      } else {
        return filePath;
      }
    }).toList();
  }

  static Future<bool> doesFileExist(String filePath) async {
    filePath = _sanitisePath(filePath);
    final File file = File(await documentsDirectory + filePath);
    return file.existsSync();
  }

  static Future<DateTime> lastModified(String filePath) async {
    filePath = _sanitisePath(filePath);
    final File file = File(await documentsDirectory + filePath);
    return file.lastModifiedSync();
  }

  static Future<String> newFilePath([String parentPath = '/']) async {
    assert(parentPath.endsWith('/'));

    final DateTime now = DateTime.now();
    final String filePath = '$parentPath${DateFormat("yy-MM-dd").format(now)} '
        'Untitled'
        '${NotePage.extension}';

    return await suffixFilePathToMakeItUnique(filePath);
  }

  /// Returns a unique file path by appending a number to the end of the [filePath].
  /// e.g. "/Untitled" -> "/Untitled (2)"
  ///
  /// Providing a [currentPath] means that e.g. "/Untitled (2)" being renamed
  /// to "/Untitled" will be returned as "/Untitled (2)" not "/Untitled (3)".
  ///
  /// If [currentPath] is provided, it must
  /// end with [Editor.extension] or [Editor.extensionOldJson].
  static Future<String> suffixFilePathToMakeItUnique(String filePath,
      [String? currentPath]) async {
    String newFilePath = filePath;
    bool hasExtension = false;

    if (filePath.endsWith(NotePage.extension)) {
      filePath =
          filePath.substring(0, filePath.length - NotePage.extension.length);
      newFilePath = filePath;
      hasExtension = true;
    }

    int i = 1;
    while (true) {
      if (!await doesFileExist(newFilePath + NotePage.extension)) break;
      if (newFilePath + NotePage.extension == currentPath) break;
      i++;
      newFilePath = '$filePath ($i)';
    }

    return newFilePath + (hasExtension ? NotePage.extension : '');
  }

  /// Creates the parent directories of filePath if they don't exist.
  static Future _createFileDirectory(String filePath) async {
    assert(filePath.contains('/'), 'filePath must be a path, not a file name');
    final String parentDirectory =
        filePath.substring(0, filePath.lastIndexOf('/'));
    await Directory(await documentsDirectory + parentDirectory)
        .create(recursive: true);
  }

  static Future _renameReferences(String fromPath, String toPath) async {
    PreviewCard.moveFileInCache(fromPath, toPath);

    // rename file in recently accessed
    bool replaced = false;
    for (int i = 0; i < Prefs.recentFiles.value.length; i++) {
      if (Prefs.recentFiles.value[i] != fromPath) continue;
      if (!replaced) {
        Prefs.recentFiles.value[i] = toPath;
        replaced = true;
      } else {
        Prefs.recentFiles.value.removeAt(i);
      }
    }
    Prefs.recentFiles.notifyListeners();
  }

  static Future _removeReferences(String filePath) async {
    for (int i = 0; i < Prefs.recentFiles.value.length; i++) {
      if (Prefs.recentFiles.value[i] != filePath) continue;
      Prefs.recentFiles.value.removeAt(i);
    }
    Prefs.recentFiles.notifyListeners();
  }

  static Future _saveFileAsRecentlyAccessed(String filePath) async {
    Prefs.recentFiles.value.remove(filePath);
    Prefs.recentFiles.value.insert(0, filePath);
    if (Prefs.recentFiles.value.length > maxRecentlyAccessedFiles) {
      Prefs.recentFiles.value.removeLast();
    }
    Prefs.recentFiles.notifyListeners();
  }

  static const int maxRecentlyAccessedFiles = 40;
}

enum FileOperationType {
  write,
  delete,
}

class FileOperation {
  final FileOperationType type;
  final String filePath;

  const FileOperation(this.type, this.filePath);
}
