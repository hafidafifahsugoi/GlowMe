import 'dart:async';
import 'package:flutter/material.dart';
import '../models/skin_log_model.dart';
import '../services/firestore_service.dart';

class SkinLogProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<SkinLogModel> _logs = [];
  StreamSubscription<List<SkinLogModel>>? _logsSubscription;

  List<SkinLogModel> get logs => _logs;

  void loadLogs(String userId) {
    _logsSubscription?.cancel();
    _logsSubscription = _firestoreService.getSkinLogs(userId).listen((logs) {
      _logs = logs;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addLog(SkinLogModel log) async {
    await _firestoreService.createSkinLog(log);
  }

  Future<void> updateLog(String logId, SkinLogModel log) async {
    await _firestoreService.updateSkinLog(logId, log);
  }

  Future<void> deleteLog(String logId) async {
    await _firestoreService.deleteSkinLog(logId);
  }
}
