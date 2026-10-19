import 'package:flutter/material.dart';
import '../widgets/animated_header.dart';

class WorshipScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool english;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  const WorshipScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onDataChanged,
  });

  @override
  State<WorshipScreen> createState() => _WorshipScreenState();
}

class _WorshipScreenState extends State<WorshipScreen> {
  bool _syncScheduled = false;

  String get _today => _dateKey(DateTime.now());

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime _dateFromKey(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  int _number(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return fallback;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  int _stage(Map<String, dynamic> tracker) {
    final value = _number(tracker['stage'], 3);
    return [3, 7, 10, 40].contains(value) ? value : 3;
  }

  String _stageName(int stage) {
    switch (stage) {
      case 3:
        return widget.english
            ? 'On the Path of the Salihin'
            : 'সালেহীনের পথে';
      case 7:
        return widget.english
            ? 'On the Path of the Muttaqin'
            : 'মুত্তাকীনের পথে';
      case 10:
        return widget.english
            ? 'On the Path of the Muhsinin'
            : 'মুহসিনীনদের পথে';
      default:
        return widget.english
            ? 'On the Path of the Siddiqin'
            : 'সিদ্দিকীনের পথে';
    }
  }

  String _stageDescription(int stage) {
    switch (stage) {
      case 3:
        return widget.english
            ? 'Build your foundation with 3 days of consistent deeds.'
            : '৩ দিনের ধারাবাহিক আমলের মাধ্যমে ভিত্তি গড়ে তুলুন।';
      case 7:
        return widget.english
            ? 'Continue your journey for 7 consecutive days.'
            : '৭ দিনের ধারাবাহিক আমলে নিজেকে এগিয়ে নিন।';
      case 10:
        return widget.english
            ? 'Strengthen your daily worship for 10 days.'
            : '১০ দিনের আমলে ইবাদত ও চরিত্রের অভ্যাস গড়ে তুলুন।';
      default:
        return widget.english
            ? 'Continue the 10-day task list for 40 consecutive days.'
            : '১০ দিনের আমলগুলো ৪০ দিন ধারাবাহিকভাবে পালন করুন।';
    }
  }

  bool get _isFriday => DateTime.now().weekday == DateTime.friday;

  List<Map<String, String>> _tasks(
    int stage, {
    required bool friday,
  }) {
    final tasks = <Map<String, String>>[];

    void add(String id, String bn, String en) {
      tasks.add({'id': id, 'bn': bn, 'en': en});
    }

    if (stage == 3) {
      add(
        'fajr_15',
        'ফজরের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Fajr prayer within 15 minutes of adhan',
      );
      add(
        'dhuhr_15',
        'যোহরের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Dhuhr prayer within 15 minutes of adhan',
      );
      add(
        'asr_15',
        'আসরের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Asr prayer within 15 minutes of adhan',
      );
      add(
        'maghrib_15',
        'মাগরিবের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Maghrib prayer within 15 minutes of adhan',
      );
      add(
        'isha_mosque',
        'ইশার সালাত মসজিদে আদায়',
        'Perform Isha prayer in the mosque',
      );

      if (friday) {
        add(
          'jumuah_first',
          'জুমার সালাত প্রথম কাতারে আদায়',
          'Perform Jumuah prayer in the first row',
        );
      }

      add('no_gheebah', 'গীবত থেকে বিরত থাকা', 'Avoid backbiting');
    } else if (stage == 7) {
      add(
        'dhuhr_15',
        'যোহরের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Dhuhr prayer within 15 minutes of adhan',
      );
      add(
        'asr_15',
        'আসরের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Asr prayer within 15 minutes of adhan',
      );
      add(
        'maghrib_15',
        'মাগরিবের সালাত আজানের ১৫ মিনিটের মধ্যে',
        'Maghrib prayer within 15 minutes of adhan',
      );
      add(
        'fajr_first',
        'ফজরের সালাত জামাতের প্রথম তাকবিরে',
        'Join the first takbir of Fajr congregation',
      );
      add(
        'isha_first',
        'ইশার সালাত জামাতের প্রথম তাকবিরে',
        'Join the first takbir of Isha congregation',
      );

      if (friday) {
        add(
          'jumuah_first',
          'জুমার সালাত প্রথম কাতারে আদায়',
          'Perform Jumuah prayer in the first row',
        );
      }

      add('no_gheebah', 'গীবত থেকে বিরত থাকা', 'Avoid backbiting');
      add('no_lie', 'মিথ্যা থেকে বিরত থাকা', 'Avoid lying');
      add(
        'no_pride',
        'আত্মপ্রশংসা ও অহংকার থেকে বিরত থাকা',
        'Avoid self-praise and arrogance',
      );
      add('control_anger', 'রাগ নিয়ন্ত্রণ করা', 'Control anger');
      add(
        'soft_voice',
        'কথা বলার সময় গলা না চড়ানো',
        'Avoid raising your voice while speaking',
      );
    } else {
      add(
        'five_first',
        'পাঁচ ওয়াক্ত সালাত জামাতের প্রথম তাকবিরে আদায়',
        'Join the first takbir of all five daily congregational prayers',
      );
      add(
        'fajr_dhikr',
        'ফজরের পর সূর্যোদয় পর্যন্ত মসজিদে থেকে যিকির',
        'Remain in the mosque for dhikr after Fajr until sunrise',
      );
      add('yasin', 'সূরা ইয়াসিন তিলাওয়াত', 'Recite Surah Yasin');
      add(
        'duha_four',
        'সূর্যোদয়ের পরে চার রাকাত সালাতুদ দুহা',
        'Perform four rakats of Duha after sunrise',
      );
      add(
        'mulk',
        'ঘুমানোর আগে সূরা মুলক তিলাওয়াত',
        'Recite Surah Al-Mulk before sleeping',
      );
      add(
        'tahajjud_four',
        'কমপক্ষে চার রাকাত তাহাজ্জুদ',
        'Perform at least four rakats of Tahajjud',
      );

      if (friday) {
        add(
          'jumuah_first',
          'জুমার সালাত প্রথম কাতারে আদায়',
          'Perform Jumuah prayer in the first row',
        );
      }

      add('no_gheebah', 'গীবত থেকে বিরত থাকা', 'Avoid backbiting');
      add('no_lie', 'মিথ্যা থেকে বিরত থাকা', 'Avoid lying');
      add(
        'no_pride',
        'আত্মপ্রশংসা ও অহংকার থেকে বিরত থাকা',
        'Avoid self-praise and arrogance',
      );
      add('control_anger', 'রাগ নিয়ন্ত্রণ করা', 'Control anger');
      add(
        'stay_silent',
        'সমালোচনা বা মৌখিক আক্রমণে সংযত থাকা',
        'Stay composed when criticized or verbally attacked',
      );
      add(
        'no_riya',
        'রিয়া ও লোকদেখানো আমল থেকে বিরত থাকা',
        'Avoid showing off in worship',
      );
    }

    return tasks;
  }

  @override
  void initState() {
    super.initState();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant WorshipScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _scheduleSync();
    }
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) _syncPastDays();
    });
  }

  void _syncPastDays() {
    final updated = Map<String, dynamic>.from(widget.data);
    final tracker = _map(updated['amalTracker']);
    final todayDate = DateTime.now();

    if (tracker.isEmpty) {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      tracker['stage'] = 3;
      tracker['progress'] = 0;
      tracker['lastProcessedDate'] = _dateKey(yesterday);
      tracker['logs'] = <String, dynamic>{};
      updated['amalTracker'] = tracker;
      widget.onDataChanged(updated);
      return;
    }

    int stage = _stage(tracker);
    int progress = _number(tracker['progress']).clamp(0, stage).toInt();
    final logs = _map(tracker['logs']);

    DateTime lastProcessed;
    try {
      lastProcessed = _dateFromKey(
        (tracker['lastProcessedDate'] ??
                _dateKey(todayDate.subtract(const Duration(days: 1))))
            .toString(),
      );
    } catch (_) {
      lastProcessed = todayDate.subtract(const Duration(days: 1));
    }

    final yesterday = DateTime(
      todayDate.year,
      todayDate.month,
      todayDate.day,
    ).subtract(const Duration(days: 1));

    bool changed = false;
    var date = lastProcessed.add(const Duration(days: 1));

    while (!date.isAfter(yesterday)) {
      final key = _dateKey(date);
      final log = _map(logs[key]);
      final checks = _map(log['checks']);

      final requiredIds = log['requiredIds'] is List
          ? (log['requiredIds'] as List)
              .map((id) => id.toString())
              .toList()
          : <String>[];

      final complete = requiredIds.isNotEmpty &&
          requiredIds.every((id) => checks[id] == true);

      if (complete) {
        progress++;

        if (stage != 40 && progress >= stage) {
          if (stage == 3) {
            stage = 7;
          } else if (stage == 7) {
            stage = 10;
          } else if (stage == 10) {
            stage = 40;
          }

          progress = 0;
        } else if (stage == 40 && progress > 40) {
          progress = 40;
        }
      } else {
        if (stage == 7) {
          stage = 3;
        } else if (stage == 10) {
          stage = 7;
        } else if (stage == 40) {
          stage = 10;
        }

        progress = 0;
      }

      tracker['lastProcessedDate'] = key;
      changed = true;
      date = date.add(const Duration(days: 1));
    }

    if (changed) {
      tracker['stage'] = stage;
      tracker['progress'] = progress;
      tracker['logs'] = logs;
      updated['amalTracker'] = tracker;
      widget.onDataChanged(updated);
    }
  }

  void _saveCheck(
    String id,
    bool checked,
    List<Map<String, String>> tasks,
  ) {
    final updated = Map<String, dynamic>.from(widget.data);
    final tracker = _map(updated['amalTracker']);
    final logs = _map(tracker['logs']);
    final todayLog = _map(logs[_today]);
    final checks = _map(todayLog['checks']);

    checks[id] = checked;

    todayLog['checks'] = checks;
    todayLog['requiredIds'] =
        tasks.map((task) => task['id']!).toList();

    logs[_today] = todayLog;

    tracker['stage'] = _stage(tracker);
    tracker['progress'] = _number(tracker['progress']);
    tracker['lastProcessedDate'] ??=
        _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    tracker['logs'] = logs;

    updated['amalTracker'] = tracker;
    widget.onDataChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final tracker = _map(widget.data['amalTracker']);
    final stage = _stage(tracker);
    final progress =
        _number(tracker['progress']).clamp(0, stage).toInt();

    final logs = _map(tracker['logs']);
    final todayLog = _map(logs[_today]);
    final checks = _map(todayLog['checks']);
    final tasks = _tasks(stage, friday: _isFriday);

    final done =
        tasks.where((task) => checks[task['id']] == true).length;
    final allDone = tasks.isNotEmpty && done == tasks.length;
    final dayNumber = stage == 40 && progress >= 40 ? 40 : progress + 1;
    final percent = tasks.isEmpty ? 0.0 : done / tasks.length;

    final colorScheme = Theme.of(context).colorScheme;
    final green = colorScheme.primary;
    const gold = Color(0xFFB69A55);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AnimatedHeader(
          title: widget.english ? 'Amal' : 'আমল',
          subtitle: widget.english
              ? 'Build consistency, one day at a time.'
              : 'প্রতিদিনের আমলে ধারাবাহিকতা গড়ে তুলুন।',
          icon: Icons.auto_awesome_rounded,
          colors: const [
            Color(0xFF39775A),
            Color(0xFFB69A55),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(Icons.stars_rounded, size: 52, color: gold),
                const SizedBox(height: 8),
                Text(
                  _stageName(stage),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _stageDescription(stage),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.english
                          ? 'Stage progress'
                          : 'ধাপের অগ্রগতি',
                    ),
                    Text('$progress / $stage'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / stage,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.english
                      ? 'Today: Day $dayNumber of $stage'
                      : 'আজকের লক্ষ্য: $dayNumber / $stage দিন',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.english ? 'Today’s deeds' : 'আজকের আমল',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.english
                      ? '$done of ${tasks.length} deeds completed'
                      : '${tasks.length}টি আমলের মধ্যে $doneটি সম্পন্ন',
                ),
                if (allDone) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.english
                              ? 'All today’s deeds are checked. Keep it up!'
                              : 'আজকের সব আমলে টিক দেওয়া হয়েছে। ধারাবাহিকতা বজায় রাখুন!',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...tasks.map((task) {
          final id = task['id']!;
          final checked = checks[id] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: checked,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                widget.english ? task['en']! : task['bn']!,
              ),
              secondary: Icon(
                checked
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: checked ? green : null,
              ),
              onChanged: (value) =>
                  _saveCheck(id, value ?? false, tasks),
            ),
          );
        }),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.english
                        ? 'A day counts only when every applicable deed is checked. The app evaluates the previous day when you open the app on a later date. Friday prayer tasks appear on Fridays only.'
                        : 'দিনের সব প্রযোজ্য আমলে টিক থাকলেই দিনটি পূর্ণ হবে। পরের দিনে অ্যাপ খুললে আগের দিনের হিসাব যাচাই হবে। জুমার আমল শুধু শুক্রবারে দেখানো হবে।',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
