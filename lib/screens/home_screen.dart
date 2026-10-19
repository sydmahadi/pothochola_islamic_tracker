
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

  static const List<Map<String, String>> _verses = [
    {
      'arabic': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'bn': 'নিশ্চয়ই কষ্টের সাথেই স্বস্তি রয়েছে।',
      'en': 'Indeed, with hardship comes ease.',
      'ref': 'সূরা আশ-শারহ, ৯৪:৫',
      'refEn': 'Surah Ash-Sharh, 94:5',
    },
    {
      'arabic': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'bn': 'জেনে রাখো, আল্লাহর স্মরণেই অন্তরসমূহ প্রশান্তি লাভ করে।',
      'en': 'Surely, in the remembrance of Allah do hearts find comfort.',
      'ref': 'সূরা আর-রা‘দ, ১৩:২৮',
      'refEn': 'Surah Ar-Ra’d, 13:28',
    },
    {
      'arabic': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      'bn': 'আল্লাহ কাউকে তার সাধ্যের বাইরে দায়িত্ব দেন না।',
      'en': 'Allah does not burden a soul beyond what it can bear.',
      'ref': 'সূরা আল-বাকারা, ২:২৮৬',
      'refEn': 'Surah Al-Baqarah, 2:286',
    },
    {
      'arabic': 'وَقُلْ رَبِّ زِدْنِي عِلْمًا',
      'bn': 'আর বলো, হে আমার রব! আমার জ্ঞান বৃদ্ধি করুন।',
      'en': 'And say, “My Lord, increase me in knowledge.”',
      'ref': 'সূরা ত্ব-হা, ২০:১১৪',
      'refEn': 'Surah Taha, 20:114',
    },
    {
      'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ',
      'bn': 'তোমরা আমাকে স্মরণ করো, আমিও তোমাদের স্মরণ করব।',
      'en': 'So remember Me; I will remember you.',
      'ref': 'সূরা আল-বাকারা, ২:১৫২',
      'refEn': 'Surah Al-Baqarah, 2:152',
    },
  ];

  static const List<Map<String, String>> _hadiths = [
    {
      'ar': 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      'bn': 'নিশ্চয়ই সকল কাজের ফলাফল নিয়তের ওপর নির্ভরশীল।',
      'en': 'Actions are judged by intentions.',
      'ref': 'সহিহ বুখারি, ১',
      'refEn': 'Sahih al-Bukhari, 1',
    },
    {
      'ar': 'مَنْ لَا يَرْحَمُ لَا يُرْحَمُ',
      'bn': 'যে দয়া করে না, তার প্রতিও দয়া করা হয় না।',
      'en': 'Whoever does not show mercy will not be shown mercy.',
      'ref': 'সহিহ বুখারি, ৬০১৩',
      'refEn': 'Sahih al-Bukhari, 6013',
    },
    {
      'ar': 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
      'bn': 'পবিত্রতা ঈমানের অর্ধেক।',
      'en': 'Purification is half of faith.',
      'ref': 'সহিহ মুসলিম, ২২৩',
      'refEn': 'Sahih Muslim, 223',
    },
    {
      'ar': 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      'bn': 'যে আল্লাহ ও আখিরাতে বিশ্বাস করে, সে যেন ভালো কথা বলে অথবা নীরব থাকে।',
      'en': 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
      'ref': 'সহিহ বুখারি, ৬০১৮',
      'refEn': 'Sahih al-Bukhari, 6018',
    },
    {
      'ar': 'يَسِّرُوا وَلَا تُعَسِّرُوا',
      'bn': 'সহজ করো, কঠিন করো না।',
      'en': 'Make things easy and do not make them difficult.',
      'ref': 'সহিহ বুখারি, ৬৯',
      'refEn': 'Sahih al-Bukhari, 69',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final goals = (data['goals'] as List?) ?? [];
    final rights = (data['rights'] as List?) ?? [];

    final completedGoals = goals.where((g) {
      if (g is! Map) return false;
      final progress = (g['progress'] as num?)?.toDouble() ?? 0;
      final total = (g['total'] as num?)?.toDouble() ?? 1;
      return progress >= total;
    }).length;

    final completedRights =
        rights.where((r) => r is Map && r['done'] == true).length;

    // একই দিনে একই আয়াত ও হাদিস থাকবে; দিন বদলালে বদলাবে।
    final today = DateTime.now();
    final dayNumber =
        DateTime(today.year, today.month, today.day)
            .difference(DateTime(2025, 1, 1))
            .inDays
            .abs();

    final verse = _verses[dayNumber % _verses.length];
    final hadith = _hadiths[dayNumber % _hadiths.length];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        AnimatedHeader(
          title: english ? 'Pathchola' : 'পথচলা',
          subtitle: english
              ? 'Grow closer to Allah, one day at a time.'
              : 'প্রতিদিন একটু ভালো হওয়ার যাত্রা।',
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 22),

        // Date greeting
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: colors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      english ? 'Assalamu Alaikum' : 'আসসালামু আলাইকুম',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      english
                          ? 'Make today meaningful with good deeds.'
                          : 'আজকের দিনটি সুন্দর আমলে সাজিয়ে তুলুন।',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionTitle(
          context,
          english ? 'Your progress' : 'আপনার অগ্রগতি',
          Icons.insights_rounded,
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.38,
          children: [
            _statCard(
              context,
              english ? 'Total goals' : 'মোট লক্ষ্য',
              '${goals.length}',
              Icons.flag_rounded,
              const Color(0xFF138568),
            ),
            _statCard(
              context,
              english ? 'Goals completed' : 'সম্পন্ন লক্ষ্য',
              '$completedGoals',
              Icons.task_alt_rounded,
              const Color(0xFF3977D5),
            ),
            _statCard(
              context,
              english ? 'Daily worship' : 'দৈনিক আমল',
              english ? 'Keep going' : 'চালিয়ে যান',
              Icons.mosque_rounded,
              const Color(0xFF8960C9),
            ),
            _statCard(
              context,
              english ? 'Duties completed' : 'সম্পন্ন দায়িত্ব',
              '$completedRights',
              Icons.volunteer_activism_rounded,
              const Color(0xFFCA8A27),
            ),
          ],
        ),
        const SizedBox(height: 26),

        _sectionTitle(
          context,
          english ? 'Verse of the day' : 'আজকের কুরআনের আয়াত',
          Icons.menu_book_rounded,
        ),
        const SizedBox(height: 12),
        _dailyCard(
          context,
          label: english ? 'QURAN · DAILY VERSE' : 'আল-কুরআন · আজকের আয়াত',
          arabic: verse['arabic']!,
          translation: english ? verse['en']! : verse['bn']!,
          reference: english ? verse['refEn']! : verse['ref']!,
          icon: Icons.auto_stories_rounded,
          accent: const Color(0xFF087F5B),
          arabicSize: 25,
        ),
        const SizedBox(height: 22),

        _sectionTitle(
          context,
          english ? 'Hadith of the day' : 'আজকের হাদিস',
          Icons.format_quote_rounded,
        ),
        const SizedBox(height: 12),
        _dailyCard(
          context,
          label: english ? 'HADITH · DAILY WISDOM' : 'হাদিস · আজকের শিক্ষা',
          arabic: hadith['ar']!,
          translation: english ? hadith['en']! : hadith['bn']!,
          reference: english ? hadith['refEn']! : hadith['ref']!,
          icon: Icons.volunteer_activism_rounded,
          accent: const Color(0xFFAD7A28),
          arabicSize: 22,
        ),
        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D6B50), Color(0xFF174C3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFE8C879),
                size: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      english ? 'A little reminder' : 'ছোট্ট একটি স্মরণ',
                      style: const TextStyle(
                        color: Color(0xFFE8C879),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      english
                          ? 'Consistency in good deeds matters, even when they are small.'
                          : 'নিয়মিত ছোট ছোট ভালো কাজও জীবনে বড় পরিবর্তন আনতে পারে।',
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 23),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: value.length > 12 ? 15 : 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _dailyCard(
    BuildContext context, {
    required String label,
    required String arabic,
    required String translation,
    required String reference,
    required IconData icon,
    required Color accent,
    required double arabicSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: arabicSize,
                height: 1.9,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: accent.withValues(alpha: 0.16),
          ),
          const SizedBox(height: 14),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                reference,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
