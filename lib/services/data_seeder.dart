import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../models/special_day.dart';
import 'isar_service.dart';

/// Seeds the Isar database from the bundled data.json file.
class DataSeeder {
  /// Imports all entries from data.json into Isar.
  /// Skips if the DB already has data (idempotent).
  static Future<int> seedFromJson({bool force = false}) async {
    final isar = IsarService.instance;
    final existing = await isar.count();

    if (existing > 0 && !force) {
      debugPrint('[DataSeeder] DB already has $existing entries, skipping seed.');
      return 0;
    }

    debugPrint('[DataSeeder] Seeding database from data.json...');

    try {
      final jsonString = await rootBundle.loadString('lib/models/data.json');
      final List<dynamic> entries = json.decode(jsonString);
      final dateFormat = DateFormat('dd/MM/yyyy');
      int imported = 0;

      for (final entry in entries) {
        try {
          final name = entry['name'] as String? ?? '';
          final dobStr = entry['dob'] as String? ?? '';

          if (name.isEmpty || dobStr.isEmpty) continue;

          final dob = dateFormat.parse(dobStr);

          // Detect category from name
          String category = 'Birthday';
          String emoji = '🎂';
          bool isCustom = false;

          final nameLower = name.toLowerCase();
          if (nameLower.contains('anniversary') ||
              nameLower.contains('wedding')) {
            category = 'Anniversary';
            emoji = '💍';
          } else if (nameLower.contains('passed away') ||
              nameLower.contains('memorial')) {
            category = 'Memorial';
            emoji = '🕯️';
            isCustom = true;
          }

          final day = SpecialDay()
            ..title = name
            ..date = dob
            ..category = category
            ..emoji = emoji
            ..isCustom = isCustom
            ..contact = entry['contact'] as String?;

          await isar.addSpecialDay(day);
          imported++;
        } catch (e) {
          debugPrint('[DataSeeder] Skipping entry: $e');
          continue;
        }
      }

      debugPrint('[DataSeeder] ✅ Imported $imported entries.');
      return imported;
    } catch (e) {
      debugPrint('[DataSeeder] ❌ Failed to seed: $e');
      return 0;
    }
  }
}
