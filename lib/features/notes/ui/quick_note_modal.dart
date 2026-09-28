import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/notes_repository.dart';

class QuickNoteModal extends ConsumerStatefulWidget {
  const QuickNoteModal({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickNoteModal(),
    );
  }

  @override
  ConsumerState<QuickNoteModal> createState() => _QuickNoteModalState();
}

class _QuickNoteModalState extends ConsumerState<QuickNoteModal> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final content = _contentController.text.trim();
    if (content.isNotEmpty) {
      // Use the first line as title, or a default
      final lines = content.split('\n');
      final title = lines.first.length > 30 ? '${lines.first.substring(0, 30)}...' : lines.first;
      
      ref.read(notesRepositoryProvider).addNote(title, content, null);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(bottom: bottomInset, left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          TextField(
            controller: _contentController,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Jot down something...',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _saveNote,
            child: const Text('Save Note', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
