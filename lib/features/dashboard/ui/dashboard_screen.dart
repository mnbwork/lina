import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/controller/tasks_controller.dart';
import '../../tasks/repository/tasks_repository.dart';
import '../../notes/ui/quick_note_modal.dart';
import '../../notes/controller/notes_controller.dart';
import '../../notes/repository/notes_repository.dart';
import '../../habits/controller/habits_controller.dart';
import '../../habits/repository/habits_repository.dart';
import '../controller/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTasks = ref.watch(groupedTasksProvider);
    final repository = ref.read(tasksRepositoryProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final nextPrayerAsync = ref.watch(nextPrayerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white/neutral background
      appBar: AppBar(
        title: const Text('TODAY', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add, color: Color(0xFF2E7D32)),
            onPressed: () => QuickNoteModal.show(context),
            tooltip: 'Quick Note',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good Morning,', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    weatherAsync.when(
                      data: (temp) => Text('Dhaka • $temp', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      loading: () => const Text('Loading weather...'),
                      error: (_, __) => const Text('Weather offline'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                  child: nextPrayerAsync.when(
                    data: (prayer) => Text('Next: $prayer', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                    loading: () => const Text('...', style: TextStyle(color: Color(0xFF2E7D32))),
                    error: (_, __) => const Text('Offline'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildHabitsSection(ref, context),
            const SizedBox(height: 32),
            _buildCategorySection('WORK', groupedTasks['Work'] ?? [], repository, context),
            const SizedBox(height: 24),
            _buildCategorySection('LIFE', groupedTasks['Life'] ?? [], repository, context),
            const SizedBox(height: 24),
            _buildCategorySection('DEEN', groupedTasks['Deen'] ?? [], repository, context),
            const SizedBox(height: 32),
            _buildNotesSection(ref, context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32), // Subtle emerald accent
        onPressed: () => _showAddTaskDialog(context, repository),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitsSection(WidgetRef ref, BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final statusMap = ref.watch(habitStatusProvider);
    final repo = ref.read(habitsRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('DAILY HABITS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showAddHabitDialog(context, repo),
            ),
          ],
        ),
        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) return const Text('No habits tracking yet.', style: TextStyle(color: Colors.black38));
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: habits.map((habit) {
                  final isDone = statusMap[habit.id] ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () => repo.toggleHabitForToday(habit.id, !isDone),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xFF2E7D32) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDone ? const Color(0xFF2E7D32) : Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.white : Colors.grey),
                            const SizedBox(height: 8),
                            Text(habit.name, style: TextStyle(color: isDone ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => const Text('Error loading habits'),
        ),
      ],
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitsRepository repo) {
    String name = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Habit'),
        content: TextField(
          autofocus: true,
          onChanged: (v) => name = v,
          decoration: const InputDecoration(hintText: 'e.g. Read Quran'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              if (name.isNotEmpty) {
                repo.addHabit(name, 'Deen');
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Widget _buildNotesSection(WidgetRef ref, BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT NOTES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) return const Text('No notes yet.', style: TextStyle(color: Colors.black38));
            return Column(
              children: notes.take(3).map((note) => Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () => ref.read(notesRepositoryProvider).deleteNote(note.id),
                  ),
                ),
              )).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => const Text('Error loading notes'),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, List tasks, TasksRepository repo, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          const Text('No tasks.', style: TextStyle(color: Colors.black38))
        else
          ...tasks.map((task) => CheckboxListTile(
            title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
            value: task.isCompleted,
            activeColor: const Color(0xFF2E7D32),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => repo.toggleTaskStatus(task),
          )).toList(),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, TasksRepository repo) {
    String title = '';
    String category = 'Work';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Quick Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              onChanged: (v) => title = v,
              decoration: const InputDecoration(hintText: 'What needs to be done?'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              items: ['Work', 'Life', 'Deen'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => category = v!,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              if (title.isNotEmpty) {
                repo.addTask(title, category, null);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
