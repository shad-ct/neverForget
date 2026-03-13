import 'package:isar/isar.dart';

part 'special_day.g.dart';

/// Isar collection representing a Special Day reminder.
@collection
class SpecialDay {
  Id id = Isar.autoIncrement;

  late String title;
  late DateTime date;
  late String category;
  late String emoji;
  late bool isCustom;

  /// Contact phone number (optional).
  String? contact;

  /// Computes days remaining until next occurrence.
  @ignore
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next.difference(today).inDays;
  }

  /// Next occurrence DateTime.
  @ignore
  DateTime get nextOccurrence {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next;
  }

  /// Age breakdown: years, months, and days since birth date.
  @ignore
  ({int years, int months, int days}) get age {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int years = today.year - date.year;
    int months = today.month - date.month;
    int days = today.day - date.day;

    if (days < 0) {
      months--;
      // Days in the previous month
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return (years: years, months: months, days: days);
  }

  /// Formatted age string (e.g., "18y 5m 12d").
  @ignore
  String get ageFormatted {
    final a = age;
    return '${a.years}y ${a.months}m ${a.days}d';
  }
}
