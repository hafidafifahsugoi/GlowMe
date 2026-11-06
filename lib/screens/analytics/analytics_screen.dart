import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../providers/skin_log_provider.dart';
import '../../models/skin_log_model.dart';
import 'log_detail_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('id_ID', null);
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing locale: $e');
      if (mounted) {
        setState(() {
          _localeInitialized = true; // Continue anyway
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final skinLogProvider = Provider.of<SkinLogProvider>(context);
    final logs = skinLogProvider.logs;

    return Scaffold(
      appBar: AppBar(title: const Text('Analitik Kulit')),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada data'),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai catat kondisi kulit untuk melihat analitik',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grafik Progress
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
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
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rata-rata: ${_calculateAverageScore(logs).toStringAsFixed(1)}/10',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 2,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= logs.length) {
                                          return const Text('');
                                        }
                                        // Reverse index karena grafik sudah direverse
                                        final reversedIndex =
                                            logs.length - 1 - value.toInt();
                                        final log = logs[reversedIndex];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            DateFormat('dd/MM')
                                                .format(log.date),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 2,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    left: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                minX: 0,
                                maxX: (logs.length - 1).toDouble(),
                                minY: 0,
                                maxY: 10,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getChartData(logs),
                                    isCurved: true,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withAlpha(26),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Grafik menunjukkan tingkat kenyamanan kulit (1-10)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event_note,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Total Catatan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${logs.length} catatan',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Flexible(
                                      child: Text(
                                        'Kondisi Kulit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      _getTrendIcon(logs),
                                      color: _getTrendColor(logs),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _getTrendText(logs),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _getTrendColor(logs),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Penjelasan Konsistensi
                  const SizedBox(height: 20),

                  // Riwayat Catatan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Catatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${logs.length} catatan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List Catatan
                  ...logs.map((log) => _LogCard(log: log)),
                ],
              ),
            ),
    );
  }

  double _calculateAverageScore(List logs) {
    if (logs.isEmpty) return 0;
    final sum = logs.fold<int>(0, (sum, log) => sum + (log.acneLevel as int));
    return (sum / logs.length);
  }

  String _getTrendText(List logs) {
    if (logs.length < 2) return 'Belum cukup data';

    // Ambil 3 catatan terakhir vs 3 sebelumnya (atau sebanyak yang ada)
    final recentCount = logs.length >= 3 ? 3 : logs.length;
    final recentLogs = logs.take(recentCount).toList();
    final recentAvg =
        recentLogs.fold<int>(0, (sum, log) => sum + (log.acneLevel as int)) /
            recentCount;

    if (logs.length < 4) {
      // Jika kurang dari 4 catatan, bandingkan dengan catatan pertama
      final firstScore = logs.last.acneLevel;
      final diff = recentAvg - firstScore;

      if (diff > 1) return 'Membaik';
      if (diff < -1) return 'Menurun';
      return 'Stabil';
    }

    // Bandingkan dengan 3 catatan sebelumnya
    final previousLogs = logs.skip(recentCount).take(recentCount).toList();
    final previousAvg =
        previousLogs.fold<int>(0, (sum, log) => sum + (log.acneLevel as int)) /
            previousLogs.length;

    final diff = recentAvg - previousAvg;

    if (diff > 0.5) return 'Membaik';
    if (diff < -0.5) return 'Menurun';
    return 'Stabil';
  }

  Color _getTrendColor(List logs) {
    final trend = _getTrendText(logs);
    if (trend == 'Membaik') return Colors.green;
    if (trend == 'Menurun') return Colors.red;
    return Colors.orange;
  }

  IconData _getTrendIcon(List logs) {
    final trend = _getTrendText(logs);
    if (trend == 'Membaik') return Icons.trending_up;
    if (trend == 'Menurun') return Icons.trending_down;
    return Icons.trending_flat;
  }

  List<FlSpot> _getChartData(List logs) {
    if (logs.isEmpty) return [];
    // Reverse agar grafik kiri = lama, kanan = baru
    final reversedLogs = logs.reversed.toList();
    return reversedLogs
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.acneLevel.toDouble()))
        .toList();
  }
}

class _LogCard extends StatelessWidget {
  final SkinLogModel log;

  const _LogCard({required this.log});

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
      // Fallback jika locale gagal
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogDetailScreen(log: log),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(log.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Catatan'),
                              content: const Text(
                                'Yakin ingin menghapus catatan ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Provider.of<SkinLogProvider>(
                                      context,
                                      listen: false,
                                    ).deleteLog(log.logId);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Catatan berhasil dihapus'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: log.conditions.map((cond) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(cond).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getConditionText(cond),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getConditionColor(cond),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tingkat Kenyamanan: ${log.acneLevel}/10',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              if (log.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.notes,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (log.photoUrl != null && log.photoUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ada foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
