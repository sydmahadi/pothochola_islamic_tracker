
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/worship_screen.dart';
import 'screens/rights_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/report_screen.dart';
import 'screens/today_amal_screen.dart';
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

  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  Map<String, dynamic> _data = {};

  bool _english = false;
  bool _dark = false;
  bool _loading = true;
  bool _dailyDialogShown = false;
  bool _handlingBack = false;

  String? _loadError;
  int _selectedIndex = 0;

  static const String _themeKey = 'pathchola_theme_dark_v2';

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
      ]);

      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _data = Map<String, dynamic>.from(
          results[0] as Map<String, dynamic>,
        );
        _english = results[1] as bool;
        _dark = prefs.getBool(_themeKey) ?? false;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleDailyPopup();
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

  Future<void> _scheduleDailyPopup() async {
    if (!mounted || _dailyDialogShown || _loadError != null) {
      return;
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted || _dailyDialogShown) return;

    final context = _navigatorKey.currentContext;
    if (context == null) return;

    _dailyDialogShown = true;
    await _showDailyPopup(context);
  }

  Future<void> _showDailyPopup(BuildContext dialogContext) async {
    if (!mounted) return;

    final item = DailyContentService.forToday();

    await showDialog<void>(
      context: dialogContext,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) {
        final isQuran = item.isQuran;

        return AlertDialog(
          icon: Icon(
            isQuran
                ? Icons.menu_book_rounded
                : Icons.auto_stories_rounded,
            size: 38,
            color: const Color(0xFFB69A55),
          ),
          title: Text(
            isQuran
                ? (_english
                    ? 'Verse of the day'
                    : 'আজকের কুরআনের আয়াত')
                : (_english
                    ? 'Hadith of the day'
                    : 'আজকের হাদিস'),
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
                      color: Color(0xFFB69A55),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _english ? item.english : item.bangla,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.reference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF39775A),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(_english ? 'Continue' : 'শুরু করি'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeData(Map<String, dynamic> newData) async {
    final previous = _data;
    final updated = Map<String, dynamic>.from(newData);

    setState(() {
      _data = updated;
    });

    try {
      await _storage.saveData(updated);
    } catch (e, stackTrace) {
      debugPrint('PATHCHOLA SAVE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

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

      rethrow;
    }
  }

  Future<void> _toggleLanguage() async {
    final next = !_english;

    setState(() {
      _english = next;
    });

    try {
      await _storage.saveEnglish(next);
    } catch (e) {
      debugPrint('PATHCHOLA LANGUAGE ERROR: $e');
    }
  }

  Future<void> _toggleTheme() async {
    final next = !_dark;

    setState(() {
      _dark = next;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, next);
    } catch (e) {
      debugPrint('PATHCHOLA THEME ERROR: $e');
    }
  }

  void _openTodayAmal() {
    final navigator = _navigatorKey.currentState;

    if (navigator == null) {
      debugPrint('PATHCHOLA: Navigator is not ready.');
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => TodayAmalScreen(
          data: Map<String, dynamic>.from(_data),
          english: _english,
          onDataChanged: _changeData,
        ),
      ),
    );
  }

  Future<void> _handleBack() async {
    if (_handlingBack || !mounted) return;

    _handlingBack = true;

    try {
      // অন্য tab-এ থাকলে Home-এ ফিরবে।
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        return;
      }

      final dialogContext = _navigatorKey.currentContext;
      if (dialogContext == null || !mounted) return;

      final shouldExit = await showDialog<bool>(
        context: dialogContext,
        useRootNavigator: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              _english ? 'Exit Pathchola?' : 'অ্যাপ বন্ধ করবেন?',
            ),
            content: Text(
              _english
                  ? 'Do you want to close the app?'
                  : 'আপনি কি পথচলা অ্যাপ থেকে বের হতে চান?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: Text(_english ? 'Cancel' : 'না'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(_english ? 'Exit' : 'হ্যাঁ, বন্ধ করুন'),
              ),
            ],
          );
        },
      );

      if (shouldExit == true && mounted) {
        await SystemNavigator.pop();
      }
    } finally {
      _handlingBack = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF39775A),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF39775A),
      secondary: const Color(0xFFB69A55),
      surface: const Color(0xFFFFFEF8),
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF39775A),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF78B89A),
      secondary: const Color(0xFFD6BE7D),
      surface: const Color(0xFF20352B),
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'পথচলা',
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F6EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F6EF),
          foregroundColor: Color(0xFF254B39),
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFEF8),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFFE4E7D9),
              width: 0.7,
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFFFFEF8),
          indicatorColor: Color(0xFFDDEBDD),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF14221B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14221B),
          foregroundColor: Color(0xFFE5EBDD),
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF20352B),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF20352B),
          indicatorColor: Color(0xFF365642),
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
              Text(
                _english
                    ? 'Loading Pathchola...'
                    : 'পথচলা চালু হচ্ছে...',
              ),
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
                      ? 'Saved data could not be loaded.'
                      : 'সংরক্ষিত ডেটা লোড করা যায়নি।',
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
                  label: Text(
                    _english ? 'Try again' : 'আবার চেষ্টা করুন',
                  ),
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
        onTodayAmal: _openTodayAmal,
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
            'Prohori',
            'Rights',
            'Reflection',
            'Report',
          ]
        : [
            'হোম',
            'লক্ষ্য',
            'প্রহরী',
            'দায়িত্ব',
            'আত্মসমালোচনা',
            'রিপোর্ট',
          ];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
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
            setState(() {
              _selectedIndex = index;
            });
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
              label: _english ? 'Prohori' : 'প্রহরী',
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
      ),
    );
  }
}
