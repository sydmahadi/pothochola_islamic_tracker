
import 'package:flutter/material.dart';

class TodayAmalScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool english;
  final Future<void> Function(Map<String, dynamic>) onDataChanged;

  const TodayAmalScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onDataChanged,
  });

  @override
  State<TodayAmalScreen> createState() => _TodayAmalScreenState();
}

class _TodayAmalScreenState extends State<TodayAmalScreen> {
  bool _saving = false;
  late Map<String, dynamic> _checks;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static const List<Map<String, String>> _items = [
    {'id': 'fajr', 'category': 'farz', 'bn': 'ফজরের ফরজ সালাত', 'en': 'Fajr obligatory prayer'},
    {'id': 'dhuhr', 'category': 'farz', 'bn': 'যোহরের ফরজ সালাত', 'en': 'Dhuhr obligatory prayer'},
    {'id': 'asr', 'category': 'farz', 'bn': 'আসরের ফরজ সালাত', 'en': 'Asr obligatory prayer'},
    {'id': 'maghrib', 'category': 'farz', 'bn': 'মাগরিবের ফরজ সালাত', 'en': 'Maghrib obligatory prayer'},
    {'id': 'isha', 'category': 'farz', 'bn': 'ইশার ফরজ সালাত', 'en': 'Isha obligatory prayer'},
    {'id': 'fast', 'category': 'farz', 'bn': 'রমজানের রোজা (প্রযোজ্য হলে)', 'en': 'Ramadan fast (when applicable)'},
    {'id': 'parents', 'category': 'farz', 'bn': 'মা-বাবার সঙ্গে সদাচরণ ও দায়িত্ব পালন', 'en': 'Kindness and duties towards parents'},
    {'id': 'rights', 'category': 'farz', 'bn': 'মানুষের হক ও আমানত রক্ষা', 'en': 'Respect people’s rights and trusts'},
    {'id': 'fajr_sunnah', 'category': 'sunnah', 'bn': 'ফজরের দুই রাকাত সুন্নত', 'en': 'Two Sunnah rakats before Fajr'},
    {'id': 'rawatib', 'category': 'sunnah', 'bn': 'অন্যান্য সুন্নাতে রাতিবা', 'en': 'Other regular Sunnah prayers'},
    {'id': 'witr', 'category': 'sunnah', 'bn': 'বিতরের সালাত', 'en': 'Witr prayer'},
    {'id': 'tahajjud', 'category': 'sunnah', 'bn': 'তাহাজ্জুদ সালাত', 'en': 'Tahajjud prayer'},
    {'id': 'duha', 'category': 'sunnah', 'bn': 'দুহা/চাশতের সালাত', 'en': 'Duha prayer'},
    {'id': 'quran', 'category': 'sunnah', 'bn': 'কুরআন তিলাওয়াত', 'en': 'Quran recitation'},
    {'id': 'morning_dhikr', 'category': 'sunnah', 'bn': 'সকালের যিকির', 'en': 'Morning adhkar'},
    {'id': 'evening_dhikr', 'category': 'sunnah', 'bn': 'সন্ধ্যার যিকির', 'en': 'Evening adhkar'},
    {'id': 'dua', 'category': 'sunnah', 'bn': 'দোয়া ও ইস্তিগফার', 'en': 'Dua and istighfar'},
    {'id': 'salawat', 'category': 'sunnah', 'bn': 'নবী ﷺ-এর ওপর দরুদ পাঠ', 'en': 'Sending salawat upon the Prophet ﷺ'},
    {'id': 'learning', 'category': 'sunnah', 'bn': 'ইসলামি জ্ঞান অর্জন', 'en': 'Learning Islamic knowledge'},
    {'id': 'charity', 'category': 'sunnah', 'bn': 'সদকা বা উপকারী ভালো কাজ', 'en': 'Charity or another good deed'},
    {'id': 'silah', 'category': 'sunnah', 'bn': 'আত্মীয়তার সম্পর্ক বজায় রাখা', 'en': 'Maintaining family ties'},
    {'id': 'truth', 'category': 'avoid', 'bn': 'মিথ্যা বলা থেকে বিরত ছিলাম', 'en': 'Avoided lying'},
    {'id': 'backbiting', 'category': 'avoid', 'bn': 'গীবত ও অপবাদ থেকে বিরত ছিলাম', 'en': 'Avoided backbiting and slander'},
    {'id': 'cheating', 'category': 'avoid', 'bn': 'প্রতারণা ও ধোঁকা থেকে বিরত ছিলাম', 'en': 'Avoided cheating and deception'},
    {'id': 'anger', 'category': 'avoid', 'bn': 'অন্যায় রাগ ও গালাগালি নিয়ন্ত্রণ করেছি', 'en': 'Controlled wrongful anger and abusive speech'},
    {'id': 'pride', 'category': 'avoid', 'bn': 'অহংকার ও আত্মপ্রশংসা থেকে বিরত ছিলাম', 'en': 'Avoided arrogance and self-praise'},
    {'id': 'riya', 'category': 'avoid', 'bn': 'লোক দেখানো আমল থেকে বিরত ছিলাম', 'en': 'Avoided showing off in worship'},
    {'id': 'haram', 'category': 'avoid', 'bn': 'হারাম উপার্জন ও লেনদেন থেকে বিরত ছিলাম', 'en': 'Avoided unlawful earnings and dealings'},
    {'id': 'gaze', 'category': 'avoid', 'bn': 'দৃষ্টি ও আচরণ সংযত রেখেছি', 'en': 'Guarded my gaze and conduct'},
    {'id': 'waste', 'category': 'avoid', 'bn': 'অপচয় ও অন্যের হক নষ্ট করা থেকে বিরত ছিলাম', 'en': 'Avoided waste and violating others’ rights'},
  ];

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  @override
  void initState() {
    super.initState();
    final allLogs = _asMap(widget.data['todayAmalLogs']);
    final today = _asMap(allLogs[_todayKey]);
    _checks = _asMap(today['checks']);
  }

  @override
  void didUpdateWidget(covariant TodayAmalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final allLogs = _asMap(widget.data['todayAmalLogs']);
    final today = _asMap(allLogs[_todayKey]);
    _checks = _asMap(today['checks']);
  }

  List<Map<String, String>> _categoryItems(String category) {
    return _items.where((item) => item['category'] == category).toList();
  }

  int _doneCount(List<Map<String, String>> items) {
    return items.where((item) => _checks[item['id']] == true).length;
  }

  Future<void> _toggle(String id, bool value) async {
    if (_saving) return;

    final previousChecks = Map<String, dynamic>.from(_checks);
    final nextChecks = Map<String, dynamic>.from(_checks);
    nextChecks[id] = value;

    final newData = Map<String, dynamic>.from(widget.data);
    final allLogs = _asMap(newData['todayAmalLogs']);
    allLogs[_todayKey] = {
      'checks': nextChecks,
      'requiredIds': _items.map((item) => item['id']!).toList(),
    };
    newData['todayAmalLogs'] = allLogs;

    setState(() {
      _checks = nextChecks;
      _saving = true;
    });

    try {
      await widget.onDataChanged(newData);
    } catch (_) {
      if (mounted) {
        setState(() => _checks = previousChecks);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.length;
    final completed = _doneCount(_items);
    final ratio = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.english ? 'Today’s Amal' : 'আজকের আমল'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.english
                        ? 'Today’s progress'
                        : 'আজকের অগ্রগতি',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text('$completed / $total'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: ratio, minHeight: 9),
                  const SizedBox(height: 8),
                  Text(
                    widget.english
                        ? 'For avoidance items, tick when you have avoided the action today.'
                        : 'বর্জনীয় কাজের পাশে টিক দেবে যদি আজ সেই কাজ থেকে বিরত থাকতে পারো।',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _section(
            title: widget.english ? 'Obligatory duties' : 'ফরজ আমল ও দায়িত্ব',
            category: 'farz',
            icon: Icons.mosque_outlined,
          ),
          _section(
            title: widget.english ? 'Sunnah and voluntary deeds' : 'সুন্নাহ ও নফল আমল',
            category: 'sunnah',
            icon: Icons.auto_stories_outlined,
          ),
          _section(
            title: widget.english ? 'Things to avoid' : 'নিষিদ্ধ ও বর্জনীয় কাজ',
            category: 'avoid',
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 12),
          Text(
            widget.english
                ? 'This checklist is for personal reflection, not a religious ruling. Some duties depend on your circumstances.'
                : 'এটি ব্যক্তিগত আত্মসমালোচনার তালিকা; ফতোয়া নয়। কিছু দায়িত্ব ব্যক্তির পরিস্থিতির ওপর নির্ভরশীল।',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required String category,
    required IconData icon,
  }) {
    final items = _categoryItems(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text('${_doneCount(items)}/${items.length}'),
                ],
              ),
            ),
            const Divider(),
            ...items.map((item) {
              final id = item['id']!;
              return CheckboxListTile(
                value: _checks[id] == true,
                onChanged: _saving
                    ? null
                    : (value) => _toggle(id, value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  widget.english ? item['en']! : item['bn']!,
                ),
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }
}
