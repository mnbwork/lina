import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../tasks/repository/tasks_repository.dart'; // To get databaseProvider
import 'package:drift/drift.dart';

final habitsRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return HabitsRepository(db);
});

class HabitsRepository {
  final AppDatabase _db;
  HabitsRepository(this._db);

  Stream<List<Habit>> watchAllHabits() {
    return (_db.select(_db.habits)..where((h) => h.isDeleted.equals(false))).watch();
  }

  Future<void> addHabit(String name, String category) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.into(_db.habits).insert(
      HabitsCompanion.insert(
        id: id,
        name: name,
        category: category,
      ),
    );
  }

  Stream<List<HabitLog>> watchLogsForToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.habitLogs)
          ..where((l) => l.date.isBiggerOrEqualValue(startOfDay))
          ..where((l) => l.date.isSmallerThanValue(endOfDay)))
        .watch();
  }

  Future<void> toggleHabitForToday(String habitId, bool isCompleted) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    // Check if log exists for today
    final existingLog = await (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId))
          ..where((l) => l.date.isBiggerOrEqualValue(startOfDay)))
        .getSingleOrNull();

    if (existingLog != null) {
      if (!isCompleted) {
        // Remove the log if untoggled
        await (_db.delete(_db.habitLogs)..where((l) => l.id.equals(existingLog.id))).go();
      }
    } else if (isCompleted) {
      // Add new log
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _db.into(_db.habitLogs).insert(
        HabitLogsCompanion.insert(
          id: id,
          habitId: habitId,
          date: today,
          status: 'Completed',
        ),
      );
    }
  }
}

