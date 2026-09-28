import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../repository/tasks_repository.dart';

final dailyTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.watchTasksForDate(DateTime.now());
});

final groupedTasksProvider = Provider.autoDispose<Map<String, List<Task>>>((ref) {
  final tasksAsync = ref.watch(dailyTasksProvider);
  
  return tasksAsync.maybeWhen(
    data: (tasks) {
      final Map<String, List<Task>> grouped = {
        'Work': [],
        'Life': [],
        'Deen': [],
      };
      
      for (var task in tasks) {
        if (grouped.containsKey(task.category)) {
          grouped[task.category]!.add(task);
        } else {
          // Fallback for uncategorized
          grouped['Life']!.add(task);
        }
      }
      return grouped;
    },
    orElse: () => {'Work': [], 'Life': [], 'Deen': []},
  );
});
