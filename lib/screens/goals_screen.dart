import 'package:flutter/material.dart';
import '../widgets/animated_header.dart';

class GoalsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool english;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  const GoalsScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onDataChanged,
  });

  Future<void> _addGoal(BuildContext context) async {
    final controller = TextEditingController();
    final totalController = TextEditingController(text: '30');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(english ? 'New goal' : 'নতুন লক্ষ্য'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: english ? 'Goal name' : 'লক্ষ্যের নাম',
              ),
            ),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: english ? 'Target days/steps' : 'মোট দিন/ধাপ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(english ? 'Cancel' : 'বাতিল'),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              final total = int.tryParse(totalController.text) ?? 30;
              if (title.isNotEmpty && total > 0) {
                Navigator.pop(dialogContext, {
                  'title': title,
                  'total': total,
                  'progress': 0,
                  'deadline': '',
                  'created': DateTime.now().toIso8601String(),
                });
              }
            },
            child: Text(english ? 'Add' : 'যোগ করুন'),
          ),
        ],
      ),
    );

    controller.dispose();
    totalController.dispose();

    if (result == null) return;
    final updated = Map<String, dynamic>.from(data);
    final goals = List<dynamic>.from(updated['goals'] ?? []);
    goals.add(result);
    updated['goals'] = goals;
    onDataChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final goals = (data['goals'] as List?) ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addGoal(context),
        icon: const Icon(Icons.add),
        label: Text(english ? 'Add goal' : 'লক্ষ্য যোগ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedHeader(
            title: english ? 'My Goals' : 'আমার লক্ষ্য',
            subtitle: english
                ? 'Small steps create lasting change.'
                : 'ছোট ছোট পদক্ষেপেই বড় পরিবর্তন।',
            icon: Icons.flag_rounded,
            colors: const [Color(0xFF3457D5), Color(0xFF7A5CE0)],
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            _empty(context, english ? 'No goals yet. Add your first goal!' : 'এখনো কোনো লক্ষ্য নেই। প্রথম লক্ষ্যটি যোগ করুন।'),
          ...goals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = Map<String, dynamic>.from(entry.value as Map);
            final total = (goal['total'] as num?)?.toInt() ?? 1;
            final progress = (goal['progress'] as num?)?.toInt() ?? 0;
            final fraction = total > 0 ? (progress / total).clamp(0.0, 1.0) : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${goal['title'] ?? ''}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: english ? 'Delete' : 'মুছুন',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            final updated = Map<String, dynamic>.from(data);
                            final list = List<dynamic>.from(updated['goals'] ?? []);
                            list.removeAt(index);
                            updated['goals'] = list;
                            onDataChanged(updated);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 9,
                        backgroundColor: Theme.of(context).dividerColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('$progress / $total'),
                        ),
                        IconButton(
                          onPressed: progress <= 0
                              ? null
                              : () {
                                  final updated = Map<String, dynamic>.from(data);
                                  final list = List<dynamic>.from(updated['goals'] ?? []);
                                  final item = Map<String, dynamic>.from(list[index] as Map);
                                  item['progress'] = progress - 1;
                                  list[index] = item;
                                  updated['goals'] = list;
                                  onDataChanged(updated);
                                },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        IconButton(
                          onPressed: progress >= total
                              ? null
                              : () {
                                  final updated = Map<String, dynamic>.from(data);
                                  final list = List<dynamic>.from(updated['goals'] ?? []);
                                  final item = Map<String, dynamic>.from(list[index] as Map);
                                  item['progress'] = progress + 1;
                                  list[index] = item;
                                  updated['goals'] = list;
                                  onDataChanged(updated);
                                },
                          icon: const Icon(Icons.add_circle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(text, textAlign: TextAlign.center)),
      );
}
