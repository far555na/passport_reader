import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a loaded map of CSCA certificates for instant trust chain verification.
/// The key is the Base64-encoded Subject, and the value is the Base64-encoded Certificate.
final cscaIndexProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  try {
    final jsonString = await rootBundle.loadString('assets/csca_index.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map((key, value) {
      final list = (value as List).map((e) => e.toString()).toList();
      return MapEntry(key, list);
    });
  } catch (e) {
    debugPrint('Error loading CSCA index: $e');
    return {};
  }
});
