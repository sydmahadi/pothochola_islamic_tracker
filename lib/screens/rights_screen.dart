import 'package:flutter/material.dart';
import '../widgets/animated_header.dart';

class RightsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool english;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  const RightsScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onDataChanged,
  });

  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(english ? 'Add responsibility' : 'দায়িত্ব যোগ করুন'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: english ? 'Enter responsibility' : 'দায়িত্বের নাম লিখুন',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(english ? 'Cancel' : 'বাতিল'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(ctx, value);
            },
            child: Text(english ? 'Save' : 'সংরক্ষণ'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (title == null || title.isEmpty) return;

    final updated = Map<String, dynamic>.from(data);
    final list = List<dynamic>.from(updated['rights'] ?? []);
    list.add({
      'title': title,
      'due': '',
      'done': false,
    });
    updated['rights'] = list;
    onDataChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final rights = (data['rights'] as List?) ?? [];
    final completed = rights.where((r) => r is Map && r['done'] == true).length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: Text(english ? 'Add' : 'যোগ করুন'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedHeader(
            title: english ? 'Rights & Duties' : 'হক ও দায়িত্ব',
            subtitle: english
                ? 'Remember your commitments to others.'
                : 'অন্যের প্রতি নিজের দায়িত্ব মনে রাখুন।',
            icon: Icons.volunteer_activism_rounded,
            colors: const [Color(0xFFB66A18), Color(0xFFE6A23C)],
          ),
          const SizedBox(height: 18),
          Text(
            english
                ? '$completed of ${rights.length} completed'
                : '${rights.length}টির মধ্যে $completedটি সম্পন্ন',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (rights.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                english
                    ? 'No responsibilities added yet.'
                    : 'এখনো কোনো দায়িত্ব যোগ করা হয়নি।',
                textAlign: TextAlign.center,
              ),
            ),
          ...rights.asMap().entries.map((entry) {
            final index = entry.key;
            final item = Map<String, dynamic>.from(entry.value as Map);
            final done = item['done'] == true;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: done,
                title: Text(
                  '${item['title'] ?? ''}',
                  style: TextStyle(
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                secondary: IconButton(
                  tooltip: english ? 'Delete' : 'মুছুন',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final updated = Map<String, dynamic>.from(data);
                    final list = List<dynamic>.from(updated['rights'] ?? []);
                    list.removeAt(index);
                    updated['rights'] = list;
                    onDataChanged(updated);
                  },
                ),
                onChanged: (value) {
                  final updated = Map<String, dynamic>.from(data);
                  final list = List<dynamic>.from(updated['rights'] ?? []);
                  final changed = Map<String, dynamic>.from(list[index] as Map);
                  changed['done'] = value ?? false;
                  list[index] = changed;
                  updated['rights'] = list;
                  onDataChanged(updated);
                },
              ),
            );
          }),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}
