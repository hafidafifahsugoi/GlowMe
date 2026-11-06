import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/skin_log_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/notification_service.dart';
import '../routine/routine_screen.dart';
import '../tracker/tracker_screen.dart';
import '../analytics/analytics_screen.dart';
import '../prayer/prayer_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const RoutineScreen(),
    const TrackerScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId != null) {
      Provider.of<RoutineProvider>(context, listen: false).loadRoutines(userId);
      Provider.of<SkinLogProvider>(context, listen: false).loadLogs(userId);
    }
    Provider.of<PrayerProvider>(context, listen: false).loadPrayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Rutinitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Catat',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analitik',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Pagi, Cantik',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selamat datang kembali, ${authProvider.currentUser?.name ?? ""}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) =>
                            const _NotificationSettingsSheet(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status Kulit Hari Ini',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Terlihat bercahaya hari ini! Pertahankan!'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Rutinitas Harian',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoutineCard(
                      icon: Icons.wb_sunny,
                      title: 'Pagi',
                      completed: routineProvider.routines
                          .where((r) =>
                              r.title.toLowerCase().contains('pagi') ||
                              r.title.toLowerCase().contains('morning'))
                          .fold(
                              0,
                              (sum, r) =>
                                  sum + r.products.where((p) => p.done).length),
                      total: routineProvider.routines
                          .where((r) =>
                              r.title.toLowerCase().contains('pagi') ||
                              r.title.toLowerCase().contains('morning'))
                          .fold(0, (sum, r) => sum + r.products.length),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoutineCard(
                      icon: Icons.nightlight,
                      title: 'Malam',
                      completed: routineProvider.routines
                          .where((r) =>
                              r.title.toLowerCase().contains('malam') ||
                              r.title.toLowerCase().contains('night'))
                          .fold(
                              0,
                              (sum, r) =>
                                  sum + r.products.where((p) => p.done).length),
                      total: routineProvider.routines
                          .where((r) =>
                              r.title.toLowerCase().contains('malam') ||
                              r.title.toLowerCase().contains('night'))
                          .fold(0, (sum, r) => sum + r.products.length),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Mindfulness & Spiritual',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrayerScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Afirmasi, Refleksi & Doa',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Manifesting positif, ketenangan pikiran, dan doa harian',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int completed;
  final int total;

  const _RoutineCard({
    required this.icon,
    required this.title,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Icon(icon, color: Theme.of(context).colorScheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$completed/$total Selesai',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends State<_NotificationSettingsSheet> {
  bool _morningEnabled = true;
  bool _nightEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _nightTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService.loadSettings();
    if (mounted) {
      setState(() {
        _morningEnabled = settings['morningEnabled'] as bool;
        _morningTime = TimeOfDay(
          hour: settings['morningHour'] as int,
          minute: settings['morningMinute'] as int,
        );
        _nightEnabled = settings['nightEnabled'] as bool;
        _nightTime = TimeOfDay(
          hour: settings['nightHour'] as int,
          minute: settings['nightMinute'] as int,
        );
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Atur Pengingat Notifikasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.wb_sunny,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Rutinitas Pagi'),
              subtitle: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _morningTime,
                    helpText: 'Pilih Jam Notifikasi Pagi',
                  );
                  if (picked != null) {
                    setState(() {
                      _morningTime = picked;
                      _morningEnabled = true;
                    });
                    await NotificationService.scheduleMorningRoutine(
                      hour: _morningTime.hour,
                      minute: _morningTime.minute,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jam: ${_formatTime(_morningTime)} (Ketuk untuk ubah)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              value: _morningEnabled,
              onChanged: (value) async {
                setState(() => _morningEnabled = value);
                if (value) {
                  await NotificationService.scheduleMorningRoutine(
                    hour: _morningTime.hour,
                    minute: _morningTime.minute,
                  );
                } else {
                  await NotificationService.cancelMorningRoutine();
                }
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.nightlight,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Rutinitas Malam'),
              subtitle: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _nightTime,
                    helpText: 'Pilih Jam Notifikasi Malam',
                  );
                  if (picked != null) {
                    setState(() {
                      _nightTime = picked;
                      _nightEnabled = true;
                    });
                    await NotificationService.scheduleNightRoutine(
                      hour: _nightTime.hour,
                      minute: _nightTime.minute,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jam: ${_formatTime(_nightTime)} (Ketuk untuk ubah)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              value: _nightEnabled,
              onChanged: (value) async {
                setState(() => _nightEnabled = value);
                if (value) {
                  await NotificationService.scheduleNightRoutine(
                    hour: _nightTime.hour,
                    minute: _nightTime.minute,
                  );
                } else {
                  await NotificationService.cancelNightRoutine();
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await NotificationService.showTestNotification();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Notifikasi tes telah dikirim! Cek bar notifikasi HP kamu.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Tes Notifikasi Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
