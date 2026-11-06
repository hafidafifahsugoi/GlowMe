import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/routine_model.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Pisahkan rutinitas pagi dan malam
    final morningRoutines = routineProvider.routines
        .where((r) =>
            r.title.toLowerCase().contains('pagi') ||
            r.title.toLowerCase().contains('morning'))
        .toList();

    final nightRoutines = routineProvider.routines
        .where((r) =>
            r.title.toLowerCase().contains('malam') ||
            r.title.toLowerCase().contains('night'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinitas Saya'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny), text: 'Pagi'),
            Tab(icon: Icon(Icons.nightlight), text: 'Malam'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutineList(morningRoutines, 'pagi'),
          _buildRoutineList(nightRoutines, 'malam'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final userId = authProvider.firebaseUser?.uid;
          if (userId != null) {
            _showAddRoutineDialog(
              context,
              userId,
              _tabController.index == 0 ? 'pagi' : 'malam',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan login terlebih dahulu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Rutinitas'),
      ),
    );
  }

  Widget _buildRoutineList(List<RoutineModel> routines, String type) {
    if (routines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pagi' ? Icons.wb_sunny : Icons.nightlight,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text('Belum ada rutinitas $type'),
            const SizedBox(height: 8),
            Text(
              'Tambah rutinitas $type pertamamu',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return _RoutineCard(routine: routine);
      },
    );
  }

  void _showAddRoutineDialog(BuildContext context, String userId, String type) {
    final titleController = TextEditingController(
      text: type == 'pagi' ? 'Rutinitas Pagi' : 'Rutinitas Malam',
    );
    final productControllers = <TextEditingController>[TextEditingController()];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tambah Rutinitas ${type == 'pagi' ? 'Pagi' : 'Malam'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    hintText: 'Rutinitas Pagi',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Produk:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...productControllers.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: 'Produk ${entry.key + 1}',
                        hintText: 'Contoh: Facial Wash',
                        suffixIcon: productControllers.length > 1
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    productControllers.removeAt(entry.key);
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      productControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Produk'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final products = productControllers
                    .where((c) => c.text.isNotEmpty)
                    .map((c) => Product(name: c.text, done: false))
                    .toList();

                if (titleController.text.isNotEmpty && products.isNotEmpty) {
                  final routine = RoutineModel(
                    routineId: '',
                    userId: userId,
                    title: titleController.text,
                    time: '', // Tidak pakai waktu
                    products: products,
                    lastResetDate: DateTime.now(),
                  );

                  Provider.of<RoutineProvider>(
                    context,
                    listen: false,
                  ).addRoutine(routine);
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final RoutineModel routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    final completedCount = routine.products.where((p) => p.done).length;
    final totalCount = routine.products.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        routine.title.toLowerCase().contains('pagi') ||
                                routine.title.toLowerCase().contains('morning')
                            ? Icons.wb_sunny
                            : Icons.nightlight,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routine.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      label: Text('$completedCount/$totalCount'),
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withAlpha(26),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Rutinitas'),
                            content: const Text(
                              'Yakin ingin menghapus rutinitas ini?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Provider.of<RoutineProvider>(
                                    context,
                                    listen: false,
                                  ).deleteRoutine(routine.routineId);
                                  Navigator.pop(context);
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...routine.products.asMap().entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.value.name),
                value: entry.value.done,
                onChanged: (value) {
                  Provider.of<RoutineProvider>(
                    context,
                    listen: false,
                  ).toggleProduct(routine.routineId, entry.key, value ?? false);
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            if (completedCount == totalCount && totalCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Rutinitas selesai! 🎉',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
