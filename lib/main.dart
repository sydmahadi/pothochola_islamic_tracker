
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
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
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: TrackerHome(
        english: english,
        onLanguageChanged: (value) {
          setState(() => english = value);
        },
      ),
    );
  }
}

class TrackerHome extends StatefulWidget {
  final bool english;
  final ValueChanged<bool> onLanguageChanged;

  const TrackerHome({
    super.key,
    required this.english,
    required this.onLanguageChanged,
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
  int tab = 0;

  bool get en => widget.english;

  String tr(String bn, String english) => en ? english : bn;

  String get today {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = {
            'goals': decoded['goals'] ?? <dynamic>[],
            'habits': decoded['habits'] ?? <String, dynamic>{},
            'reflections':
                decoded['reflections'] ?? <String, dynamic>{},
            'rights': decoded['rights'] ?? <dynamic>[],
          };
        }
      } catch (_) {
        // Keep default data if a saved value cannot be decoded.
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data));
    if (mounted) setState(() {});
  }

  List<dynamic> get goals => data['goals'] as List<dynamic>;
  List<dynamic> get rights => data['rights'] as List<dynamic>;

  Map<String, dynamic> get todayHabits {
    final all = data['habits'] as Map<String, dynamic>;
    return Map<String, dynamic>.from(
      all[today] as Map? ?? <String, dynamic>{},
    );
  }

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

  Future<void> addGoal() async {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '30');
    final formKey = GlobalKey<FormState>();
    DateTime deadline = DateTime.now().add(const Duration(days: 30));

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refreshDialog) => AlertDialog(
          title: Text(tr('নতুন লক্ষ্য', 'New goal')),
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
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? tr('লক্ষ্যের নাম লিখো', 'Enter a goal')
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr(
                        'মোট ধাপ বা দিনের সংখ্যা',
                        'Total steps or days',
                      ),
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
                    label: Text(
                      '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-'
                      '${deadline.day.toString().padLeft(2, '0')}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        refreshDialog(() => deadline = picked);
                      }
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
      goals.add({
        'title': titleController.text.trim(),
        'total': int.parse(targetController.text),
        'progress': 0,
        'deadline': deadline.toIso8601String(),
        'created': DateTime.now().toIso8601String(),
      });
      await saveData();
    }

    titleController.dispose();
    targetController.dispose();
  }

  Future<void> addRight() async {
    final titleController = TextEditingController();
    DateTime due = DateTime.now().add(const Duration(days: 7));

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refreshDialog) => AlertDialog(
          title: Text(tr('মানুষের হক ও সংশোধন', 'Rights and amends')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr(
                  'যেমন: ক্ষমা চাওয়া, পাওনা ফেরত, ক্ষতিপূরণ বা প্রতিশ্রুতি পূরণ।',
                  'For example: apologise, return what is owed, make amends, or fulfil a promise.',
                ),
              ),
              TextField(
                controller: titleController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: tr('করণীয় লিখো', 'Action to take'),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: due,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) refreshDialog(() => due = picked);
                },
                child: Text(
                  '${tr('তারিখ', 'Due')}: ${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('বাতিল', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
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
      rights.add({
        'title': titleController.text.trim(),
        'due': due.toIso8601String(),
        'done': false,
      });
      await saveData();
    }
    titleController.dispose();
  }

  Future<void> updateGoal(int index, int change) async {
    final goal = Map<String, dynamic>.from(goals[index] as Map);
    final total = goal['total'] as int;
    final progress = goal['progress'] as int;
    goal['progress'] = (progress + change).clamp(0, total);
    goals[index] = goal;
    await saveData();

    if ((goal['progress'] as int) == total &&
        progress < total &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('অভিনন্দন! তুমি লক্ষ্য পূরণ করেছ।',
                'Congratulations! You reached your goal.'),
          ),
        ),
      );
    }
  }

  Future<void> toggleHabit(int index, bool value) async {
    final all = data['habits'] as Map<String, dynamic>;
    final habits = todayHabits;
    habits['$index'] = value;
    all[today] = habits;
    await saveData();
  }

  Future<void> saveReflection(String text) async {
    final reflections = data['reflections'] as Map<String, dynamic>;
    reflections[today] = text;
    await saveData();
  }

  Widget sectionTitle(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
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

  Widget reminderCard(String title, String message, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF145A3A), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
      ),
    );
  }

  Widget dashboard() {
    final completed = todayHabits.values.where((v) => v == true).length;
    final total = habitBn.length;
    final percent = total == 0 ? 0.0 : completed / total;

    final overdueGoals = goals.where((item) {
      final g = Map<String, dynamic>.from(item as Map);
      return (g['progress'] as int) < (g['total'] as int) &&
          DateTime.parse(g['deadline'] as String).isBefore(
            DateTime.now().subtract(const Duration(days: 1)),
          );
    }).length;

    final openRights = rights.where((item) {
      final r = Map<String, dynamic>.from(item as Map);
      return r['done'] != true;
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
                tr('আজকের তারিখ: $today', 'Today: $today'),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        sectionTitle(tr('আজকের অগ্রগতি', 'Today’s progress')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  height: 78,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    backgroundColor: Colors.black12,
                    color: const Color(0xFF145A3A),
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
                      Text(tr('অভ্যাস সম্পন্ন', 'habits completed')),
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
            tr('$overdueGoalsটি লক্ষ্য পরীক্ষা করো এবং পরিকল্পনা ঠিক করো।',
                'Review $overdueGoals overdue goal(s) and adjust your plan.'),
            Icons.warning_amber_rounded,
          ),
        if (openRights > 0)
          reminderCard(
            tr('অসম্পূর্ণ দায়িত্ব', 'Outstanding responsibilities'),
            tr('$openRightsটি কাজ এখনও সম্পন্ন হয়নি।',
                '$openRights action(s) are still incomplete.'),
            Icons.volunteer_activism,
          ),
        sectionTitle(tr('আজকের লক্ষ্যসমূহ', 'Your goals')),
        if (goals.isEmpty)
          Text(tr(
            'এখনও কোনো লক্ষ্য নেই। + বোতামে চাপ দিয়ে লক্ষ্য যোগ করো।',
            'No goals yet. Use the + button to add one.',
          )),
        ...goals.asMap().entries.map((entry) {
          final g = Map<String, dynamic>.from(entry.value as Map);
          final progress = g['progress'] as int;
          final totalSteps = g['total'] as int;
          final ratio = totalSteps == 0 ? 0.0 : progress / totalSteps;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: ratio),
                  const SizedBox(height: 8),
                  Text('$progress / $totalSteps  •  ${(ratio * 100).round()}%'),
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
                      Text(
                        '${DateTime.parse(g['deadline'] as String).year}-'
                        '${DateTime.parse(g['deadline'] as String).month.toString().padLeft(2, '0')}-'
                        '${DateTime.parse(g['deadline'] as String).day.toString().padLeft(2, '0')}',
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('আজকের ইবাদত ও অভ্যাস', 'Today’s worship and habits'),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tr(
          'নিজের অগ্রগতি সৎভাবে চিহ্নিত করো। এটি আত্মউন্নতির জন্য, অন্যকে বিচার করার জন্য নয়।',
          'Track your progress honestly. This is for self-improvement, not judging others.',
        )),
        const SizedBox(height: 12),
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
          'ব্যক্তিগতভাবে করণীয় লিখে রাখো। প্রয়োজন অনুযায়ী ক্ষমা চাওয়া, পাওনা ফেরত বা ক্ষতিপূরণ দেওয়ার কাজ সম্পন্ন হলে চিহ্নিত করো।',
          'Keep a private action list. Mark actions complete when you have apologised, returned what is owed, or made appropriate amends.',
        )),
        const SizedBox(height: 12),
        if (rights.isEmpty)
          Text(tr('এখন কোনো কাজ যোগ করা হয়নি।', 'No actions added yet.')),
        ...rights.asMap().entries.map((entry) {
          final r = Map<String, dynamic>.from(entry.value as Map);
          final due = DateTime.parse(r['due'] as String);
          final done = r['done'] == true;
          final late = !done && due.isBefore(DateTime.now());
          return Card(
            child: CheckboxListTile(
              value: done,
              onChanged: (value) async {
                r['done'] = value ?? false;
                rights[entry.key] = r;
                await saveData();
              },
              title: Text(r['title'] as String),
              subtitle: Text(
                '${tr('শেষ তারিখ', 'Due')}: ${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}'
                '${late ? tr(' • সময় পেরিয়েছে', ' • Overdue') : ''}',
                style: TextStyle(color: late ? Colors.red : null),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: addRight,
          icon: const Icon(Icons.add),
          label: Text(tr('নতুন কাজ যোগ করো', 'Add an action')),
        ),
      ],
    );
  }

  Widget reflectionScreen() {
    final reflections = data['reflections'] as Map<String, dynamic>;
    final controller = TextEditingController(
      text: reflections[today] as String? ?? '',
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('দিনের আত্মসমালোচনা', 'Daily reflection'),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(tr(
          'আজ কী ভালো করেছি? কী সংশোধন করা দরকার? কারও হক বাকি আছে? আগামীকাল কোন কাজটি আগে করব?',
          'What went well today? What needs correction? Is anyone’s right outstanding? What should I prioritise tomorrow?',
        )),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
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
          onPressed: () async {
            await saveReflection(controller.text);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('সংরক্ষণ হয়েছে', 'Saved'))),
              );
            }
          },
          icon: const Icon(Icons.save),
          label: Text(tr('আজকের হিসাব সংরক্ষণ', 'Save reflection')),
        ),
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
          : pages[tab],
      floatingActionButton: tab == 0
          ? FloatingActionButton(
              onPressed: addGoal,
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
