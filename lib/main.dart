
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PathcholaApp());
}

class PathcholaApp extends StatefulWidget {
  const PathcholaApp({super.key});

  @override
  State<PathcholaApp> createState() => _PathcholaAppState();
}

class _PathcholaAppState extends State<PathcholaApp> {
  bool english = false;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        english = prefs.getBool('pathchola_english') ?? false;
        darkMode = prefs.getBool('pathchola_dark') ?? false;
      });
    } catch (_) {
      // App remains usable with default settings.
    }
  }

  Future<void> _setLanguage(bool value) async {
    setState(() => english = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pathchola_english', value);
    } catch (_) {}
  }

  Future<void> _setTheme(bool value) async {
    setState(() => darkMode = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pathchola_dark', value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF145A3A);
    const gold = Color(0xFFC9A45C);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'পথচলা',
      locale: Locale(english ? 'en' : 'bn'),
      supportedLocales: const [Locale('bn'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          primary: green,
          secondary: gold,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          secondary: gold,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF103D2B),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: TrackerHome(
        english: english,
        darkMode: darkMode,
        onLanguageChanged: _setLanguage,
        onThemeChanged: _setTheme,
      ),
    );
  }
}

class TrackerHome extends StatefulWidget {
  final bool english;
  final bool darkMode;
  final ValueChanged<bool> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const TrackerHome({
    super.key,
    required this.english,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

class _TrackerHomeState extends State<TrackerHome> {
  static const _storageKey = 'pathchola_v1_data';

  Map<String, dynamic> data = {
    'goals': <dynamic>[],
    'habits': <String, dynamic>{},
    'reflections': <String, dynamic>{},
    'rights': <dynamic>[],
  };

  bool loading = true;
  String? loadError;
  int tab = 0;
  DateTime selectedDay = DateTime.now();
  late final TextEditingController reflectionController;

  bool get en => widget.english;

  String tr(String bn, String english) => en ? english : bn;

  String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get today => dayKey(selectedDay);

  String dateText(DateTime d) => dayKey(d);

  @override
  void initState() {
    super.initState();
    reflectionController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    reflectionController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          data = {
            'goals': decoded['goals'] is List
                ? decoded['goals']
                : <dynamic>[],
            'habits': decoded['habits'] is Map
                ? Map<String, dynamic>.from(decoded['habits'])
                : <String, dynamic>{},
            'reflections': decoded['reflections'] is Map
                ? Map<String, dynamic>.from(decoded['reflections'])
                : <String, dynamic>{},
            'rights': decoded['rights'] is List
                ? decoded['rights']
                : <dynamic>[],
          };
        }
      }
    } catch (e) {
      loadError = e.toString();
    } finally {
      if (mounted) {
        reflectionController.text = currentReflection;
        setState(() => loading = false);
      }
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(_storageKey, jsonEncode(data));
      if (!saved && mounted) {
        showMessage(tr('তথ্য সংরক্ষণ করা যায়নি।', 'Could not save data.'));
      }
    } catch (e) {
      if (mounted) {
        showMessage(tr(
          'সংরক্ষণে সমস্যা হয়েছে। আবার চেষ্টা করো।',
          'Saving failed. Please try again.',
        ));
      }
    }
    if (mounted) setState(() {});
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<dynamic> get goals => data['goals'] as List<dynamic>;
  List<dynamic> get rights => data['rights'] as List<dynamic>;

  Map<String, dynamic> get allHabits =>
      data['habits'] as Map<String, dynamic>;

  Map<String, dynamic> get todayHabits {
    final raw = allHabits[today];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  Map<String, dynamic> get reflections =>
      data['reflections'] as Map<String, dynamic>;

  String get currentReflection => reflections[today] as String? ?? '';

  final List<String> habitBn = [
    'পাঁচ ওয়াক্ত সালাত',
    'কুরআন তিলাওয়াত',
    'হাদিস অধ্যয়ন',
    'যিকির ও দোয়া',
    'ইসলামিক বই পড়া',
    'সদাকাহ',
    'কিয়ামুল লাইল',
    'পরিবারের হক আদায়',
    'ভালো ব্যবহার',
  ];

  final List<String> habitEn = [
    'Five daily prayers',
    'Quran recitation',
    'Hadith study',
    'Dhikr and dua',
    'Read an Islamic book',
    'Sadaqah',
    'Qiyam al-Layl',
    'Family responsibilities',
    'Kind behaviour',
  ];

  Future<void> chooseDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      selectedDay = picked;
      reflectionController.text = currentReflection;
    });
  }

  Future<void> addGoal({int? index}) async {
    final old = index == null
        ? null
        : Map<String, dynamic>.from(goals[index] as Map);

    final titleController =
        TextEditingController(text: old?['title'] as String? ?? '');
    final targetController = TextEditingController(
      text: '${old?['total'] ?? 30}',
    );
    final formKey = GlobalKey<FormState>();

    DateTime deadline = old == null
        ? DateTime.now().add(const Duration(days: 30))
        : DateTime.tryParse(old['deadline'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 30));

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: Text(tr(
            old == null ? 'নতুন লক্ষ্য' : 'লক্ষ্য সম্পাদনা',
            old == null ? 'New goal' : 'Edit goal',
          )),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: tr('লক্ষ্যের নাম', 'Goal title'),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? tr('নাম লিখো', 'Enter a title')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr('মোট ধাপ বা দিন', 'Total steps or days'),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1
                          ? tr('সঠিক সংখ্যা দাও', 'Enter a valid number')
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(dateText(deadline)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: deadline,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) refresh(() => deadline = picked);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('বাতিল', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(tr('সংরক্ষণ', 'Save')),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final total = int.parse(targetController.text);
      final previousProgress = old?['progress'] as int? ?? 0;

      final item = <String, dynamic>{
        'title': titleController.text.trim(),
        'total': total,
        'progress': previousProgress.clamp(0, total),
        'deadline': deadline.toIso8601String(),
        'created': old?['created'] ?? DateTime.now().toIso8601String(),
      };

      if (index == null) {
        goals.add(item);
      } else {
        goals[index] = item;
      }
      await saveData();
    }

    titleController.dispose();
    targetController.dispose();
  }

  Future<void> deleteGoal(int index) async {
    final confirmed = await confirmDelete(
      tr('লক্ষ্য মুছে ফেলবে?', 'Delete this goal?'),
    );
    if (confirmed) {
      goals.removeAt(index);
      await saveData();
    }
  }

  Future<void> updateGoal(int index, int change) async {
    final goal = Map<String, dynamic>.from(goals[index] as Map);
    final total = goal['total'] as int? ?? 1;
    final progress = goal['progress'] as int? ?? 0;
    final updated = (progress + change).clamp(0, total);
    goal['progress'] = updated;
    goals[index] = goal;
    await saveData();

    if (updated == total && progress < total && mounted) {
      showMessage(tr(
        'অভিনন্দন! তুমি লক্ষ্য পূরণ করেছ।',
        'Congratulations! You reached your goal.',
      ));
    }
  }

  Future<bool> confirmDelete(String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr('বাতিল', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr('মুছে ফেলো', 'Delete')),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> toggleHabit(int index, bool value) async {
    final habits = todayHabits;
    habits['$index'] = value;
    allHabits[today] = habits;
    await saveData();
  }

  Future<void> saveReflection() async {
    reflections[today] = reflectionController.text;
    await saveData();
    if (mounted) {
      showMessage(tr('আত্মসমালোচনা সংরক্ষিত হয়েছে।', 'Reflection saved.'));
    }
  }

  Future<void> addRight({int? index}) async {
    final old = index == null
        ? null
        : Map<String, dynamic>.from(rights[index] as Map);
    final controller =
        TextEditingController(text: old?['title'] as String? ?? '');
    DateTime due = DateTime.tryParse(old?['due'] as String? ?? '') ??
        DateTime.now().add(const Duration(days: 7));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: Text(tr(
            old == null ? 'নতুন দায়িত্ব' : 'দায়িত্ব সম্পাদনা',
            old == null ? 'New action' : 'Edit action',
          )),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr(
                  'যেমন: ক্ষমা চাওয়া, পাওনা ফেরত বা প্রতিশ্রুতি পূরণ।',
                  'For example: apologise, return what is owed, or fulfil a promise.',
                )),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: tr('করণীয় লিখো', 'Action to take'),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text('${tr('শেষ তারিখ', 'Due')}: ${dateText(due)}'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: due,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) refresh(() => due = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('বাতিল', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, true);
                }
              },
              child: Text(tr('সংরক্ষণ', 'Save')),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final item = <String, dynamic>{
        'title': controller.text.trim(),
        'due': due.toIso8601String(),
        'done': old?['done'] == true,
      };
      if (index == null) {
        rights.add(item);
      } else {
        rights[index] = item;
      }
      await saveData();
    }
    controller.dispose();
  }

  Future<void> deleteRight(int index) async {
    final confirmed = await confirmDelete(
      tr('এই কাজটি মুছে ফেলবে?', 'Delete this action?'),
    );
    if (confirmed) {
      rights.removeAt(index);
      await saveData();
    }
  }

  Widget sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget dayPickerButton() {
    return OutlinedButton.icon(
      onPressed: chooseDay,
      icon: const Icon(Icons.calendar_month),
      label: Text(dateText(selectedDay)),
    );
  }

  Widget reminderCard(String title, String message, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC9A45C), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
      ),
    );
  }

  Widget dashboard() {
    final completed = todayHabits.values.where((v) => v == true).length;
    final total = habitBn.length;
    final percent = completed / total;

    final overdueGoals = goals.where((item) {
      final g = Map<String, dynamic>.from(item as Map);
      final deadline = DateTime.tryParse(g['deadline'] as String? ?? '');
      return (g['progress'] as int? ?? 0) < (g['total'] as int? ?? 1) &&
          deadline != null &&
          deadline.isBefore(DateTime.now()) &&
          dayKey(deadline) != dayKey(DateTime.now());
    }).length;

    final openRights = rights.where((item) {
      return (item as Map)['done'] != true;
    }).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF145A3A), Color(0xFF23734D)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('আসসালামু আলাইকুম', 'Assalamu Alaikum'),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                tr('আজকের পথচলা', 'Your journey today'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(
                  'নিশ্চয়ই কষ্টের সাথে স্বস্তি আছে। — সূরা আশ-শারহ ৯৪:৫–৬',
                  'With hardship comes ease. — Quran 94:5–6',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                tr('তারিখ: ${dateText(selectedDay)}',
                    'Date: ${dateText(selectedDay)}'),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        sectionTitle(tr('দিন নির্বাচন', 'Select a day')),
        dayPickerButton(),
        sectionTitle(tr('আজকের ইবাদতের অগ্রগতি', 'Worship progress')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    color: const Color(0xFFC9A45C),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completed / $total',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(tr('অভ্যাস সম্পন্ন', 'Habits completed')),
                      Text('${(percent * 100).round()}%'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (overdueGoals > 0)
          reminderCard(
            tr('লক্ষ্য পিছিয়ে আছে', 'Goals overdue'),
            tr('$overdueGoalsটি লক্ষ্য পর্যালোচনা করো।',
                'Review $overdueGoals overdue goal(s).'),
            Icons.warning_amber_rounded,
          ),
        if (openRights > 0)
          reminderCard(
            tr('অসম্পূর্ণ দায়িত্ব', 'Outstanding actions'),
            tr('$openRightsটি কাজ এখনও বাকি।',
                '$openRights action(s) remain incomplete.'),
            Icons.volunteer_activism,
          ),
        sectionTitle(
          tr('লক্ষ্যসমূহ', 'Your goals'),
          trailing: IconButton(
            onPressed: () => addGoal(),
            icon: const Icon(Icons.add_circle),
          ),
        ),
        if (goals.isEmpty)
          Text(tr('এখনও কোনো লক্ষ্য নেই। + চাপ দিয়ে যোগ করো।',
              'No goals yet. Tap + to add one.')),
        ...goals.asMap().entries.map((entry) {
          final g = Map<String, dynamic>.from(entry.value as Map);
          final progress = g['progress'] as int? ?? 0;
          final totalSteps = g['total'] as int? ?? 1;
          final ratio = (progress / totalSteps).clamp(0.0, 1.0);
          final deadline =
              DateTime.tryParse(g['deadline'] as String? ?? '');
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g['title'] as String? ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') addGoal(index: entry.key);
                          if (v == 'delete') deleteGoal(entry.key);
                        },
                        itemBuilder: (_) => [
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
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: ratio),
                  const SizedBox(height: 8),
                  Text('$progress / $totalSteps • ${(ratio * 100).round()}%'),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => updateGoal(entry.key, -1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () => updateGoal(entry.key, 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      if (deadline != null)
                        Text(
                          dateText(deadline),
                          style: const TextStyle(fontSize: 12),
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

  Widget habitScreen() {
    final checked = todayHabits;
    final completed = checked.values.where((v) => v == true).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('ইবাদত ও দৈনিক অভ্যাস', 'Worship and daily habits'),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        dayPickerButton(),
        Text(tr(
          'নিজের অগ্রগতি সৎভাবে চিহ্নিত করো। এটি আত্মউন্নতির জন্য।',
          'Track your progress honestly for self-improvement.',
        )),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: completed / habitBn.length),
        const SizedBox(height: 6),
        Text('$completed / ${habitBn.length}'),
        const SizedBox(height: 8),
        ...List.generate(habitBn.length, (i) {
          return Card(
            child: CheckboxListTile(
              value: checked['$i'] == true,
              onChanged: (v) => toggleHabit(i, v ?? false),
              title: Text(en ? habitEn[i] : habitBn[i]),
              activeColor: const Color(0xFF145A3A),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
      ],
    );
  }

  Widget rightsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('মানুষের হক ও সংশোধন', 'Rights and making amends'),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tr(
          'ক্ষমা চাওয়া, পাওনা ফেরত, ক্ষতিপূরণ বা প্রতিশ্রুতি পূরণের মতো কাজ ব্যক্তিগতভাবে লিখে রাখো।',
          'Privately track actions such as apologising, returning what is owed, making amends, or fulfilling promises.',
        )),
        const SizedBox(height: 12),
        if (rights.isEmpty)
          Text(tr('এখন কোনো কাজ যোগ করা হয়নি।',
              'No actions added yet.')),
        ...rights.asMap().entries.map((entry) {
          final r = Map<String, dynamic>.from(entry.value as Map);
          final due = DateTime.tryParse(r['due'] as String? ?? '') ??
              DateTime.now();
          final done = r['done'] == true;
          final late = !done &&
              due.isBefore(DateTime.now()) &&
              dayKey(due) != dayKey(DateTime.now());

          return Card(
            child: ListTile(
              leading: Checkbox(
                value: done,
                onChanged: (value) async {
                  r['done'] = value ?? false;
                  rights[entry.key] = r;
                  await saveData();
                },
              ),
              title: Text(
                r['title'] as String? ?? '',
                style: TextStyle(
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '${tr('শেষ তারিখ', 'Due')}: ${dateText(due)}'
                '${late ? tr(' • সময় পেরিয়েছে', ' • Overdue') : ''}',
                style: TextStyle(color: late ? Colors.red : null),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') addRight(index: entry.key);
                  if (v == 'delete') deleteRight(entry.key);
                },
                itemBuilder: (_) => [
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
            ),
          );
        }),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => addRight(),
          icon: const Icon(Icons.add),
          label: Text(tr('নতুন কাজ যোগ করো', 'Add an action')),
        ),
      ],
    );
  }

  Widget reflectionScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('দিনের আত্মসমালোচনা', 'Daily reflection'),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        dayPickerButton(),
        const SizedBox(height: 8),
        Text(tr(
          'আজ কী ভালো করেছি? কী সংশোধন করা দরকার? কারও হক বাকি আছে? আগামীকাল কোন কাজটি আগে করব?',
          'What went well today? What needs correction? Is anyone’s right outstanding? What should I prioritise tomorrow?',
        )),
        const SizedBox(height: 16),
        TextField(
          controller: reflectionController,
          minLines: 8,
          maxLines: 14,
          decoration: InputDecoration(
            hintText: tr('নিজের জন্য লিখে রাখো…', 'Write a private note…'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: saveReflection,
          icon: const Icon(Icons.save),
          label: Text(tr('এই দিনের নোট সংরক্ষণ', 'Save this day’s reflection')),
        ),
        sectionTitle(tr('আগের দিনের নোট', 'Previous reflections')),
        ...reflections.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key))
          ..take(30).map((entry) => Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(entry.key),
              subtitle: Text(
                entry.value.toString().isEmpty
                    ? tr('খালি নোট', 'Empty note')
                    : entry.value.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                final parts = entry.key.split('-');
                if (parts.length == 3) {
                  final date = DateTime.tryParse(entry.key);
                  if (date != null) {
                    setState(() {
                      selectedDay = date;
                      reflectionController.text = currentReflection;
                    });
                  }
                }
              },
            ),
          )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      tr('পথচলা', 'Pathchola'),
      tr('ইবাদত', 'Worship'),
      tr('মানুষের হক', 'Rights'),
      tr('আত্মসমালোচনা', 'Reflection'),
    ];

    final pages = [
      dashboard(),
      habitScreen(),
      rightsScreen(),
      reflectionScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[tab]),
        actions: [
          IconButton(
            tooltip: tr('থিম পরিবর্তন', 'Toggle theme'),
            onPressed: () => widget.onThemeChanged(!widget.darkMode),
            icon: Icon(
              widget.darkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          TextButton(
            onPressed: () => widget.onLanguageChanged(!en),
            child: Text(
              en ? 'বাংলা' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber, size: 48),
                        const SizedBox(height: 12),
                        Text(tr(
                          'আগের তথ্য পড়তে সমস্যা হয়েছে। অ্যাপ চালু রাখা হয়েছে।',
                          'There was a problem reading saved data. The app is still available.',
                        )),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              loadError = null;
                              loading = true;
                            });
                            loadData();
                          },
                          child: Text(tr('আবার চেষ্টা', 'Retry')),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            loadError = null;
                            loading = false;
                          }),
                          child: Text(tr('সংরক্ষিত তথ্য বাদ দিয়ে চালু করো',
                              'Continue without loading saved data')),
                        ),
                      ],
                    ),
                  ),
                )
              : IndexedStack(
                  index: tab,
                  children: pages,
                ),
      floatingActionButton: !loading && loadError == null && tab == 0
          ? FloatingActionButton(
              onPressed: () => addGoal(),
              backgroundColor: const Color(0xFFC9A45C),
              foregroundColor: Colors.black,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: tr('লক্ষ্য', 'Goals'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque),
            label: tr('ইবাদত', 'Worship'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.handshake_outlined),
            selectedIcon: const Icon(Icons.handshake),
            label: tr('হক', 'Rights'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: tr('হিসাব', 'Reflect'),
          ),
        ],
      ),
    );
  }
}
