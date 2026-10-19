
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
  String _period = 'weekly';

  static const Map<String, Map<String, String>> _labels = {
    'fajr': {'bn': 'ফজরের ফরজ সালাত', 'en': 'Fajr obligatory prayer'},
    'dhuhr': {'bn': 'যোহরের ফরজ সালাত', 'en': 'Dhuhr obligatory prayer'},
    'asr': {'bn': 'আসরের ফরজ সালাত', 'en': 'Asr obligatory prayer'},
    'maghrib': {'bn': 'মাগরিবের ফরজ সালাত', 'en': 'Maghrib obligatory prayer'},
    'isha': {'bn': 'ইশার ফরজ সালাত', 'en': 'Isha obligatory prayer'},
    'fast': {'bn': 'রমজানের রোজা', 'en': 'Ramadan fast'},
    'parents': {'bn': 'মা-বাবার সঙ্গে সদাচরণ', 'en': 'Kindness to parents'},
    'rights': {'bn': 'মানুষের হক ও আমানত', 'en': 'People’s rights and trusts'},
    'fajr_sunnah': {'bn': 'ফজরের দুই রাকাত সুন্নত', 'en': 'Two Sunnah rakats before Fajr'},
    'rawatib': {'bn': 'অন্যান্য সুন্নাতে রাতিবা', 'en': 'Other regular Sunnah prayers'},
    'witr': {'bn': 'বিতরের সালাত', 'en': 'Witr prayer'},
    'tahajjud': {'bn': 'তাহাজ্জুদ সালাত', 'en': 'Tahajjud prayer'},
    'duha': {'bn': 'দুহা/চাশতের সালাত', 'en': 'Duha prayer'},
    'quran': {'bn': 'কুরআন তিলাওয়াত', 'en': 'Quran recitation'},
    'morning_dhikr': {'bn': 'সকালের যিকির', 'en': 'Morning adhkar'},
    'evening_dhikr': {'bn': 'সন্ধ্যার যিকির', 'en': 'Evening adhkar'},
    'dua': {'bn': 'দোয়া ও ইস্তিগফার', 'en': 'Dua and istighfar'},
    'salawat': {'bn': 'দরুদ পাঠ', 'en': 'Sending salawat'},
    'learning': {'bn': 'ইসলামি জ্ঞান অর্জন', 'en': 'Islamic learning'},
    'charity': {'bn': 'সদকা বা ভালো কাজ', 'en': 'Charity or good deed'},
    'silah': {'bn': 'আত্মীয়তার সম্পর্ক', 'en': 'Maintaining family ties'},
    'truth': {'bn': 'মিথ্যা থেকে বিরত থাকা', 'en': 'Avoided lying'},
    'backbiting': {'bn': 'গীবত ও অপবাদ থেকে বিরত থাকা', 'en': 'Avoided backbiting and slander'},
    'cheating': {'bn': 'প্রতারণা থেকে বিরত থাকা', 'en': 'Avoided cheating'},
    'anger': {'bn': 'রাগ ও গালাগালি নিয়ন্ত্রণ', 'en': 'Controlled anger and abusive speech'},
    'pride': {'bn': 'অহংকার থেকে বিরত থাকা', 'en': 'Avoided arrogance'},
    'riya': {'bn': 'লোক দেখানো আমল থেকে বিরত থাকা', 'en': 'Avoided showing off'},
    'haram': {'bn': 'হারাম উপার্জন থেকে বিরত থাকা', 'en': 'Avoided unlawful earnings'},
    'gaze': {'bn': 'দৃষ্টি ও আচরণ সংযত রাখা', 'en': 'Guarded gaze and conduct'},
    'waste': {'bn': 'অপচয় থেকে বিরত থাকা', 'en': 'Avoided waste'},
  };

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<DateTime> get _days {
    final today = _today;
    late DateTime start;

    if (_period == 'weekly') {
      start = today.subtract(Duration(days: today.weekday - 1));
    } else if (_period == 'monthly') {
      start = DateTime(today.year, today.month, 1);
    } else {
      start = DateTime(today.year, 1, 1);
    }

    return List.generate(
      today.difference(start).inDays + 1,
      (index) => start.add(Duration(days: index)),
    );
  }

  Map<String, dynamic> _log(DateTime date) {
    final all = _map(widget.data['todayAmalLogs']);
    return _map(all[_key(date)]);
  }

  Map<String, dynamic> _checks(DateTime date) =>
      _map(_log(date)['checks']);

  List<String> _required(DateTime date) {
    final raw = _log(date)['requiredIds'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  int _done(DateTime date) {
    final required = _required(date);
    final checks = _checks(date);
    return required.where((id) => checks[id] == true).length;
  }

  int _total(DateTime date) => _required(date).length;

  bool _hasRecord(DateTime date) =>
      _map(widget.data['todayAmalLogs']).containsKey(_key(date));

  double _ratio(DateTime date) {
    final total = _total(date);
    if (total == 0) return 0;
    return (_done(date) / total).clamp(0.0, 1.0).toDouble();
  }

  int get _doneTotal => _days.fold(0, (sum, date) => sum + _done(date));
  int get _possibleTotal => _days.fold(0, (sum, date) => sum + _total(date));

  double get _ratioTotal {
    if (_possibleTotal == 0) return 0;
    return (_doneTotal / _possibleTotal).clamp(0.0, 1.0).toDouble();
  }

  List<String> get _ids {
    final ids = <String>{};
    for (final date in _days) {
      ids.addAll(_required(date));
      ids.addAll(_checks(date).keys.map((e) => e.toString()));
    }
    final result = ids.toList()..sort();
    return result;
  }

  String _label(String id) {
    final pair = _labels[id];
    if (pair == null) return id;
    return widget.english ? pair['en']! : pair['bn']!;
  }

  String _dateLabel(DateTime date) {
    if (widget.english) return _key(date);
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Map<String, int> _statsForId(String id) {
    int done = 0;
    int total = 0;

    for (final date in _days) {
      if (_required(date).contains(id)) {
        total++;
        if (_checks(date)[id] == true) done++;
      }
    }
    return {'done': done, 'total': total};
  }

  Map<String, int> _monthStats(int month) {
    final today = _today;
    final start = DateTime(today.year, month, 1);
    final end = month == today.month ? today : DateTime(today.year, month + 1, 0);

    int done = 0;
    int total = 0;

    for (DateTime date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      done += _done(date);
      total += _total(date);
    }

    return {'done': done, 'total': total};
  }

  String _monthName(int month) {
    const bn = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট',
      'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];
    const en = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return widget.english ? en[month - 1] : bn[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final english = widget.english;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          english ? 'Today’s Amal report' : 'আজকের আমলের রিপোর্ট',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          english
              ? 'Reports are based only on the Today’s Amal checklist.'
              : 'শুধু “আজকের আমল” তালিকার তথ্য দিয়ে রিপোর্ট তৈরি হয়েছে।',
        ),
        const SizedBox(height: 18),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'weekly',
              label: Text(english ? 'Weekly' : 'সাপ্তাহিক'),
              icon: const Icon(Icons.calendar_view_week),
            ),
            ButtonSegment(
              value: 'monthly',
              label: Text(english ? 'Monthly' : 'মাসিক'),
              icon: const Icon(Icons.calendar_month),
            ),
            ButtonSegment(
              value: 'yearly',
              label: Text(english ? 'Yearly' : 'বার্ষিক'),
              icon: const Icon(Icons.calendar_today),
            ),
          ],
          selected: {_period},
          onSelectionChanged: (value) => setState(() => _period = value.first),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  english ? 'Overall completion' : 'সামগ্রিক সম্পন্নের হার',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_ratioTotal * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _ratioTotal, minHeight: 9),
                const SizedBox(height: 8),
                Text('$_doneTotal / $_possibleTotal'),
                Text(
                  english
                      ? '${_days.length} days in this period'
                      : 'এই সময়সীমায় ${_days.length} দিন',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_period == 'yearly') ...[
          Text(
            english ? 'Monthly summary' : 'মাসভিত্তিক হিসাব',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...List.generate(DateTime.now().month, (index) {
            final month = index + 1;
            final stats = _monthStats(month);
            final total = stats['total']!;
            final done = stats['done']!;
            final ratio = total == 0 ? 0.0 : done / total;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(_monthName(month))),
                        Text('${(ratio * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: ratio),
                    const SizedBox(height: 6),
                    Text('$done / $total'),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
        Text(
          english ? 'Amal breakdown' : 'আমলভিত্তিক হিসাব',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (_ids.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                english
                    ? 'No checklist records found for this period.'
                    : 'এই সময়সীমায় এখনো কোনো আমলের তথ্য সংরক্ষিত নেই।',
              ),
            ),
          )
        else
          ..._ids.map((id) {
            final stats = _statsForId(id);
            final done = stats['done']!;
            final total = stats['total']!;
            final ratio = total == 0 ? 0.0 : done / total;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(_label(id))),
                        Text('$done/$total'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: ratio),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        Text(
          english ? 'Daily history' : 'দিনভিত্তিক হিসাব',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...(_period == 'yearly' ? _days.reversed.take(31) : _days.reversed)
            .map((date) {
          final done = _done(date);
          final total = _total(date);
          final hasRecord = _hasRecord(date);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text('${date.day}')),
              title: Text(_dateLabel(date)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: _ratio(date)),
                    const SizedBox(height: 5),
                    Text(
                      !hasRecord
                          ? (english ? 'No record' : 'তথ্য সংরক্ষিত নেই')
                          : '${(_ratio(date) * 100).round()}%',
                    ),
                  ],
                ),
              ),
              trailing: Text(
                '$done/$total',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }
}
