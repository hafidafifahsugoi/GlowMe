import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_provider.dart';
import '../../models/prayer_model.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final affirmations = prayerProvider.getByCategory('affirmation');
    final reflections = prayerProvider.getByCategory('reflection');
    final prayers = prayerProvider.getByCategory('prayer');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mindfulness & Spiritual'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey.shade600,
            tabs: const [
              Tab(
                icon: Icon(Icons.auto_awesome_outlined, size: 18),
                text: 'Afirmasi & Manifesting',
              ),
              Tab(
                icon: Icon(Icons.self_improvement_outlined, size: 18),
                text: 'Refleksi & Mindfulness',
              ),
              Tab(
                icon: Icon(Icons.volunteer_activism_outlined, size: 18),
                text: 'Doa & Dzikir',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoryList(
              items: affirmations,
              headerBanner:
                  'Ucapkan afirmasi positif & manifesting ini dengan penuh keyakinan untuk membangun energi positif dari dalam diri.',
              icon: Icons.auto_awesome,
            ),
            _CategoryList(
              items: reflections,
              headerBanner:
                  'Tenangkan pikiran dan kurangi stres agar tubuh serta kulitmu dapat beristirahat dan beregenerasi secara optimal.',
              icon: Icons.self_improvement,
            ),
            _CategoryList(
              items: prayers,
              headerBanner:
                  'Kumpulan doa dan dzikir harian untuk memohon kesehatan, ketenangan hati, serta keberkahan.',
              icon: Icons.volunteer_activism,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<PrayerModel> items;
  final String headerBanner;
  final IconData icon;

  const _CategoryList({
    required this.items,
    required this.headerBanner,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(60),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  headerBanner,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _PrayerCard(prayer: item, icon: icon)),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerModel prayer;
  final IconData icon;

  const _PrayerCard({required this.prayer, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrayerDetailScreen(prayer: prayer),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      prayer.arabicText.isEmpty
                          ? prayer.latinText
                          : prayer.translation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        fontStyle: prayer.arabicText.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerDetailScreen extends StatefulWidget {
  final PrayerModel prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  int _currentCount = 0;

  String _getCounterLabel(String category) {
    switch (category) {
      case 'affirmation':
        return 'Ucapkan Afirmasi Ini';
      case 'reflection':
        return 'Lakukan Siklus Ini';
      default:
        return 'Hitung Bacaan / Dzikir';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayer;
    final hasArabic = prayer.arabicText.trim().isNotEmpty;
    final isCompleted = _currentCount >= prayer.targetCount;

    return Scaffold(
      appBar: AppBar(title: Text(prayer.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (hasArabic) ...[
                      Text(
                        prayer.arabicText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 2,
                        width: 60,
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(51),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        prayer.latinText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        prayer.translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ] else ...[
                      Icon(
                        prayer.category == 'affirmation'
                            ? Icons.auto_awesome
                            : Icons.self_improvement,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        prayer.latinText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.5,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 2,
                        width: 60,
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(51),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        prayer.translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (prayer.guidance != null && prayer.guidance!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Panduan Praktik',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prayer.guidance!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Interactive Counter Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      _getCounterLabel(prayer.category),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketuk lingkaran di bawah setiap kali selesai mengucapkannya',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentCount++;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (isCompleted
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.primary)
                                  .withAlpha(77),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_currentCount / ${prayer.targetCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCompleted ? 'Selesai ✨' : 'Ketuk',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_currentCount > 0) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentCount = 0;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Ulangi dari 0'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
