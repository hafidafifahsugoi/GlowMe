import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import '../services/firestore_service.dart';

class PrayerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<PrayerModel> _firestorePrayers = [];
  StreamSubscription<List<PrayerModel>>? _subscription;

  static final List<PrayerModel> _defaultItems = [
    // 1. AFIRMASI & MANIFESTING (Universal)
    PrayerModel(
      prayerId: 'aff_1',
      title: 'Manifesting Kulit Sehat & Bercahaya',
      category: 'affirmation',
      arabicText: '',
      latinText:
          '"Kulitku semakin sehat, bersih, lembut, dan bercahaya setiap hari."',
      translation:
          'Ucapkan sambil tersenyum di depan cermin saat mengaplikasikan skincare pagi atau malam.',
      guidance:
          'Bayangkan kulitmu menerima setiap nutrisi produk dengan optimal dan memancarkan kilau sehat dari dalam.',
      targetCount: 5,
    ),
    PrayerModel(
      prayerId: 'aff_2',
      title: 'Afirmasi Self-Love & Penerimaan Diri',
      category: 'affirmation',
      arabicText: '',
      latinText:
          '"Aku mencintai, menghargai, dan menerima diriku sepenuhnya di setiap prosesnya."',
      translation:
          'Kecantikan sejati berawal dari pikiran yang damai dan hati yang menerima diri sendiri.',
      guidance:
          'Jangan terlalu keras pada dirimu. Kondisi kulit yang sedang berproses tidak mengurangi nilai dan kecantikan dirimu.',
      targetCount: 5,
    ),
    PrayerModel(
      prayerId: 'aff_3',
      title: 'Manifesting Pemulihan Kulit (Skin Healing)',
      category: 'affirmation',
      arabicText: '',
      latinText:
          '"Tubuh dan kulitku memiliki kemampuan alami yang luar biasa untuk pulih dan beregenerasi."',
      translation:
          'Cocok dibaca saat kulit sedang mengalami kemerahan, iritasi, atau berjerawat.',
      guidance:
          'Tarik napas perlahan, lepaskan rasa cemas terhadap kulitmu, dan percayakan proses pemulihan alami tubuhmu.',
      targetCount: 5,
    ),
    PrayerModel(
      prayerId: 'aff_4',
      title: 'Manifesting Aura Positif & Percaya Diri',
      category: 'affirmation',
      arabicText: '',
      latinText:
          '"Hari ini aku memancarkan energi positif, ketenangan, dan rasa percaya diri."',
      translation:
          'Awali harimu dengan keyakinan bahwa kamu layak merasa nyaman dan bahagia.',
      guidance:
          'Energi positif yang kamu rasakan di dalam diri akan terpancar secara alami melalui ekspresi wajahmu.',
      targetCount: 3,
    ),

    // 2. REFLEKSI & MINDFULNESS (Universal)
    PrayerModel(
      prayerId: 'ref_1',
      title: 'Pernapasan 4-7-8 (Redakan Stres Kulit)',
      category: 'reflection',
      arabicText: '',
      latinText:
          '"Aku menarik napas ketenangan, dan menghembuskan segala ketegangan."',
      translation:
          'Teknik relaksasi untuk menurunkan hormon stres (kortisol) yang sering memicu jerawat dan kulit kusam.',
      guidance:
          '1. Tarik napas perlahan melalui hidung selama 4 detik.\n2. Tahan napas selama 7 detik.\n3. Hembuskan perlahan melalui mulut selama 8 detik.\n4. Ulangi sebanyak 4 kali hingga tubuh terasa rileks.',
      targetCount: 4,
    ),
    PrayerModel(
      prayerId: 'ref_2',
      title: 'Refleksi Rasa Syukur (Gratitude Moment)',
      category: 'reflection',
      arabicText: '',
      latinText:
          '"Terima kasih tubuhku dan kulitku karena telah melindungiku dengan setia setiap hari."',
      translation:
          'Mengubah fokus dari kekurangan kulit menjadi rasa syukur atas kesehatan tubuh.',
      guidance:
          'Sebutkan 3 hal kecil yang kamu syukuri hari ini. Hati yang tenang dan penuh syukur membantu menjaga keseimbangan hormon kulit.',
      targetCount: 3,
    ),
    PrayerModel(
      prayerId: 'ref_3',
      title: 'Mindful Skincare Routine',
      category: 'reflection',
      arabicText: '',
      latinText:
          '"Momen merawat kulit ini adalah waktu istirahat dan bentuk kasih sayang untuk diriku sendiri."',
      translation:
          'Nikmati setiap langkah rutinitas skincare tanpa terburu-buru.',
      guidance:
          'Rasakan suhu air saat mencuci wajah, aroma lembut produk, dan sentuhan jari di kulitmu. Jadikan momen ini sebagai terapi ketenanganmu.',
      targetCount: 3,
    ),
    PrayerModel(
      prayerId: 'ref_4',
      title: 'Refleksi Malam & Melepas Lelah',
      category: 'reflection',
      arabicText: '',
      latinText:
          '"Aku sudah melakukan yang terbaik hari ini. Kini saatnya pikiran, tubuh, dan kulitku beristirahat."',
      translation:
          'Persiapan tidur berkualitas agar proses regenerasi sel kulit malam hari berjalan optimal.',
      guidance:
          'Lepaskan beban pikiran hari ini sebelum tidur. Tidur yang nyenyak adalah skincare alami terbaik untuk kulitmu.',
      targetCount: 3,
    ),

    // 3. DOA & DZIKIR (Islami)
    PrayerModel(
      prayerId: 'pray_1',
      title: 'Doa Ketika Bercermin & Merawat Wajah',
      category: 'prayer',
      arabicText: 'اللَّهُمَّ كَمَا حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
      latinText: 'Allahumma kamaa hassanta khalqii fahassin khuluqii',
      translation:
          'Ya Allah, sebagaimana Engkau telah memperindah rupaku, maka perindahlah pula akhlakku.',
      guidance:
          'Dibaca saat bercermin atau ketika memulai rutinitas perawatan wajah agar kecantikan lahir dan batin senantiasa terjaga.',
      targetCount: 3,
    ),
    PrayerModel(
      prayerId: 'pray_2',
      title: 'Doa Memohon Cahaya (Nur) pada Wajah & Hati',
      category: 'prayer',
      arabicText: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَفِي وَجْهِي نُورًا',
      latinText: 'Allahummaj\'al fii qalbii nuuran wa fii wajhii nuuran',
      translation:
          'Ya Allah, jadikanlah cahaya di dalam hatiku dan cahaya pada wajahku.',
      guidance:
          'Memohon ketenangan batin dan wajah yang berseri-seri penuh keberkahan.',
      targetCount: 3,
    ),
    PrayerModel(
      prayerId: 'pray_3',
      title: 'Doa Memohon Kesehatan & Kesembuhan Kulit',
      category: 'prayer',
      arabicText:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي',
      latinText:
          'Allahumma \'aafinii fii badanii, Allahumma \'aafinii fii sam\'ii, Allahumma \'aafinii fii basharii',
      translation:
          'Ya Allah, berikanlah kesehatan pada tubuhku, pendengaranku, dan penglihatanku.',
      guidance:
          'Dzikir pagi dan petang yang dianjurkan dibaca 3 kali untuk memohon kesehatan tubuh dan kulit.',
      targetCount: 3,
    ),
    PrayerModel(
      prayerId: 'pray_4',
      title: 'Dzikir Ketenangan Hati (Tasbih & Tahmid)',
      category: 'prayer',
      arabicText:
          'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      latinText:
          'Subhanallah walhamdulillah wa laa ilaaha illallah wallahu akbar',
      translation:
          'Maha Suci Allah, segala puji bagi Allah, tiada Tuhan selain Allah, dan Allah Maha Besar.',
      guidance:
          'Menenangkan pikiran dan hati dengan berdzikir, membantu meredakan kecemasan sehari-hari.',
      targetCount: 33,
    ),
  ];

  List<PrayerModel> get prayers => [..._defaultItems, ..._firestorePrayers];

  List<PrayerModel> getByCategory(String category) {
    return prayers.where((item) => item.category == category).toList();
  }

  void loadPrayers() {
    _subscription?.cancel();
    _subscription = _firestoreService.getPrayers().listen((prayers) {
      _firestorePrayers = prayers;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
