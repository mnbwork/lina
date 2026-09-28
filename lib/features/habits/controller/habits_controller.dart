import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../repository/habits_repository.dart';

final habitsProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.watchAllHabits();
});

final todayHabitLogsProvider = StreamProvider.autoDispose<List<HabitLog>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.watchLogsForToday();
});

// A combined provider to easily check if a habit is done today
final habitStatusProvider = Provider.autoDispose<Map<String, bool>>((ref) {
  final logsAsync = ref.watch(todayHabitLogsProvider);
  
  return logsAsync.maybeWhen(
    data: (logs) {
      final Map<String, bool> statusMap = {};
      for (var log in logs) {
        statusMap[log.habitId] = true;
      }
      return statusMap;
    },
    orElse: () => {},
  );
});

