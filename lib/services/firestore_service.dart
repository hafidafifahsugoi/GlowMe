import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine_model.dart';
import '../models/skin_log_model.dart';
import '../models/prayer_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ROUTINES CRUD
  Future<void> createRoutine(RoutineModel routine) async {
    await _firestore.collection('routines').add(routine.toFirestore());
  }

  Stream<List<RoutineModel>> getRoutines(String userId) {
    return _firestore
        .collection('routines')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RoutineModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateRoutine(String routineId, RoutineModel routine) async {
    await _firestore
        .collection('routines')
        .doc(routineId)
        .update(routine.toFirestore());
  }

  Future<void> deleteRoutine(String routineId) async {
    await _firestore.collection('routines').doc(routineId).delete();
  }

  // SKIN LOGS CRUD
  Future<void> createSkinLog(SkinLogModel log) async {
    await _firestore.collection('skin_logs').add(log.toFirestore());
  }

  Stream<List<SkinLogModel>> getSkinLogs(String userId) {
    return _firestore
        .collection('skin_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SkinLogModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateSkinLog(String logId, SkinLogModel log) async {
    await _firestore
        .collection('skin_logs')
        .doc(logId)
        .update(log.toFirestore());
  }

  Future<void> deleteSkinLog(String logId) async {
    await _firestore.collection('skin_logs').doc(logId).delete();
  }

  // PRAYERS
  Stream<List<PrayerModel>> getPrayers() {
    return _firestore
        .collection('prayers')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrayerModel.fromFirestore(doc))
              .toList(),
        );
  }
}
