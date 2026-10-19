
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool english;
  final VoidCallback onGoals;
  final VoidCallback onWorship;
  final VoidCallback onRights;
  final VoidCallback onReflection;

  const HomeScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onGoals,
    required this.onWorship,
    required this.onRights,
    required this.onReflection,
  });

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int _countCompleted(dynamic value) {
    if (value is List) {
      return value.where(_isCompleted).length;
    }

    if (value is Map) {
      return value.values.where(_isCompleted).length;
    }

    return 0;
  }

  bool _isCompleted(dynamic item) {
    if (item is bool) return item;

    if (item is Map) {
      return item['completed'] == true ||
          item['done'] == true ||
          item['isDone'] == true;
    }

    return false;
  }

  int get _worshipCompleted {
    final habits = Map<String, dynamic>.from(data['habits'] ?? {});
    final today = Map<String, dynamic>.from(habits[_todayKey] ?? {});

    return List.generate(7, (index) => today['$index'] == true)
        .where((done) => done)
        .length;
  }

  Map<String, dynamic> get _amalTracker {
    final raw = data['amalTracker'];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  int get _stage {
    final value = _amalTracker['stage'];
    if (value is int && [3, 7, 10, 40].contains(value)) {
      return value;
    }
    return 3;
  }

  int get _stageProgress {
    final value = _amalTracker['progress'];
    final progress = value is num ? value.toInt() : 0;
    return progress.clamp(0, _stage).toInt();
  }

  String get _stageName {
    switch (_stage) {
      case 7:
        return english ? 'Path of the Muttaqin' : 'মুত্তাকীনের পথে';
      case 10:
        return english ? 'Path of the Muhsin' : 'মুহসিনের পথে';
      case 40:
        return english ? 'Path of the Siddiqin' : 'সিদ্দিকীনের পথে';
      default:
        return english ? 'Path of the Saliheen' : 'সালেহীনের পথে';
    }
  }

  String get _nextStageName {
    switch (_stage) {
      case 3:
        return english ? 'Saliheen' : 'সালেহীনের পথে';
      case 7:
        return english ? 'Muttaqin' : 'মুত্তাকীনের পথে';
      case 10:
        return english ? 'Muhsin' : 'মুহসিনীনের পথে';
      default:
        return english ? 'Siddiqin' : 'সিদ্দিকীনের পথে';
    }
  }

  int get _amalTodayCompleted {
    final tracker = _amalTracker;
    final logsRaw = tracker['logs'];

    if (logsRaw is! Map) return 0;

    final logRaw = logsRaw[_todayKey];
    if (logRaw is! Map) return 0;

    final checksRaw = logRaw['checks'];
    if (checksRaw is! Map) return 0;

    return checksRaw.values.where((value) => value == true).length;
  }

  int get _amalTodayTotal {
    final tracker = _amalTracker;
    final logsRaw = tracker['logs'];

    if (logsRaw is! Map) return 0;

    final logRaw = logsRaw[_todayKey];
    if (logRaw is! Map) return 0;

    final requiredRaw = logRaw['requiredIds'];
    if (requiredRaw is! List) return 0;

    return requiredRaw.length;
  }

  @override
  Widget build(BuildContext context) {
    final goals = data['goals'];
    final rights = data['rights'] ?? data['duties'];

    final totalGoals = goals is List
        ? goals.length
        : goals is Map
            ? goals.length
            : 0;

    final completedGoals = _countCompleted(goals);
    final completedRights = _countCompleted(rights);

    final progress = _stageProgress / _stage;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                english ? 'Assalamu Alaikum' : 'আসসালামু আলাইকুম',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Icon(
              Icons.waving_hand_rounded,
              color: Color(0xFFC9A45C),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          english
              ? 'Make today a step towards becoming better.'
              : 'আজকের দিনটিকে আরও ভালো হওয়ার একটি ধাপ বানান।',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.38,
          children: [
            _statCard(
              context,
              title: english ? 'Goals' : 'লক্ষ্য',
              value: '$completedGoals/$totalGoals',
              icon: Icons.flag_rounded,
              color: const Color(0xFF2E8B72),
              onTap: onGoals,
            ),
            _statCard(
              context,
              title: english ? 'Amal today' : 'আজকের আমল',
              value: '$_amalTodayCompleted/$_amalTodayTotal',
              icon: Icons.mosque_rounded,
              color: const Color(0xFF8A4DB8),
              onTap: onWorship,
            ),
            _statCard(
              context,
              title: english ? 'Goals completed' : 'সম্পন্ন লক্ষ্য',
              value: '$completedGoals',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF277DA1),
              onTap: onGoals,
            ),
            _statCard(
              context,
              title: english ? 'Responsibilities' : 'দায়িত্ব',
              value: '$completedRights',
              icon: Icons.favorite_rounded,
              color: const Color(0xFFCB6880),
              onTap: onRights,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Current Amal stage
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onWorship,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Color(0xFFC9A45C),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              english ? 'Your Amal journey' : 'তোমার আমলের যাত্রা',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _stageName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          _stage == 40
                              ? (english
                                  ? 'Consecutive days in this stage'
                                  : 'এই স্তরে ধারাবাহিক দিন')
                              : (english
                                  ? 'Progress to next stage'
                                  : 'পরবর্তী স্তরের অগ্রগতি'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '$_stageProgress/$_stage',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _stage == 40
                        ? (english
                            ? 'Keep going with sincerity and consistency.'
                            : 'আন্তরিকতা ও ধারাবাহিকতার সঙ্গে আমল চালিয়ে যাও।')
                        : (english
                            ? 'Next: $_nextStageName'
                            : 'পরবর্তী স্তর: $_nextStageName'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: onWorship,
                      icon: const Icon(Icons.checklist_rounded),
                      label: Text(
                        english ? 'Open Amal' : 'আমল লিখুন',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Today's Amal checklist progress
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onWorship,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.today_rounded,
                        color: Color(0xFFC9A45C),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          english ? 'Today’s Amal' : 'আজকের আমল',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '$_amalTodayCompleted/$_amalTodayTotal',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: _amalTodayTotal == 0
                          ? 0
                          : (_amalTodayCompleted / _amalTodayTotal)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                      minHeight: 9,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    english
                        ? 'Tap to open your Amal checklist.'
                        : 'আজকের আমলের তালিকা খুলতে এখানে চাপ দাও।',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1FC9A45C),
              child: Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFC9A45C),
              ),
            ),
            title: Text(
              english ? 'Daily reflection' : 'দৈনিক আত্মসমালোচনা',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              english
                  ? 'Review your day and plan to improve.'
                  : 'দিনের কাজ পর্যালোচনা করুন, আগামীকাল আরও ভালো করার পরিকল্পনা করুন।',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onReflection,
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFC9A45C),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        english ? 'A little reminder' : 'একটি ছোট স্মরণিকা',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        english
                            ? 'Small, consistent good deeds can help build lasting habits. Focus on sincerity and steady progress.'
                            : 'ছোট ছোট ভালো কাজ নিয়মিত করতে থাকুন। আন্তরিকতা ও ধারাবাহিকতার মাধ্যমে ধীরে ধীরে ভালো অভ্যাস গড়ে তুলুন।',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 27),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
