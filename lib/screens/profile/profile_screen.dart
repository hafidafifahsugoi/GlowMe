import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _morningNotification = true;
  bool _nightNotification = true;

  // Jam notifikasi (bisa diubah user & tersimpan di SharedPreferences)
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _nightTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final settings = await NotificationService.loadSettings();
    if (mounted) {
      setState(() {
        _morningNotification = settings['morningEnabled'] as bool;
        _morningTime = TimeOfDay(
          hour: settings['morningHour'] as int,
          minute: settings['morningMinute'] as int,
        );
        _nightNotification = settings['nightEnabled'] as bool;
        _nightTime = TimeOfDay(
          hour: settings['nightHour'] as int,
          minute: settings['nightMinute'] as int,
        );
      });
    }
  }

  Future<void> _selectMorningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningTime,
      helpText: 'Pilih Jam Notifikasi Pagi',
    );

    if (picked != null) {
      setState(() {
        _morningTime = picked;
        _morningNotification = true;
      });

      await NotificationService.scheduleMorningRoutine(
        hour: _morningTime.hour,
        minute: _morningTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notifikasi pagi diatur setiap pukul ${_formatTime(_morningTime)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectNightTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _nightTime,
      helpText: 'Pilih Jam Notifikasi Malam',
    );

    if (picked != null) {
      setState(() {
        _nightTime = picked;
        _nightNotification = true;
      });

      await NotificationService.scheduleNightRoutine(
        hour: _nightTime.hour,
        minute: _nightTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notifikasi malam diatur setiap pukul ${_formatTime(_nightTime)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Chip(
              label: Text('Jenis Kulit: ${user?.skinType ?? 'Normal'}'),
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withAlpha(26),
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode Gelap'),
                    subtitle: const Text('Aktifkan tema gelap'),
                    secondary: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifikasi Pagi'),
                    subtitle: Text(
                      _morningNotification
                          ? 'Aktif • Setiap pukul ${_formatTime(_morningTime)}'
                          : 'Nonaktif',
                    ),
                    secondary: const Icon(Icons.wb_sunny),
                    value: _morningNotification,
                    onChanged: (value) async {
                      setState(() {
                        _morningNotification = value;
                      });
                      if (value) {
                        await NotificationService.scheduleMorningRoutine(
                          hour: _morningTime.hour,
                          minute: _morningTime.minute,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Notifikasi pagi diaktifkan (${_formatTime(_morningTime)})',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        await NotificationService.cancelMorningRoutine();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi pagi dinonaktifkan'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text('Ubah Jam Notifikasi Pagi'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_morningTime),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time, size: 20),
                      ],
                    ),
                    onTap: _selectMorningTime,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifikasi Malam'),
                    subtitle: Text(
                      _nightNotification
                          ? 'Aktif • Setiap pukul ${_formatTime(_nightTime)}'
                          : 'Nonaktif',
                    ),
                    secondary: const Icon(Icons.nightlight),
                    value: _nightNotification,
                    onChanged: (value) async {
                      setState(() {
                        _nightNotification = value;
                      });
                      if (value) {
                        await NotificationService.scheduleNightRoutine(
                          hour: _nightTime.hour,
                          minute: _nightTime.minute,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Notifikasi malam diaktifkan (${_formatTime(_nightTime)})',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        await NotificationService.cancelNightRoutine();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi malam dinonaktifkan'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text('Ubah Jam Notifikasi Malam'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_nightTime),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time, size: 20),
                      ],
                    ),
                    onTap: _selectNightTime,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.notifications_active_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Tes Notifikasi Sekarang'),
                    subtitle: const Text(
                      'Pastikan notifikasi muncul di layar HP kamu',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        await NotificationService.showTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notifikasi tes telah dikirim! Cek bar notifikasi di atas layar.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Text('Kirim Tes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Bantuan & Dukungan'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Bantuan & Dukungan'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Butuh bantuan? Hubungi kami:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: const Text('Email'),
                                  subtitle: const Text('support@glowme.app'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Tentang Aplikasi'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              const Icon(Icons.spa, size: 32),
                              const SizedBox(width: 12),
                              const Text('GlowMe'),
                            ],
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Versi 1.0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aplikasi Tracking Skincare Harian',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'GlowMe adalah aplikasi tracking skincare yang membantu kamu merawat kulit dengan lebih konsisten dan teratur.',
                              ),
                              SizedBox(height: 16),
                              Text(
                                '© 2026 GlowMe. All rights reserved.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar'),
                    content: const Text('Yakin ingin keluar dari akun?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
