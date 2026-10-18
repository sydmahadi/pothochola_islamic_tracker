
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PathcholaApp());
}

const Color emerald = Color(0xFF087F5B);
const Color gold = Color(0xFFFFC857);
const Color violet = Color(0xFF7857E8);
const Color blue = Color(0xFF3977F6);
const Color teal = Color(0xFF009E9A);
const Color coral = Color(0xFFFF795E);
const Color ink = Color(0xFF17233B);

class PathcholaApp extends StatefulWidget {
  const PathcholaApp({super.key});

  @override
  State<PathcholaApp> createState() => _PathcholaAppState();
}

class _PathcholaAppState extends State<PathcholaApp> {
  bool english = false;
  bool dark = false;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      english = prefs.getBool('pathchola_english') ?? false;
      dark = prefs.getBool('pathchola_dark') ?? false;
    } catch (_) {}
    if (mounted) setState(() => ready = true);
  }

  Future<void> _setEnglish(bool value) async {
    setState(() => english = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pathchola_english', value);
  }

  Future<void> _setDark(bool value) async {
    setState(() => dark = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pathchola_dark', value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'পথচলা',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor:
            dark ? const Color(0xFF101821) : const Color(0xFFF5F7FB),
        appBarTheme: AppBarTheme(
          backgroundColor:
              dark ? const Color(0xFF101821) : const Color(0xFFF5F7FB),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: dark ? const Color(0xFF1B2634) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: dark ? const Color(0xFF243244) : const Color(0xFFF1F4F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: ready
          ? TrackerHome(
              english: english,
              dark: dark,
              onLanguageChanged: _setEnglish,
              onThemeChanged: _setDark,
            )
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class TrackerHome extends StatefulWidget {
  final bool english;
  final bool dark;
  final ValueChanged<bool> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const TrackerHome({
    super.key,
    required this.english,
    required this.dark,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

class _TrackerHomeState extends State<TrackerHome> {
  static const String _storageKey = 'pathchola_v1_data';

  int page = 0;
  DateTime selectedDate = DateTime.now();

  Map<String, dynamic> data = {
    'goals': <dynamic>[],
    'habits': <String, dynamic>{},
    'reflections': <String, dynamic>{},
    'rights': <dynamic>[],
  };

  bool loading = true;
  bool loadError = false;
  bool saving = false;
  bool _allowSave = true;
  String? saveError;
  Future<void> _saveQueue = Future<void>.value();

  final TextEditingController reflectionController =
      TextEditingController();

  String tr(String bn, String en) => widget.english ? en : bn;

  String get dateKey => _keyFor(selectedDate);

  String _keyFor(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    reflectionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);

        if (decoded is! Map) {
          throw const FormatException('Invalid saved data');
        }

        final loaded = Map<String, dynamic>.from(decoded);

        data = {
          'goals': loaded['goals'] is List
              ? List<dynamic>.from(loaded['goals'])
              : <dynamic>[],
          'habits': loaded['habits'] is Map
              ? Map<String, dynamic>.from(loaded['habits'])
              : <String, dynamic>{},
          'reflections': loaded['reflections'] is Map
              ? Map<String, dynamic>.from(loaded['reflections'])
              : <String, dynamic>{},
          'rights': loaded['rights'] is List
              ? List<dynamic>.from(loaded['rights'])
              : <dynamic>[],
        };
      }
      _allowSave = true;
    } catch (_) {
      // Never automatically overwrite unreadable saved data.
      loadError = true;
      _allowSave = false;
    }

    reflectionController.text =
        (data['reflections'] as Map<String, dynamic>)[dateKey]?.toString() ??
            '';

    if (mounted) setState(() => loading = false);
  }

  Future<void> _saveData() async {
    if (!_allowSave) return;

    final snapshot = jsonEncode(data);

    _saveQueue = _saveQueue.then((_) async {
      if (mounted) setState(() => saving = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final ok = await prefs.setString(_storageKey, snapshot);

        if (!ok) throw Exception('Could not save data');

        // Verify the write before reporting success.
        if (prefs.getString(_storageKey) != snapshot) {
          throw Exception('Saved data verification failed');
        }

        if (mounted) {
          setState(() => saveError = null);
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            saveError = tr(
              'ডেটা সংরক্ষণ হয়নি। আবার চেষ্টা করো।',
              'Data could not be saved. Please try again.',
            );
          });
        }
      } finally {
        if (mounted) setState(() => saving = false);
      }
    });

    await _saveQueue;
  }

  void _refreshAndSave() {
    setState(() {});
    _saveData();
  }

  List<Map<String, dynamic>> get goals =>
      (data['goals'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  List<Map<String, dynamic>> get rights =>
      (data['rights'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  Map<String, dynamic> get habits =>
      data['habits'] as Map<String, dynamic>;

  Map<String, dynamic> get reflections =>
      data['reflections'] as Map<String, dynamic>;

  List<String> get habitNames => [
        tr('পাঁচ ওয়াক্ত নামাজ', 'Five daily prayers'),
        tr('কুরআন তিলাওয়াত', 'Quran recitation'),
        tr('সকালের যিকির', 'Morning adhkar'),
        tr('সন্ধ্যার যিকির', 'Evening adhkar'),
        tr('ইস্তিগফার', 'Istighfar'),
        tr('দরুদ পাঠ', 'Salawat'),
        tr('উপকারী জ্ঞান অর্জন', 'Beneficial learning'),
        tr('সদকা ও ভালো কাজ', 'Charity and good deeds'),
      ];

  int get completedHabits {
    final today = habits[dateKey];
    if (today is! Map) return 0;
    return today.values.where((v) => v == true).length;
  }

  int get completedGoals =>
      goals.where((g) {
        final total = _number(g['total']);
        return total > 0 && _number(g['progress']) >= total;
      }).length;

  int get completedRights =>
      rights.where((r) => r['done'] == true).length;

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: tr('তারিখ নির্বাচন', 'Select date'),
    );

    if (picked == null || !mounted) return;

    setState(() {
      selectedDate = picked;
      reflectionController.text =
          reflections[_keyFor(picked)]?.toString() ?? '';
    });
  }

  Future<void> _addGoal({Map<String, dynamic>? existing}) async {
    final titleController = TextEditingController(
      text: existing?['title']?.toString() ?? '',
    );
    final totalController = TextEditingController(
      text: (existing?['total'] ?? 10).toString(),
    );
    final progressController = TextEditingController(
      text: (existing?['progress'] ?? 0).toString(),
    );
    DateTime deadline = DateTime.tryParse(
          existing?['deadline']?.toString() ?? '',
        ) ??
        DateTime.now().add(const Duration(days: 30));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? tr('নতুন লক্ষ্য', 'New goal')
                    : tr('লক্ষ্য সম্পাদনা', 'Edit goal'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: tr('লক্ষ্যের নাম', 'Goal title'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: totalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: tr('মোট ধাপ/পরিমাণ', 'Total steps'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: progressController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: tr('বর্তমান অগ্রগতি', 'Current progress'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: deadline,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          updateDialog(() => deadline = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        '${tr('শেষ তারিখ', 'Deadline')}: ${_formatDate(deadline)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(tr('বাতিল', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final total =
                        int.tryParse(totalController.text.trim()) ?? 1;
                    final progress =
                        int.tryParse(progressController.text.trim()) ?? 0;

                    if (title.isEmpty || total < 1) return;

                    final safeProgress = progress.clamp(0, total);

                    if (existing == null) {
                      (data['goals'] as List).add({
                        'title': title,
                        'total': total,
                        'progress': safeProgress,
                        'deadline': deadline.toIso8601String(),
                        'created': DateTime.now().toIso8601String(),
                      });
                    } else {
                      existing['title'] = title;
                      existing['total'] = total;
                      existing['progress'] = safeProgress;
                      existing['deadline'] = deadline.toIso8601String();
                    }

                    Navigator.pop(dialogContext);
                    _refreshAndSave();
                  },
                  child: Text(tr('সংরক্ষণ', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    totalController.dispose();
    progressController.dispose();
  }

  Future<void> _addRight({Map<String, dynamic>? existing}) async {
    final titleController = TextEditingController(
      text: existing?['title']?.toString() ?? '',
    );

    DateTime due = DateTime.tryParse(existing?['due']?.toString() ?? '') ??
        DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(
            existing == null
                ? tr('নতুন দায়িত্ব', 'New responsibility')
                : tr('দায়িত্ব সম্পাদনা', 'Edit responsibility'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: tr('কাজের বিবরণ', 'Description'),
                  hintText: tr(
                    'যেমন: কারও টাকা ফেরত দেওয়া',
                    'e.g. Return money to someone',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: due,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) updateDialog(() => due = picked);
                },
                icon: const Icon(Icons.event_rounded),
                label: Text(_formatDate(due)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('বাতিল', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                if (existing == null) {
                  (data['rights'] as List).add({
                    'title': title,
                    'due': due.toIso8601String(),
                    'done': false,
                  });
                } else {
                  existing['title'] = title;
                  existing['due'] = due.toIso8601String();
                }

                Navigator.pop(dialogContext);
                _refreshAndSave();
              },
              child: Text(tr('সংরক্ষণ', 'Save')),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
  }

  Future<void> _confirmDelete({
    required String title,
    required VoidCallback onDelete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('মুছে ফেলবে?', 'Delete item?')),
        content: Text(
          tr(
            'এই তথ্যটি মুছে ফেলতে চাও?',
            'Do you want to delete this item?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('না', 'No')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('মুছে ফেলো', 'Delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
      _refreshAndSave();
    }
  }

  Widget _pageHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
  }) {
    return AnimatedGradientHeader(
      title: title,
      subtitle: subtitle,
      icon: icon,
      colors: colors,
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: widget.dark ? 0.17 : 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      Color.lerp(color, Colors.white, 0.28)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboard() {
    final allHabits = habitNames.length;
    final habitProgress =
        allHabits == 0 ? 0.0 : completedHabits / allHabits;
    final goalCount = goals.length;
    final rightsCount = rights.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        _pageHeader(
          title: tr('পথচলা', 'Pathchola'),
          subtitle: tr(
            'নিজেকে গড়ো, লক্ষ্য ঠিক রাখো, প্রতিদিন এগিয়ে চলো।',
            'Build yourself, stay focused, and grow every day.',
          ),
          icon: Icons.auto_awesome_rounded,
          colors: const [Color(0xFF066B50), Color(0xFF15A878), gold],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.dark ? const Color(0xFF1B2634) : Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('আজকের দিন', 'Today'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      tr(
                        'প্রতিদিন একটু ভালো হওয়ার চেষ্টা করো।',
                        'Try to become a little better each day.',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: habitProgress),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) =>
                            CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor:
                              emerald.withValues(alpha: 0.12),
                          valueColor:
                              const AlwaysStoppedAnimation(emerald),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(habitProgress * 100).round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          tr('অভ্যাস', 'Habits'),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _sectionTitle(tr('তোমার অগ্রগতি', 'Your progress')),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.24,
          children: [
            _statCard(
              title: tr('মোট লক্ষ্য', 'Total goals'),
              value: '$goalCount',
              icon: Icons.flag_rounded,
              color: blue,
            ),
            _statCard(
              title: tr('সম্পন্ন লক্ষ্য', 'Goals completed'),
              value: '$completedGoals',
              icon: Icons.emoji_events_rounded,
              color: gold,
            ),
            _statCard(
              title: tr('আজকের অভ্যাস', 'Habits today'),
              value: '$completedHabits/$allHabits',
              icon: Icons.mosque_rounded,
              color: violet,
            ),
            _statCard(
              title: tr('দায়িত্ব সম্পন্ন', 'Responsibilities done'),
              value: '$completedRights/$rightsCount',
              icon: Icons.volunteer_activism_rounded,
              color: coral,
            ),
          ],
        ),
        _sectionTitle(tr('দ্রুত প্রবেশ', 'Quick access')),
        _actionTile(
          icon: Icons.flag_rounded,
          title: tr('আমার লক্ষ্য', 'My goals'),
          subtitle: tr('পরিকল্পনা ও অগ্রগতি', 'Plans and progress'),
          color: blue,
          onTap: () => setState(() => page = 1),
        ),
        _actionTile(
          icon: Icons.mosque_rounded,
          title: tr('দৈনিক ইবাদত', 'Daily worship'),
          subtitle: tr('অভ্যাসের হিসাব রাখো', 'Track daily habits'),
          color: violet,
          onTap: () => setState(() => page = 2),
        ),
        _actionTile(
          icon: Icons.volunteer_activism_rounded,
          title: tr('মানুষের হক', 'People’s rights'),
          subtitle: tr('দায়িত্ব ভুলে যেয়ো না', 'Remember your duties'),
          color: coral,
          onTap: () => setState(() => page = 3),
        ),
        _actionTile(
          icon: Icons.menu_book_rounded,
          title: tr('আত্মসমালোচনা', 'Reflection'),
          subtitle: tr('নিজের দিনটি পর্যালোচনা করো', 'Review your day'),
          color: teal,
          onTap: () => setState(() => page = 4),
        ),
      ],
    );
  }

  Widget goalsScreen() {
    final items = goals;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        _pageHeader(
          title: tr('লক্ষ্যের যাত্রা', 'Goal journey'),
          subtitle: tr(
            'বড় লক্ষ্য পূরণ হয় ছোট ছোট পদক্ষেপে।',
            'Big goals are reached through small steps.',
          ),
          icon: Icons.flag_rounded,
          colors: const [Color(0xFF315EE7), Color(0xFF8A50E8)],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _addGoal(),
          icon: const Icon(Icons.add_rounded),
          label: Text(tr('নতুন লক্ষ্য তৈরি করো', 'Create a new goal')),
          style: FilledButton.styleFrom(
            backgroundColor: blue,
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        _sectionTitle(
          tr('আমার লক্ষ্যসমূহ', 'My goals'),
          trailing: Text('${items.length}'),
        ),
        if (items.isEmpty)
          _emptyState(
            icon: Icons.flag_circle_rounded,
            title: tr('এখনো কোনো লক্ষ্য নেই', 'No goals yet'),
            subtitle: tr(
              'প্রথম লক্ষ্যটি তৈরি করে শুরু করো।',
              'Create your first goal to get started.',
            ),
            color: blue,
          ),
        ...items.map((goal) {
          final total = _number(goal['total']).toInt().clamp(1, 100000000);
          final progress =
              _number(goal['progress']).toInt().clamp(0, total);
          final ratio = progress / total;
          final done = progress >= total;
          final deadline =
              DateTime.tryParse(goal['deadline']?.toString() ?? '');

          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Container(
              decoration: BoxDecoration(
                color: widget.dark ? const Color(0xFF1B2634) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: blue.withValues(alpha: 0.15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            done
                                ? Icons.emoji_events_rounded
                                : Icons.track_changes_rounded,
                            color: done ? gold : blue,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            goal['title']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _addGoal(existing: goal);
                            } else if (value == 'delete') {
                              _confirmDelete(
                                title: goal['title']?.toString() ?? '',
                                onDelete: () {
                                  (data['goals'] as List).removeWhere(
                                    (g) => identical(g, goal),
                                  );
                                },
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(tr('সম্পাদনা', 'Edit')),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(tr('মুছে ফেলো', 'Delete')),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('অগ্রগতি', 'Progress'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$progress / $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ratio),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) =>
                          ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: blue.withValues(alpha: 0.12),
                          valueColor:
                              const AlwaysStoppedAnimation(blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          done ? Icons.check_circle_rounded : Icons.event,
                          size: 17,
                          color: done ? emerald : coral,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            done
                                ? tr('লক্ষ্য সম্পন্ন!', 'Goal completed!')
                                : deadline == null
                                    ? tr('শেষ তারিখ নির্ধারিত নয়', 'No deadline')
                                    : '${tr('শেষ তারিখ', 'Deadline')}: ${_formatDate(deadline)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: done ? emerald : null,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: tr('অগ্রগতি বাড়াও', 'Increase progress'),
                          onPressed: done
                              ? null
                              : () {
                                  goal['progress'] = (progress + 1).clamp(
                                    0,
                                    total,
                                  );
                                  _refreshAndSave();
                                },
                          icon: const Icon(Icons.add_rounded),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          tooltip: tr('কমানো', 'Decrease'),
                          onPressed: progress == 0
                              ? null
                              : () {
                                  goal['progress'] =
                                      (progress - 1).clamp(0, total);
                                  _refreshAndSave();
                                },
                          icon: const Icon(Icons.remove_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget worshipScreen() {
    final current = habits[dateKey] is Map
        ? Map<String, dynamic>.from(habits[dateKey] as Map)
        : <String, dynamic>{};

    final done = habitNames.asMap().entries.where(
          (e) => current[e.key.toString()] == true,
        ).length;

    final progress = done / habitNames.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        _pageHeader(
          title: tr('ইবাদতের আলো', 'Light of worship'),
          subtitle: tr(
            'নিয়মিত ছোট আমলও জীবনে বড় পরিবর্তন আনে।',
            'Consistent small deeds can make a big difference.',
          ),
          icon: Icons.mosque_rounded,
          colors: const [Color(0xFF6545C6), Color(0xFF079E9A)],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('দৈনিক অগ্রগতি', 'Daily progress'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '$done / ${habitNames.length} '
                        '${tr('সম্পন্ন', 'completed')}',
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: teal.withValues(alpha: 0.15),
                          valueColor:
                              const AlwaysStoppedAnimation(teal),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 31,
                  backgroundColor: teal.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.spa_rounded,
                    color: teal,
                    size: 31,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _chooseDate,
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(
            '${tr('তারিখ', 'Date')}: ${_formatDate(selectedDate)}',
          ),
        ),
        _sectionTitle(tr('আজকের আমল', 'Daily habits')),
        ...habitNames.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final checked = current[index.toString()] == true;
          final colors = [
            violet,
            teal,
            blue,
            coral,
            emerald,
            const Color(0xFFBA7C17),
            const Color(0xFFCA5685),
            const Color(0xFF5276C9),
          ];
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: checked
                    ? color.withValues(alpha: widget.dark ? 0.22 : 0.09)
                    : (widget.dark
                        ? const Color(0xFF1B2634)
                        : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: checked ? 0.55 : 0.15),
                ),
              ),
              child: CheckboxListTile(
                value: checked,
                activeColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                secondary: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(
                    checked
                        ? Icons.check_rounded
                        : Icons.auto_awesome_rounded,
                    color: color,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration:
                        checked ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  checked
                      ? tr('আলহামদুলিল্লাহ, সম্পন্ন', 'Completed')
                      : tr('সম্পন্ন হলে টিক দাও', 'Check when completed'),
                  style: const TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  final today = habits[dateKey] is Map
                      ? Map<String, dynamic>.from(habits[dateKey] as Map)
                      : <String, dynamic>{};

                  today[index.toString()] = value ?? false;
                  habits[dateKey] = today;
                  _refreshAndSave();
                },
              ),
            ),
          );
        }),
        if (done == habitNames.length)
          _emptyState(
            icon: Icons.emoji_events_rounded,
            title: tr('মাশাআল্লাহ!', 'MashaAllah!'),
            subtitle: tr(
              'আজকের সব অভ্যাস সম্পন্ন হয়েছে।',
              'All habits for this day are completed.',
            ),
            color: gold,
          ),
      ],
    );
  }

  Widget rightsScreen() {
    final items = rights;
    final pending = items.where((r) => r['done'] != true).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        _pageHeader(
          title: tr('মানুষের হক', 'People’s rights'),
          subtitle: tr(
            'দায়িত্ব, প্রতিশ্রুতি ও পাওনা মনে রাখো।',
            'Remember your duties, promises, and dues.',
          ),
          icon: Icons.volunteer_activism_rounded,
          colors: const [Color(0xFFEF684D), Color(0xFFFFB347)],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF795E), Color(0xFFED9B3D)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pending ${tr('টি অসম্পন্ন দায়িত্ব', 'pending duties')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tr(
                        'সময়মতো দায়িত্ব শেষ করার চেষ্টা করো।',
                        'Try to complete responsibilities on time.',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        FilledButton.icon(
          onPressed: () => _addRight(),
          icon: const Icon(Icons.add_rounded),
          label: Text(tr('নতুন দায়িত্ব যোগ করো', 'Add responsibility')),
          style: FilledButton.styleFrom(
            backgroundColor: coral,
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        _sectionTitle(tr('দায়িত্বের তালিকা', 'Responsibilities')),
        if (items.isEmpty)
          _emptyState(
            icon: Icons.volunteer_activism_rounded,
            title: tr('কোনো দায়িত্ব যোগ করা হয়নি', 'No responsibilities'),
            subtitle: tr(
              'দায়িত্ব বা প্রতিশ্রুতি এখানে লিখে রাখো।',
              'Keep track of your duties and promises here.',
            ),
            color: coral,
          ),
        ...items.map((item) {
          final isDone = item['done'] == true;
          final due = DateTime.tryParse(item['due']?.toString() ?? '');
          final overdue = !isDone &&
              due != null &&
              DateTime(due.year, due.month, due.day).isBefore(
                DateTime.now().subtract(
                  Duration(
                    hours: DateTime.now().hour,
                    minutes: DateTime.now().minute,
                    seconds: DateTime.now().second,
                  ),
                ),
              );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.dark ? const Color(0xFF1B2634) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: overdue
                      ? coral.withValues(alpha: 0.6)
                      : (isDone
                          ? emerald.withValues(alpha: 0.35)
                          : coral.withValues(alpha: 0.15)),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isDone,
                    activeColor: emerald,
                    onChanged: (value) {
                      item['done'] = value ?? false;
                      _refreshAndSave();
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']?.toString() ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              overdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.event_rounded,
                              size: 15,
                              color: overdue ? coral : teal,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                due == null
                                    ? tr('তারিখ নেই', 'No date')
                                    : '${_formatDate(due)}'
                                        '${overdue ? ' • ${tr('সময় পেরিয়েছে', 'Overdue')}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: overdue ? coral : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _addRight(existing: item);
                      } else if (value == 'delete') {
                        _confirmDelete(
                          title: item['title']?.toString() ?? '',
                          onDelete: () {
                            (data['rights'] as List).removeWhere(
                              (r) => identical(r, item),
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(tr('সম্পাদনা', 'Edit')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(tr('মুছে ফেলো', 'Delete')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget reflectionScreen() {
    final entries = reflections.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        _pageHeader(
          title: tr('নিজেকে জানো', 'Know yourself'),
          subtitle: tr(
            'দিন শেষে ভাবো—কী শিখলে, কী উন্নতি করবে?',
            'Reflect on what you learned and how to improve.',
          ),
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF008F95), Color(0xFF3678CF)],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.dark ? const Color(0xFF1B2634) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_calendar_rounded, color: teal),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      tr('আজকের ডায়েরি', 'Daily journal'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _chooseDate,
                    tooltip: tr('তারিখ নির্বাচন', 'Select date'),
                    icon: const Icon(Icons.calendar_month_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${tr('নির্বাচিত তারিখ', 'Selected date')}: ${_formatDate(selectedDate)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reflectionController,
                minLines: 7,
                maxLines: 12,
                maxLength: 5000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: tr(
                    'আজ কী ভালো কাজ করলে?\n'
                    'কোন বিষয়ে উন্নতি দরকার?\n'
                    'আগামীকাল কী করতে চাও?',
                    'What went well today?\n'
                    'What could you improve?\n'
                    'What will you do tomorrow?',
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: teal.withValues(alpha: 0.07),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: teal.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: teal.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  final text = reflectionController.text.trim();

                  if (text.isEmpty) {
                    reflections.remove(dateKey);
                  } else {
                    reflections[dateKey] = text;
                  }

                  _refreshAndSave();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr('ডায়েরি সংরক্ষণের অনুরোধ করা হয়েছে', 'Journal save requested'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded),
                label: Text(tr('ডায়েরি সংরক্ষণ', 'Save journal')),
                style: FilledButton.styleFrom(
                  backgroundColor: teal,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
        _sectionTitle(
          tr('আগের দিনের লেখা', 'Previous entries'),
          trailing: Text('${entries.length}'),
        ),
        if (entries.isEmpty)
          _emptyState(
            icon: Icons.auto_stories_rounded,
            title: tr('এখনো কোনো লেখা নেই', 'No entries yet'),
            subtitle: tr(
              'তোমার ডায়েরির লেখা এখানে দেখা যাবে।',
              'Your saved reflections will appear here.',
            ),
            color: teal,
          ),
        ...entries.take(30).map((entry) {
          final parsed = DateTime.tryParse(entry.key);
          final displayDate =
              parsed == null ? entry.key : _formatDate(parsed);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                setState(() {
                  if (parsed != null) selectedDate = parsed;
                  reflectionController.text = entry.value.toString();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.article_rounded,
                        color: teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.value.toString(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: tr('মুছে ফেলো', 'Delete'),
                      onPressed: () => _confirmDelete(
                        title: displayDate,
                        onDelete: () {
                          reflections.remove(entry.key);
                          if (entry.key == dateKey) {
                            reflectionController.clear();
                          }
                        },
                      ),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: coral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: widget.dark ? 0.13 : 0.07),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 47, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsSheet() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('সেটিংস', 'Settings'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: widget.english,
              onChanged: widget.onLanguageChanged,
              secondary: const Icon(Icons.translate_rounded, color: blue),
              title: Text(tr('English ভাষা', 'English language')),
              subtitle: Text(tr('বাংলা / English', 'English / Bangla')),
            ),
            SwitchListTile(
              value: widget.dark,
              onChanged: widget.onThemeChanged,
              secondary: const Icon(Icons.dark_mode_rounded, color: violet),
              title: Text(tr('ডার্ক মোড', 'Dark mode')),
              subtitle: Text(
                tr('রাতের জন্য আরামদায়ক থিম', 'A comfortable dark theme'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'পথচলা • নিজের উন্নতির প্রতিদিনের সঙ্গী',
                'Pathchola • Your daily companion for growth',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loadError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(tr('ডেটা লোড সমস্যা', 'Data loading issue')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: coral,
                size: 58,
              ),
              const SizedBox(height: 18),
              Text(
                tr(
                  'আগের সংরক্ষিত ডেটা পড়া যায়নি।',
                  'Previously saved data could not be read.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tr(
                  'তোমার পুরোনো ডেটা যেন মুছে না যায়, তাই এখন নতুন ডেটা সংরক্ষণ বন্ধ রাখা হয়েছে। অ্যাপের ডেটা ক্লিয়ার বা অ্যাপ আনইনস্টল কোরো না।',
                  'Saving is disabled to avoid overwriting your old data. Do not clear app storage or uninstall the app.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () async {
                  setState(() {
                    loading = true;
                    loadError = false;
                  });
                  await _loadData();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(tr('আবার চেষ্টা করো', 'Try again')),
              ),
            ],
          ),
        ),
      );
    }

    final pages = [
      dashboard(),
      goalsScreen(),
      worshipScreen(),
      rightsScreen(),
      reflectionScreen(),
    ];

    final titles = [
      tr('পথচলা', 'Pathchola'),
      tr('লক্ষ্যের যাত্রা', 'Goal journey'),
      tr('ইবাদতের আলো', 'Worship'),
      tr('মানুষের হক', 'People’s rights'),
      tr('আত্মসমালোচনা', 'Reflection'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            titles[page],
            key: ValueKey(page),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        actions: [
          if (saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: tr('সেটিংস', 'Settings'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => _settingsSheet(),
              ),
              icon: const Icon(Icons.tune_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          if (saveError != null)
            MaterialBanner(
              content: Text(saveError!),
              leading: const Icon(Icons.error_outline_rounded, color: coral),
              actions: [
                TextButton(
                  onPressed: _saveData,
                  child: Text(tr('আবার চেষ্টা', 'Retry')),
                ),
              ],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slide,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(page),
                child: pages[page],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) {
          FocusScope.of(context).unfocus();
          setState(() => page = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: tr('হোম', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag_rounded),
            label: tr('লক্ষ্য', 'Goals'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque_rounded),
            label: tr('ইবাদত', 'Worship'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.volunteer_activism_outlined),
            selectedIcon: const Icon(Icons.volunteer_activism_rounded),
            label: tr('দায়িত্ব', 'Duties'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: tr('ডায়েরি', 'Journal'),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const AnimatedGradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.19),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(icon, size: 34, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
