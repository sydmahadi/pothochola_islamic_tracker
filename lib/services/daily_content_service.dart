class DailyContent {
  final String arabic;
  final String bangla;
  final String english;
  final String reference;
  final bool isQuran;

  const DailyContent({
    required this.arabic,
    required this.bangla,
    required this.english,
    required this.reference,
    required this.isQuran,
  });
}

class DailyContentService {
  DailyContentService._();

  static const List<DailyContent> verses = [
    DailyContent(
      arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      bangla: 'নিশ্চয়ই কষ্টের সাথেই স্বস্তি রয়েছে।',
      english: 'Indeed, with hardship comes ease.',
      reference: 'সূরা আশ-শারহ ৯৪:৫',
      isQuran: true,
    ),
    DailyContent(
      arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      bangla: 'জেনে রাখো, আল্লাহর স্মরণেই অন্তরসমূহ প্রশান্তি লাভ করে।',
      english: 'Surely, in the remembrance of Allah do hearts find comfort.',
      reference: 'সূরা আর-রাদ ১৩:২৮',
      isQuran: true,
    ),
    DailyContent(
      arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      bangla: 'আল্লাহ কাউকে তার সাধ্যের বাইরে দায়িত্ব দেন না।',
      english: 'Allah does not burden a soul beyond what it can bear.',
      reference: 'সূরা আল-বাকারা ২:২৮৬',
      isQuran: true,
    ),
    DailyContent(
      arabic: 'وَقُلْ رَبِّ زِدْنِي عِلْمًا',
      bangla: 'আর বলো, হে আমার রব! আমার জ্ঞান বৃদ্ধি করুন।',
      english: 'And say, “My Lord, increase me in knowledge.”',
      reference: 'সূরা ত্ব-হা ২০:১১৪',
      isQuran: true,
    ),
    DailyContent(
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
      bangla: 'তোমরা আমাকে স্মরণ করো, আমিও তোমাদের স্মরণ করব।',
      english: 'So remember Me; I will remember you.',
      reference: 'সূরা আল-বাকারা ২:১৫২',
      isQuran: true,
    ),
  ];

  static const List<DailyContent> hadiths = [
    DailyContent(
      arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      bangla: 'নিশ্চয়ই সকল কাজের ফলাফল নিয়তের ওপর নির্ভরশীল।',
      english: 'Actions are judged by intentions.',
      reference: 'সহিহ আল-বুখারি ১',
      isQuran: false,
    ),
    DailyContent(
      arabic: 'مَنْ لَا يَرْحَمُ لَا يُرْحَمُ',
      bangla: 'যে দয়া করে না, তার প্রতিও দয়া করা হয় না।',
      english: 'Whoever does not show mercy will not be shown mercy.',
      reference: 'সহিহ আল-বুখারি ৬০১৩',
      isQuran: false,
    ),
    DailyContent(
      arabic: 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
      bangla: 'পবিত্রতা ঈমানের অর্ধেক।',
      english: 'Purification is half of faith.',
      reference: 'সহিহ মুসলিম ২২৩',
      isQuran: false,
    ),
    DailyContent(
      arabic:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      bangla:
          'যে আল্লাহ ও আখিরাতে বিশ্বাস করে, সে যেন ভালো কথা বলে অথবা নীরব থাকে।',
      english:
          'Whoever believes in Allah and the Last Day should speak good or remain silent.',
      reference: 'সহিহ আল-বুখারি ৬০১৮',
      isQuran: false,
    ),
    DailyContent(
      arabic: 'يَسِّرُوا وَلَا تُعَسِّرُوا',
      bangla: 'সহজ করো, কঠিন করো না।',
      english: 'Make things easy and do not make them difficult.',
      reference: 'সহিহ আল-বুখারি ৬৯',
      isQuran: false,
    ),
  ];

  /// একই তারিখে একই কনটেন্ট, পরের দিন কুরআন ও হাদিস পালাক্রমে।
  static DailyContent forToday([DateTime? date]) {
    final now = date ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(2025, 1, 1);
    final dayNumber = today.difference(start).inDays.abs();

    final isQuran = dayNumber.isEven;
    final index = (dayNumber ~/ 2) % verses.length;

    return isQuran ? verses[index] : hadiths[index];
  }
}
