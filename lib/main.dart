import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/worship_screen.dart';
import 'screens/rights_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/report_screen.dart';
import 'services/storage_service.dart';
import 'services/daily_content_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PathcholaApp());
}

class PathcholaApp extends StatefulWidget {
  const PathcholaApp({super.key});

  @override
  State<PathcholaApp> createState() => _PathcholaAppState();
}

class _PathcholaAppState extends State<PathcholaApp> {
  final StorageService _storage = StorageService();

  Map<String, dynamic> _data = {};
  bool _english = false;
  bool _dark = true;
  bool _loading = true;
  bool _dailyDialogShown = false;
  String? _loadError;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait([
        _storage.loadData(),
        _storage.loadEnglish(),
        _storage.loadDark(),
      ]);

      if (!mounted) return;

      setState(() {
        _data = Map<String, dynamic>.from(
          results[0] as Map<String, dynamic>,
        );
        _english = results[1] as bool;
        _dark = results[2] as bool;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_dailyDialogShown && _loadError == null) {
          _dailyDialogShown = true;
          _showDailyPopup();
        }
      });
    } catch (e, stackTrace) {
      debugPrint('PATHCHOLA LOAD ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _changeData(Map<String, dynamic> newData) async {
    final previous = _data;

    setState(() {
      _data = newData;
    });

    try {
      await _storage.saveData(newData);
    } catch (e) {
      debugPrint('PATHCHOLA SAVE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _data = previous;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _english
                ? 'Could not save data. Please try again.'
                : 'ডেটা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।',
          ),
        ),
      );
    }
  }

  Future<void> _toggleLanguage() async {
    final next = !_english;
    setState(() => _english = next);

    try {
      await _storage.saveEnglish(next);
    } catch (e) {
      debugPrint('Language setting error: $e');
    }
  }

  Future<void> _toggleTheme() async {
    final next = !_dark;
    setState(() => _dark = next);

    try {
      await _storage.saveDark(next);
    } catch (e) {
      debugPrint('Theme setting error: $e');
    }
  }

  Future<void> _showDailyPopup() async {
    if (!mounted) return;

    final item = DailyContentService.forToday();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            item.isQuran ? Icons.menu_book_rounded : Icons.auto_stories_rounded,
            size: 34,
            color: const Color(0xFFC9A45C),
          ),
          title: Text(
            item.isQuran
                ? (_english ? 'Verse of the day' : 'আজকের কুরআনের আয়াত')
                : (_english ? 'Hadith of the day' : 'আজকের হাদিস'),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item.arabic,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _english ? item.english : item.bangla,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, height: 1.6),
                ),
                const SizedBox(height: 14),
                Text(
                  item.reference,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_english ? 'Continue' : 'শুরু করি'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF087F5B),
      brightness: _dark ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'পথচলা',
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme.copyWith(
          primary: const Color(0xFF087F5B),
          secondary: const Color(0xFFC9A45C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        cardTheme: CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF101A17),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: const Color(0xFF1B2924),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 18),
              Text(_english ? 'Loading Pathchola...' : 'পথচলা চালু হচ্ছে...'),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('পথচলা')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  _english
                      ? 'Previous saved data could not be read.'
                      : 'আগের সংরক্ষিত ডেটা পড়া যায়নি।',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _loadError!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(_english ? 'Try again' : 'আবার চেষ্টা করুন'),
                ),
                const SizedBox(height: 12),
                Text(
                  _english
                      ? 'Your existing data has not been intentionally replaced.'
                      : 'আপনার আগের ডেটা নতুন খালি ডেটা দিয়ে প্রতিস্থাপন করা হয়নি।',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        data: _data,
        english: _english,
        onGoals: () => setState(() => _selectedIndex = 1),
        onWorship: () => setState(() => _selectedIndex = 2),
        onRights: () => setState(() => _selectedIndex = 3),
        onReflection: () => setState(() => _selectedIndex = 4),
      ),
      GoalsScreen(
        data: _data,
        english: _english,
        onDataChanged: _changeData,
      ),
      WorshipScreen(
        data: _data,
        english: _english,
        onDataChanged: _changeData,
      ),
      RightsScreen(
        data: _data,
        english: _english,
        onDataChanged: _changeData,
      ),
      ReflectionScreen(
        key: const ValueKey('reflection-screen'),
        data: _data,
        english: _english,
        onDataChanged: _changeData,
      ),
      ReportScreen(
        data: _data,
        english: _english,
      ),
    ];

    final titles = _english
        ? [
            'Home',
            'Goals',
            'Worship',
            'Rights',
            'Reflection',
            'Report',
          ]
        : [
            'হোম',
            'লক্ষ্য',
            'ইবাদত',
            'দায়িত্ব',
            'আত্মসমালোচনা',
            'রিপোর্ট',
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: _english ? 'Change language' : 'ভাষা পরিবর্তন',
            onPressed: _toggleLanguage,
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            tooltip: _english ? 'Change theme' : 'থিম পরিবর্তন',
            onPressed: _toggleTheme,
            icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: _english ? 'Home' : 'হোম',
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: _english ? 'Goals' : 'লক্ষ্য',
          ),
          NavigationDestination(
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque),
            label: _english ? 'Worship' : 'ইবাদত',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: _english ? 'Rights' : 'দায়িত্ব',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: _english ? 'Reflect' : 'ভাবনা',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: _english ? 'Report' : 'রিপোর্ট',
          ),
        ],
      ),
    );
  }
}
