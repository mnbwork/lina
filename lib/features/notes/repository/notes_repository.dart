import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../tasks/repository/tasks_repository.dart'; // To get databaseProvider
import 'package:drift/drift.dart';

final notesRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return NotesRepository(db);
});

class NotesRepository {
  final AppDatabase _db;
  NotesRepository(this._db);

  Stream<List<Note>> watchAllNotes() {
    return (_db.select(_db.notes)..where((n) => n.isDeleted.equals(false))).watch();
  }

  Future<void> addNote(String title, String content, String? tags) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.into(_db.notes).insert(
      NotesCompanion.insert(
        id: id,
        title: title,
        content: content,
        tags: Value(tags),
      ),
    );
  }

  Future<void> updateNote(String id, String title, String content) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        title: Value(title),
        content: Value(content),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteNote(String id) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      const NotesCompanion(isDeleted: Value(true)),
    );
  }
}

