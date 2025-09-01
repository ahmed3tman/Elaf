import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Singleton-style repository to load and cache the Quran page mapping JSON once
/// and share it across the app. This prevents showing a loader the first time
/// the Mushaf screen opens.
class PageMappingRepository {
  static Map<int, List<Map<String, dynamic>>>? _cache;
  static Future<Map<int, List<Map<String, dynamic>>>>? _loading;

  /// Returns the cached mapping if already loaded.
  static Map<int, List<Map<String, dynamic>>>? get cache => _cache;

  /// Ensure the mapping is loaded. If a load is in progress it returns the same Future.
  static Future<Map<int, List<Map<String, dynamic>>>> ensureLoaded() {
    if (_cache != null) {
      return SynchronousFuture(_cache!);
    }
    if (_loading != null) {
      return _loading!;
    }
    _loading = _loadMapping();
    return _loading!;
  }

  static Future<Map<int, List<Map<String, dynamic>>>> _loadMapping() async {
    final raw = await rootBundle.loadString(
      'assets/json/quran_page_mapping.json',
    );
    final parsed = await compute<String, Map<int, List<Map<String, dynamic>>>>(
      _parsePageMappingFromRaw,
      raw,
    );
    _cache = parsed;
    return parsed;
  }
}

// Top-level function for compute() to parse mapping on a background isolate.
Map<int, List<Map<String, dynamic>>> _parsePageMappingFromRaw(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return decoded.map(
    (k, v) =>
        MapEntry(int.parse(k), List<Map<String, dynamic>>.from(v as List)),
  );
}
