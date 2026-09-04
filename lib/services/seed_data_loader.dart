import 'dart:convert';
import 'package:flutter/services.dart';

class SeedDataLoader {
  static Future<List<dynamic>> loadJsonAsset(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      print('Error loading asset $assetPath: $e');
      return [];
    }
  }
}
