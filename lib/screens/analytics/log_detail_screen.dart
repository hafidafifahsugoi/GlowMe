import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/skin_log_model.dart';

class LogDetailScreen extends StatelessWidget {
  final SkinLogModel log;

  const LogDetailScreen({super.key, required this.log});

  String _getConditionText(String condition) {
    switch (condition) {
      case 'glowing':
        return '✨ Bercahaya';
      case 'hydrated':
        return '💧 Lembap';
      case 'dry':
        return '🌵 Kering';
      case 'redness':
        return '🔥 Kemerahan';
      case 'oily':
        return '🌪️ Berminyak';
      case 'breakout':
        return '⚠️ Berjerawat';
      default:
        return '😊 Normal';
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'glowing':
        return Colors.amber;
      case 'hydrated':
        return Colors.blue;
      case 'dry':
        return Colors.brown;
      case 'redness':
        return Colors.red;
      case 'oily':
        return Colors.orange;
      case 'breakout':
        return Colors.deepOrange;
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header dengan tanggal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(log.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dicatat pada ${_formatTime(log.date)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Foto wajah (jika ada)
            if (log.photoUrl != null && log.photoUrl!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto Wajah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(log.photoUrl!),
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Foto tidak tersedia',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Kondisi Kulit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kondisi Kulit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: log.conditions.map((cond) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(cond).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getConditionColor(cond).withAlpha(77),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getConditionColor(cond),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getConditionIcon(cond),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getConditionText(cond),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getConditionColor(cond),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tingkat Kenyamanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tingkat Kenyamanan Kulit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  _getComfortColor(log.acneLevel).withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: _getComfortColor(log.acneLevel),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.acneLevel}/10',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _getComfortColor(log.acneLevel),
                                  ),
                                ),
                                Text(
                                  _getComfortLabel(log.acneLevel),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Visual bar
                          SizedBox(
                            width: 40,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                FractionallySizedBox(
                                  heightFactor: log.acneLevel / 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _getComfortColor(log.acneLevel),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Catatan
            if (log.notes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                log.notes,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Info tambahan - DIHAPUS
            const SizedBox(height: 80), // Padding untuk navbar
          ],
        ),
      ),
    );
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'glowing':
        return Icons.auto_awesome;
      case 'hydrated':
        return Icons.water_drop;
      case 'dry':
        return Icons.dry;
      case 'redness':
        return Icons.local_fire_department;
      case 'oily':
        return Icons.oil_barrel;
      case 'breakout':
        return Icons.warning;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color _getComfortColor(int level) {
    if (level >= 8) return Colors.green;
    if (level >= 6) return Colors.lightGreen;
    if (level >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getComfortLabel(int level) {
    if (level >= 8) return 'Sangat Nyaman';
    if (level >= 6) return 'Nyaman';
    if (level >= 4) return 'Cukup Nyaman';
    return 'Kurang Nyaman';
  }
}
