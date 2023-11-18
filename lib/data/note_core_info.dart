import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:bson/bson.dart';
import 'package:studyingx/views/fragments/note_drawer.dart';
import 'package:studyingx/data/file_manager.dart';
import 'package:studyingx/views/pages/note_page.dart';

class NoteCoreInfo {
  static final log = Logger('NoteCoreInfo');

  String filePath;
  NoteDrawer page;
  Uint8List screenshot;

  static final empty = NoteCoreInfo._(
    filePath: '',
    page: const NoteDrawer(),
    screenshot: Uint8List(0),
  );

  bool get isEmpty => page.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool captured = false;

  NoteCoreInfo({
    required this.filePath,
  })  : page = NoteDrawer(
          path: filePath,
        ),
        screenshot = Uint8List(0),
        captured = false;

  NoteCoreInfo._({
    required this.filePath,
    required this.page,
    required this.screenshot,
  });

  static Future<NoteCoreInfo> loadFromFilePath(String path) async {
    if (!path.endsWith(NotePage.extension)) {
      path = path + NotePage.extension;
    }
    final bsonBytes = await FileManager.readFile(path);

    if (bsonBytes == null) {
      return NoteCoreInfo(filePath: path);
    }

    return loadFromFileContents(
      bsonBytes: bsonBytes,
      path: path,
    );
  }

  @visibleForTesting
  static Future<NoteCoreInfo> loadFromFileContents({
    Uint8List? bsonBytes,
    required String path,
  }) async {
    NoteCoreInfo coreInfo;
    try {
      NoteCoreInfo isolate() => _loadFromFileIsolate(
            bsonBytes,
            path,
          );

      coreInfo = isolate();
    } catch (e) {
      log.severe('Failed to load file from $path: $e', e);
      if (kDebugMode) {
        rethrow;
      } else {
        coreInfo = NoteCoreInfo(filePath: path);
      }
    }

    return coreInfo;
  }

  static NoteCoreInfo _loadFromFileIsolate(
    Uint8List? bsonBytes,
    String path,
  ) {
    final dynamic json;
    try {
      if (bsonBytes != null) {
        final bsonBinary = BsonBinary.from(bsonBytes);
        json = BSON().deserialize(bsonBinary);
      } else {
        throw ArgumentError('Both bsonBytes and jsonString are null');
      }
    } catch (e) {
      log.severe('Failed to parse file from $path: $e', e);
      rethrow;
    }

    if (json == null) {
      throw Exception('Failed to parse json from $path');
    } else {
      return NoteCoreInfo.fromJson(
        json as Map<String, dynamic>,
        filePath: path,
      );
    }
  }

  Uint8List serializeToBSON() {
    final bson = BSON();
    final json = toJson();
    final bsonBinary = bson.serialize(json);
    return bsonBinary.byteList;
  }

  factory NoteCoreInfo.fromJson(
    Map<String, dynamic> json, {
    required String filePath,
  }) {
    return NoteCoreInfo._(
      filePath: filePath,
      page: NoteDrawer.fromJson(json['p'] as Map<String, dynamic>),
      screenshot: (json['s'] as BsonBinary).byteList,
    )..captured = json['c'] as bool;
  }

  Map<String, dynamic> toJson() {
    final List<Uint8List> assets = [];

    final json = {
      'p': page.toJson(assets),
      's': BsonBinary.from(screenshot),
      'c': captured,
    };

    json['a'] =
        assets.map((Uint8List asset) => BsonBinary.from(asset)).toList();
    return json;
  }
}
