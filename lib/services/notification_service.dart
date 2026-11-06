import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _keyMorningEnabled = 'notif_morning_enabled';
  static const String _keyMorningHour = 'notif_morning_hour';
  static const String _keyMorningMinute = 'notif_morning_minute';
  static const String _keyNightEnabled = 'notif_night_enabled';
  static const String _keyNightHour = 'notif_night_hour';
  static const String _keyNightMinute = 'notif_night_minute';

  static Future<void> initialize() async {
    _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await requestPermissions();
    await restoreScheduledNotifications();
  }

  static void _configureLocalTimeZone() {
    try {
      final Duration offset = DateTime.now().timeZoneOffset;
      if (offset.inHours == 7) {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        return;
      } else if (offset.inHours == 8) {
        tz.setLocalLocation(tz.getLocation('Asia/Makassar'));
        return;
      } else if (offset.inHours == 9) {
        tz.setLocalLocation(tz.getLocation('Asia/Jayapura'));
        return;
      }

      // Fallback: cari lokasi dengan offset yang sama
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offset.inMilliseconds) {
          tz.setLocalLocation(loc);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error configuring local timezone: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
        return granted ?? true;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return true;
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'morningEnabled': prefs.getBool(_keyMorningEnabled) ?? true,
      'morningHour': prefs.getInt(_keyMorningHour) ?? 7,
      'morningMinute': prefs.getInt(_keyMorningMinute) ?? 0,
      'nightEnabled': prefs.getBool(_keyNightEnabled) ?? true,
      'nightHour': prefs.getInt(_keyNightHour) ?? 20,
      'nightMinute': prefs.getInt(_keyNightMinute) ?? 0,
    };
  }

  static Future<void> restoreScheduledNotifications() async {
    final settings = await loadSettings();
    if (settings['morningEnabled'] == true) {
      await scheduleMorningRoutine(
        hour: settings['morningHour'] as int,
        minute: settings['morningMinute'] as int,
        savePrefs: false,
      );
    }
    if (settings['nightEnabled'] == true) {
      await scheduleNightRoutine(
        hour: settings['nightHour'] as int,
        minute: settings['nightMinute'] as int,
        savePrefs: false,
      );
    }
  }

  static Future<void> scheduleMorningRoutine({
    int? hour,
    int? minute,
    bool savePrefs = true,
  }) async {
    final scheduleHour = hour ?? 7;
    final scheduleMinute = minute ?? 0;

    if (savePrefs) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMorningEnabled, true);
      await prefs.setInt(_keyMorningHour, scheduleHour);
      await prefs.setInt(_keyMorningMinute, scheduleMinute);
    }

    await requestPermissions();
    final scheduledDate = _nextInstanceOfTime(scheduleHour, scheduleMinute);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'morning_routine_v2',
        'Rutinitas Skincare Pagi',
        channelDescription: 'Pengingat harian rutinitas skincare pagi',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.zonedSchedule(
        0,
        'Rutinitas Skincare Pagi ☀️',
        'Selamat pagi, Cantik! Waktunya merawat kulitmu & ucapkan afirmasi positif hari ini ✨',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _notifications.zonedSchedule(
        0,
        'Rutinitas Skincare Pagi ☀️',
        'Selamat pagi, Cantik! Waktunya merawat kulitmu & ucapkan afirmasi positif hari ini ✨',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> scheduleNightRoutine({
    int? hour,
    int? minute,
    bool savePrefs = true,
  }) async {
    final scheduleHour = hour ?? 20;
    final scheduleMinute = minute ?? 0;

    if (savePrefs) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNightEnabled, true);
      await prefs.setInt(_keyNightHour, scheduleHour);
      await prefs.setInt(_keyNightMinute, scheduleMinute);
    }

    await requestPermissions();
    final scheduledDate = _nextInstanceOfTime(scheduleHour, scheduleMinute);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'night_routine_v2',
        'Rutinitas Skincare Malam',
        channelDescription: 'Pengingat harian rutinitas skincare malam',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.zonedSchedule(
        1,
        'Rutinitas Skincare Malam 🌙',
        'Waktunya bersihkan wajah, pakai skincare malam, dan istirahatkan pikiranmu 🌸',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _notifications.zonedSchedule(
        1,
        'Rutinitas Skincare Malam 🌙',
        'Waktunya bersihkan wajah, pakai skincare malam, dan istirahatkan pikiranmu 🌸',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> cancelMorningRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMorningEnabled, false);
    await _notifications.cancel(0);
  }

  static Future<void> cancelNightRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNightEnabled, false);
    await _notifications.cancel(1);
  }

  static Future<void> showTestNotification() async {
    await requestPermissions();
    await _notifications.show(
      99,
      'Notifikasi GlowMe Aktif! 🌸',
      'Pengingat rutinitas skincare & mindfulness kamu sudah siap berjalan tepat waktu.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Tes Notifikasi GlowMe',
          channelDescription: 'Saluran untuk mengetes notifikasi GlowMe',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showPrayerNotification(String prayer) async {
    await _notifications.show(
      2,
      'Mindfulness & Doa Harian ✨',
      prayer,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer',
          'Mindfulness & Doa Harian',
          channelDescription: 'Notifikasi afirmasi dan doa harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    _configureLocalTimeZone();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
