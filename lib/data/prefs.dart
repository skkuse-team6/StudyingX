import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Prefs {
  static final log = Logger('Prefs');

  @visibleForTesting
  static bool warnIfPrefAccessedBeforeLoaded = true;

  static late final PlainPref<List<String>> recentFiles;

  static void init() {
    recentFiles = PlainPref('recentFiles', [],
        historicalKeys: const ['recentlyAccessed']);
  }
}

abstract class IPref<T> extends ValueNotifier<T> {
  final String key;
  final List<String> historicalKeys;
  final List<String> deprecatedKeys;

  final T defaultValue;

  bool _loaded = false;

  @protected
  bool _saved = true;

  IPref(
    this.key,
    this.defaultValue, {
    List<String>? historicalKeys,
    List<String>? deprecatedKeys,
  })  : historicalKeys = historicalKeys ?? [],
        deprecatedKeys = deprecatedKeys ?? [],
        super(defaultValue) {
    _load().then((T? loadedValue) {
      _loaded = true;
      if (loadedValue != null) {
        value = loadedValue;
      }
      _afterLoad();
      addListener(_save);
    });
  }

  Future<T?> _load();
  Future<void> _afterLoad();
  Future<void> _save();
  @protected
  Future<T?> getValueWithKey(String key);

  @visibleForTesting
  Future<void> delete();

  @override
  T get value {
    if (!loaded && Prefs.warnIfPrefAccessedBeforeLoaded) {
      Prefs.log.warning("Pref '$key' accessed before it was loaded.");
    }
    return super.value;
  }

  bool get loaded => _loaded;
  bool get saved => _saved;

  Future<void> waitUntilLoaded() async {
    while (!loaded) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  @visibleForTesting
  Future<void> waitUntilSaved() async {
    while (!saved) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  @override
  void notifyListeners() => super.notifyListeners();
}

class PlainPref<T> extends IPref<T> {
  SharedPreferences? _prefs;

  PlainPref(super.key, super.defaultValue,
      {super.historicalKeys, super.deprecatedKeys}) {
    assert(T == bool ||
        T == int ||
        T == double ||
        T == String ||
        T == typeOf<Uint8List?>() ||
        T == typeOf<List<String>>() ||
        T == typeOf<Set<String>>() ||
        T == typeOf<Queue<String>>() ||
        T == TargetPlatform);
  }

  @override
  Future<T?> _load() async {
    _prefs ??= await SharedPreferences.getInstance();

    T? currentValue = await getValueWithKey(key);
    if (currentValue != null) return currentValue;

    for (String historicalKey in historicalKeys) {
      currentValue = await getValueWithKey(historicalKey);
      if (currentValue == null) continue;

      await _save();
      _prefs!.remove(historicalKey);

      return currentValue;
    }

    for (String deprecatedKey in deprecatedKeys) {
      _prefs!.remove(deprecatedKey);
    }

    return null;
  }

  @override
  Future<void> _afterLoad() async {
    _prefs = null;
  }

  @override
  Future _save() async {
    _saved = false;
    try {
      _prefs ??= await SharedPreferences.getInstance();

      if (T == bool) {
        return await _prefs!.setBool(key, value as bool);
      } else if (T == int) {
        return await _prefs!.setInt(key, value as int);
      } else if (T == double) {
        return await _prefs!.setDouble(key, value as double);
      } else if (T == typeOf<Uint8List?>()) {
        Uint8List? bytes = value as Uint8List?;
        if (bytes == null) {
          return await _prefs!.remove(key);
        } else {
          return await _prefs!.setString(key, base64Encode(bytes));
        }
      } else if (T == typeOf<List<String>>()) {
        return await _prefs!.setStringList(key, value as List<String>);
      } else if (T == typeOf<Set<String>>()) {
        return await _prefs!
            .setStringList(key, (value as Set<String>).toList());
      } else if (T == typeOf<Queue<String>>()) {
        return await _prefs!
            .setStringList(key, (value as Queue<String>).toList());
      } else if (T == TargetPlatform) {
        return await _prefs!.setInt(key, (value as TargetPlatform).index);
      } else {
        return await _prefs!.setString(key, value as String);
      }
    } finally {
      _saved = true;
    }
  }

  @override
  Future<T?> getValueWithKey(String key) async {
    try {
      if (!_prefs!.containsKey(key)) {
        return null;
      } else if (T == typeOf<Uint8List?>()) {
        String? base64 = _prefs!.getString(key);
        if (base64 == null) return null;
        return base64Decode(base64) as T;
      } else if (T == typeOf<List<String>>()) {
        return _prefs!.getStringList(key) as T?;
      } else if (T == typeOf<Set<String>>()) {
        return _prefs!.getStringList(key)?.toSet() as T?;
      } else if (T == typeOf<Queue<String>>()) {
        List? list = _prefs!.getStringList(key);
        return list != null ? Queue<String>.from(list) as T : null;
      } else if (T == TargetPlatform) {
        final index = _prefs!.getInt(key);
        if (index == null) return null;
        if (index == -1) return defaultTargetPlatform as T?;
        return TargetPlatform.values[index] as T?;
      } else {
        return _prefs!.get(key) as T?;
      }
    } catch (e) {
      Prefs.log.severe('Error loading $key: $e', e);
      return null;
    }
  }

  @override
  Future<void> delete() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(key);
  }
}

class TransformedPref<T_in, T_out> extends IPref<T_out> {
  final IPref<T_in> pref;
  final T_out Function(T_in) transform;
  final T_in Function(T_out) reverseTransform;

  @override
  T_out get value => transform(pref.value);

  @override
  set value(T_out value) => pref.value = reverseTransform(value);

  @override
  bool get loaded => pref.loaded;

  @override
  bool get saved => pref.saved;

  TransformedPref(this.pref, this.transform, this.reverseTransform)
      : super(pref.key, transform(pref.defaultValue)) {
    pref.addListener(notifyListeners);
  }

  @override
  Future<void> _afterLoad() async {}

  @override
  Future<T_out?> _load() async => null;

  @override
  Future<void> _save() async {}

  @override
  Future<void> delete() async {}

  @override
  Future<T_out?> getValueWithKey(String key) async => null;
}

Type typeOf<T>() => T;
