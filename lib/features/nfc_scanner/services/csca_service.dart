import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/csca_data.dart';

part 'csca_service.g.dart';

@Riverpod(keepAlive: true)
CscaService cscaService(Ref ref) {
  return CscaService();
}

class CscaService {
  /// Loads and parses the CSCA certificates from the asset bundle.
  Future<CscaData> loadCscaData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/csca_index.json');
      final map = await compute(_parseCscaIndex, jsonString);
      return CscaData(map);
    } catch (e) {
      debugPrint('Error loading CSCA index: $e');
      return CscaData({});
    }
  }
}

Map<String, List<String>> _parseCscaIndex(String jsonString) {
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return jsonMap.map((key, value) {
    final list = (value as List).map((e) => e.toString()).toList();
    return MapEntry(key, list);
  });
}
