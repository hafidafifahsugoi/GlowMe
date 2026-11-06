import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/skin_log_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/skin_log_model.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<String> _selectedConditions = [];
  int _acneLevel = 5;
  final _notesController = TextEditingController();
  String? _imagePath;
  bool _isSaving = false;

  void _toggleCondition(String value) {
    setState(() {
      if (_selectedConditions.contains(value)) {
        _selectedConditions.remove(value);
      } else {
        _selectedConditions.add(value);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Tampilkan dialog pilihan
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveLog() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final skinLogProvider =
          Provider.of<SkinLogProvider>(context, listen: false);
      final userId = authProvider.firebaseUser?.uid;

      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      final selectedList = _selectedConditions.isEmpty
          ? <String>['normal']
          : List<String>.from(_selectedConditions);

      final log = SkinLogModel(
        logId: '',
        userId: userId,
        date: DateTime.now(),
        condition: selectedList.join(','),
        conditions: selectedList,
        acneLevel: _acneLevel,
        notes: _notesController.text,
        photoUrl: _imagePath,
      );

      await skinLogProvider.addLog(log);

      // Reload logs after saving
      skinLogProvider.loadLogs(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan kulit berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedConditions.clear();
          _acneLevel = 5;
          _notesController.clear();
          _imagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Kondisi Kulit'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveLog,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Simpan'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Abadikan Kulitmu',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(13),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(77),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _imagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text('Unggah Foto'),
                          const SizedBox(height: 4),
                          const Text(
                            'Lacak perkembangan visual kulitmu',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bagaimana kulitmu hari ini?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kamu bisa memilih lebih dari satu kondisi kulit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ConditionChip(
                  label: '✨ Bercahaya',
                  value: 'glowing',
                  selected: _selectedConditions.contains('glowing'),
                  onSelected: _toggleCondition,
                ),
                _ConditionChip(
                  label: '💧 Lembap',
                  value: 'hydrated',
                  selected: _selectedConditions.contains('hydrated'),
                  onSelected: _toggleCondition,
                ),
                _ConditionChip(
                  label: '🌵 Kering',
                  value: 'dry',
                  selected: _selectedConditions.contains('dry'),
                  onSelected: _toggleCondition,
                ),
                _ConditionChip(
                  label: '🔥 Kemerahan',
                  value: 'redness',
                  selected: _selectedConditions.contains('redness'),
                  onSelected: _toggleCondition,
                ),
                _ConditionChip(
                  label: '🌪️ Berminyak',
                  value: 'oily',
                  selected: _selectedConditions.contains('oily'),
                  onSelected: _toggleCondition,
                ),
                _ConditionChip(
                  label: '⚠️ Berjerawat',
                  value: 'breakout',
                  selected: _selectedConditions.contains('breakout'),
                  onSelected: _toggleCondition,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tingkat kenyamanan kulit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$_acneLevel/10',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Slider(
              value: _acneLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _acneLevel.toString(),
              onChanged: (value) {
                setState(() {
                  _acneLevel = value.toInt();
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Refleksi Diri',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Bagaimana perasaanmu hari ini? Produk apa yang kamu pakai?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '"Kulitmu adalah cerminan kedamaian batinmu. Tarik napas dalam, hembuskan ketegangan."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String) onSelected;

  const _ConditionChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }
}
