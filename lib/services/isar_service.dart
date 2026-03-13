import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/special_day.dart';

/// Singleton service managing all Isar database operations for [SpecialDay].
///
/// Provides CRUD methods and returns lists sorted by [daysRemaining].
class IsarService {
  static IsarService? _instance;
  late Isar _isar;

  IsarService._();

  /// Returns the singleton instance — call [init] first.
  static IsarService get instance {
    if (_instance == null) {
      throw StateError('IsarService not initialized. Call init() first.');
    }
    return _instance!;
  }

  /// Initializes the Isar database. Must be called once at app startup.
  static Future<IsarService> init() async {
    if (_instance != null) return _instance!;

    final service = IsarService._();
    final dir = await getApplicationDocumentsDirectory();

    service._isar = await Isar.open(
      [SpecialDaySchema],
      directory: dir.path,
      name: 'neverforget',
    );

    _instance = service;
    return service;
  }

  /// Returns all special days sorted by closest upcoming date.
  Future<List<SpecialDay>> getAllSortedByUpcoming() async {
    final days = await _isar.specialDays.where().findAll();

    // Sort in Dart by the computed daysRemaining property
    days.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return days;
  }

  /// Adds a new special day and returns its auto-generated ID.
  Future<int> addSpecialDay(SpecialDay day) async {
    return _isar.writeTxn(() => _isar.specialDays.put(day));
  }

  /// Updates an existing special day (uses same put method with existing ID).
  Future<int> updateSpecialDay(SpecialDay day) async {
    return _isar.writeTxn(() => _isar.specialDays.put(day));
  }

  /// Deletes a special day by its ID.
  Future<bool> deleteSpecialDay(int id) async {
    return _isar.writeTxn(() => _isar.specialDays.delete(id));
  }

  /// Returns a single special day by ID, or null if not found.
  Future<SpecialDay?> getById(int id) async {
    return _isar.specialDays.get(id);
  }

  /// Returns the total count of special days.
  Future<int> count() async {
    return _isar.specialDays.count();
  }

  /// Watches the collection for changes and calls [onChange] with updated list.
  Stream<List<SpecialDay>> watchAll() {
    return _isar.specialDays.watchLazy().asyncMap((_) => getAllSortedByUpcoming());
  }

  /// Closes the database. Call on app dispose if needed.
  Future<void> close() async {
    await _isar.close();
    _instance = null;
  }
}
