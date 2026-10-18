import 'package:flutter/material.dart';
import '../widgets/animated_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final goals = (data['goals'] as List?) ?? [];
    final rights = (data['rights'] as List?) ?? [];
    final completedGoals = goals.where((g) {
      return g is Map && (g['progress'] ?? 0) >= (g['total'] ?? 1);
    }).length;
    final completedRights = rights.where((r) {
      return r is Map && r['done'] == true;
    }).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AnimatedHeader(
          title: english ? 'Pathchola' : 'পথচলা',
          subtitle: english
              ? 'A better day, one good deed at a time.'
              : 'প্রতিদিন একটু ভালো হওয়ার যাত্রা।',
          icon: Icons.nightlight_round,
        ),
        const SizedBox(height: 20),
        Text(
          english ? 'Your journey' : 'আপনার অগ্রগতি',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _statCard(
              context,
              english ? 'Goals' : 'লক্ষ্য',
              '${goals.length}',
              Icons.flag_rounded,
              const Color(0xFF148F77),
            ),
            _statCard(
              context,
              english ? 'Completed' : 'সম্পন্ন লক্ষ্য',
              '$completedGoals',
              Icons.check_circle_rounded,
              const Color(0xFF3F7DE8),
            ),
            _statCard(
              context,
              english ? 'Daily worship' : 'দৈনিক আমল',
              english ? 'Track' : 'হিসাব রাখুন',
              Icons.mosque_rounded,
              const Color(0xFF9864D8),
            ),
            _statCard(
              context,
              english ? 'Rights completed' : 'সম্পন্ন দায়িত্ব',
              '$completedRights',
              Icons.volunteer_activism_rounded,
              const Color(0xFFE29B38),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          english ? 'Quick access' : 'দ্রুত প্রবেশ',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _actionTile(context, Icons.flag, english ? 'Goals' : 'লক্ষ্য',
            english ? 'Plan and track your goals' : 'লক্ষ্য তৈরি ও অগ্রগতি দেখুন',
            onGoals),
        _actionTile(context, Icons.mosque, english ? 'Worship' : 'ইবাদত',
            english ? 'Record daily habits' : 'দৈনিক আমলের হিসাব রাখুন',
            onWorship),
        _actionTile(context, Icons.favorite, english ? 'Rights & duties' : 'হক ও দায়িত্ব',
            english ? 'Keep track of responsibilities' : 'হক ও দায়িত্বের তালিকা',
            onRights),
        _actionTile(context, Icons.menu_book, english ? 'Reflection' : 'আত্মসমালোচনা',
            english ? 'Write your daily reflection' : 'দিনের ভাবনা লিখে রাখুন',
            onReflection),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 27),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: action,
      ),
    );
  }
}
