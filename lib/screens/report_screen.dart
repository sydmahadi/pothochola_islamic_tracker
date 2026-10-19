
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool english;

  const ReportScreen({
    super.key,
    required this.data,
    required this.english,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _monthly = false;

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

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> _habitsFor(DateTime date) {
    final all = widget.data['habits'];
    if (all is! Map) return {};
    final day = all[_key(date)];
    if (day is! Map) return {};
    return Map<String, dynamic>.from(day);
  }

  int _doneFor(DateTime date) {
    final habits = _habitsFor(date);
    return List.generate(7, (i) => habits['$i'] == true)
        .where((v) => v)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final english = widget.english;
    final names = english ? _en : _bn;
    final now = DateTime.now();
    final start = _monthly
        ? DateTime(now.year, now.month)
        : DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));

    final end = _monthly
        ? DateTime(now.year, now.month + 1)
        : start.add(const Duration(days: 7));

    final days = <DateTime>[];
    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      if (!d.isAfter(now)) days.add(d);
    }

    final totalPossible = days.length * 7;
    final totalDone = days.fold<int>(0, (sum, d) => sum + _doneFor(d));
    final percent = totalPossible == 0 ? 0.0 : totalDone / totalPossible;
    final bestDay = days.isEmpty
        ? 0
        : days.map(_doneFor).reduce((a, b) => a > b ? a : b);

    final todayDone = _doneFor(now);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087F5B), Color(0xFF155440)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded,
                      color: Color(0xFFFFD982), size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      english ? 'Worship Report' : 'ইবাদতের রিপোর্ট',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                english
                    ? 'Review your consistency and daily progress.'
                    : 'আপনার আমলের ধারাবাহিকতা ও অগ্রগতি দেখুন।',
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 22),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(english ? 'Weekly' : 'সাপ্তাহিক'),
                    icon: const Icon(Icons.view_week_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(english ? 'Monthly' : 'মাসিক'),
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                ],
                selected: {_monthly},
                onSelectionChanged: (selection) {
                  setState(() => _monthly = selection.first);
                },
              ),
              const SizedBox(height: 18),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD982)),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                english
                    ? '$totalDone of $totalPossible possible daily actions completed'
                    : '$totalPossibleটি সম্ভাব্য আমলের মধ্যে $totalDoneটি সম্পন্ন',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                english ? 'Today' : 'আজকের আমল',
                '$todayDone / 7',
                Icons.today_rounded,
                const Color(0xFF138568),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                english ? 'Best day' : 'সেরা দিনের আমল',
                '$bestDay / 7',
                Icons.emoji_events_rounded,
                const Color(0xFFD39A35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          english ? 'Progress by habit' : 'আমল অনুযায়ী অগ্রগতি',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(7, (index) {
          final completed = days
              .where((day) => _habitsFor(day)['$index'] == true)
              .length;
          final ratio = days.isEmpty ? 0.0 : completed / days.length;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          [
                            Icons.mosque_rounded,
                            Icons.menu_book_rounded,
                            Icons.wb_sunny_rounded,
                            Icons.nights_stay_rounded,
                            Icons.favorite_rounded,
                            Icons.school_rounded,
                            Icons.volunteer_activism_rounded,
                          ][index],
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          names[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '$completed/${days.length}',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 7,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(primary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${(ratio * 100).round()}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        Text(
          english ? 'Daily history' : 'প্রতিদিনের হিসাব',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...days.reversed.map((day) {
          final count = _doneFor(day);
          final label =
              '${day.day.toString().padLeft(2, '0')}/'
              '${day.month.toString().padLeft(2, '0')}/'
              '${day.year}';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primary.withValues(alpha: 0.10),
                child: Icon(
                  count == 7
                      ? Icons.check_circle_rounded
                      : Icons.calendar_today_rounded,
                  color: primary,
                ),
              ),
              title: Text(label),
              subtitle: Text(
                count == 7
                    ? (english ? 'All habits completed' : 'সব আমল সম্পন্ন')
                    : (english
                        ? '${7 - count} habits remaining'
                        : 'আর ${7 - count}টি আমল বাকি'),
              ),
              trailing: Text(
                '$count/7',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Text(
          english
              ? 'Reports are calculated from the habit records saved on this device.'
              : 'এই রিপোর্টে এই ডিভাইসে সংরক্ষিত আমলের তথ্য ব্যবহার করা হয়েছে।',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
