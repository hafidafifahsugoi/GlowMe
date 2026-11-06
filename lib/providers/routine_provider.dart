import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../services/firestore_service.dart';

class RoutineProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<RoutineModel> _routines = [];

  List<RoutineModel> get routines => _routines;

  void loadRoutines(String userId) {
    _firestoreService.getRoutines(userId).listen((routines) {
      _routines = routines;
      notifyListeners();
    });
  }

  Future<void> addRoutine(RoutineModel routine) async {
    await _firestoreService.createRoutine(routine);
  }

  Future<void> updateRoutine(String routineId, RoutineModel routine) async {
    await _firestoreService.updateRoutine(routineId, routine);
  }

  Future<void> deleteRoutine(String routineId) async {
    await _firestoreService.deleteRoutine(routineId);
  }

  Future<void> toggleProduct(
    String routineId,
    int productIndex,
    bool done,
  ) async {
    final routine = _routines.firstWhere((r) => r.routineId == routineId);
    final updatedProducts = List<Product>.from(routine.products);
    updatedProducts[productIndex] = Product(
      name: updatedProducts[productIndex].name,
      done: done,
    );

    final updatedRoutine = RoutineModel(
      routineId: routine.routineId,
      userId: routine.userId,
      title: routine.title,
      time: routine.time,
      products: updatedProducts,
      lastResetDate: routine.lastResetDate,
    );

    await updateRoutine(routineId, updatedRoutine);
  }
}
