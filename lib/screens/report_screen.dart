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

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> get _habits {
    return Map<String, dynamic>.from(widget.data['habits'] ?? {});
  }

  bool _isDone(DateTime date, int index) {
    final day = Map<String, dynamic>.from(
      _habits[_dateKey(date)] ?? {},
    );
    return day['$index'] == true;
  }

  List<DateTime> get _periodDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final start = _monthly
        ? DateTime(now.year, now.month, 1)
        : today.subtract(Duration(days: today.weekday - 1));

    final count = today.difference(start).inDays + 1;

    return List.generate(
      count,
      (index) => start.add(Duration(days: index)),
    );
  }

  int _dayCount(DateTime date) {
    return List.generate(7, (index) => _isDone(date, index))
        .where((done) => done)
        .length;
  }

  int get _completedTotal {
    return _periodDays.fold<int>(
      0,
      (sum, date) => sum + _dayCount(date),
    );
  }

  int get _possibleTotal => _periodDays.length * 7;

  int get _bestDay {
    if (_periodDays.isEmpty) return 0;

    return _periodDays
        .map(_dayCount)
        .reduce((a, b) => a > b ? a : b);
  }

  int _habitTotal(int index) {
    return _periodDays.where((date) => _isDone(date, index)).length;
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.english ? _en : _bn;
    final percent = _possibleTotal == 0
        ? 0.0
        : _completedTotal / _possibleTotal;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          widget.english ? 'Worship report' : 'ইবাদতের রিপোর্ট',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.english
              ? 'Review your weekly and monthly progress.'
              : 'সাপ্তাহিক ও মাসিক ইবাদতের অগ্রগতি দেখুন।',
        ),
        const SizedBox(height: 18),

        SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
              value: false,
              label: Text(widget.english ? 'Weekly' : 'সাপ্তাহিক'),
              icon: const Icon(Icons.calendar_view_week),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text(widget.english ? 'Monthly' : 'মাসিক'),
              icon: const Icon(Icons.calendar_month),
            ),
          ],
          selected: {_monthly},
          onSelectionChanged: (selection) {
            setState(() => _monthly = selection.first);
          },
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.english ? 'Overall progress' : 'সামগ্রিক অগ্রগতি',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(percent * 100).round()}%',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        '$_completedTotal/$_possibleTotal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.english
                      ? '${_periodDays.length} days included'
                      : '${_periodDays.length} দিনের হিসাব অন্তর্ভুক্ত',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                title: widget.english ? 'Completed' : 'সম্পন্ন',
                value: '$_completedTotal',
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                context,
                title: widget.english ? 'Best day' : 'সেরা দিন',
                value: '$_bestDay/7',
                icon: Icons.emoji_events_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          widget.english ? 'Habit breakdown' : 'আমলভিত্তিক হিসাব',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),

        ...List.generate(7, (index) {
          final count = _habitTotal(index);
          final ratio = _periodDays.isEmpty
              ? 0.0
              : count / _periodDays.length;

          return Card(
            margin: const EdgeInsets.only(bottom: 9),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(labels[index])),
                      Text(
                        '$count/${_periodDays.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 7,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),
        Text(
          widget.english ? 'Daily history' : 'দিনভিত্তিক হিসাব',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),

        ..._periodDays.reversed.map((date) {
          final count = _dayCount(date);
          final ratio = count / 7;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${date.day}'),
              ),
              title: Text(_formattedDate(date)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                  ),
                ),
              ),
              trailing: Text(
                '$count/7',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formattedDate(DateTime date) {
    final key = _dateKey(date);

    if (widget.english) return key;

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFC9A45C), size: 26),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}
