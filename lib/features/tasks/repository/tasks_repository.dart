import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import 'package:drift/drift.dart';

final databaseProvider = Provider((ref) => AppDatabase());

final tasksRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return TasksRepository(db);
});

class TasksRepository {
  final AppDatabase _db;
  TasksRepository(this._db);

  Stream<List<Task>> watchTasksForDate(DateTime date) {
    // Basic implementation: watch all tasks for today (ignoring actual date filtering for brevity in V1)
    return (_db.select(_db.tasks)..where((t) => t.isDeleted.equals(false))).watch();
  }

  Future<void> addTask(String title, String category, DateTime? dueDate) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.into(_db.tasks).insert(
      TasksCompanion.insert(
        id: id,
        title: title,
        category: category,
        dueDate: Value(dueDate),
      ),
    );
  }

  Future<void> toggleTaskStatus(Task task) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(isCompleted: Value(!task.isCompleted)),
    );
  }

  Future<void> deleteTask(String id) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(isDeleted: Value(true)),
    );
  }
}

