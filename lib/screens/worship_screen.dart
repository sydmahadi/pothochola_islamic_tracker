import 'package:flutter/material.dart';
import '../widgets/animated_header.dart';

class WorshipScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool english;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  const WorshipScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onDataChanged,
  });

  static const List<String> _bn = [
    'পাঁচ ওয়াক্ত সালাত',
    'কুরআন তিলাওয়াত',
    'সকালের যিকির',
    'সন্ধ্যার যিকির',
    'দোয়া ও ইস্তিগফার',
    'ইসলামি জ্ঞান অর্জন',
    'সদকা বা ভালো কাজ',
  ];

  static const List<String> _en = [
    'Five daily prayers',
    'Quran recitation',
    'Morning adhkar',
    'Evening adhkar',
    'Dua and istighfar',
    'Islamic learning',
    'Charity or good deed',
  ];

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final habits = Map<String, dynamic>.from(data['habits'] ?? {});
    final today = Map<String, dynamic>.from(habits[_today] ?? {});
    final names = english ? _en : _bn;
    final doneCount = List.generate(
      names.length,
      (i) => today['$i'] == true,
    ).where((done) => done).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AnimatedHeader(
          title: english ? 'Daily Worship' : 'দৈনিক ইবাদত',
          subtitle: english
              ? 'Build consistency, one day at a time.'
              : 'নিয়মিত আমলের অভ্যাস গড়ে তুলুন।',
          icon: Icons.mosque_rounded,
          colors: const [Color(0xFF8A4DB8), Color(0xFFCB68A7)],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  english ? 'Today’s progress' : 'আজকের অগ্রগতি',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: doneCount / names.length, minHeight: 9),
                const SizedBox(height: 8),
                Text('$doneCount / ${names.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(names.length, (i) {
          final checked = today['$i'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: checked,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(names[i]),
              secondary: Icon(
                checked ? Icons.check_circle : Icons.circle_outlined,
                color: checked ? Colors.green : null,
              ),
              onChanged: (value) {
                final updated = Map<String, dynamic>.from(data);
                final updatedHabits =
                    Map<String, dynamic>.from(updated['habits'] ?? {});
                final updatedToday =
                    Map<String, dynamic>.from(updatedHabits[_today] ?? {});
                updatedToday['$i'] = value ?? false;
                updatedHabits[_today] = updatedToday;
                updated['habits'] = updatedHabits;
                onDataChanged(updated);
              },
            ),
          );
        }),
      ],
    );
  }
}
