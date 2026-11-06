import 'package:cloud_firestore/cloud_firestore.dart';

class SkinLogModel {
  final String logId;
  final String userId;
  final DateTime date;
  final String condition;
  final List<String> conditions;
  final int acneLevel;
  final String notes;
  final String? photoUrl;

  SkinLogModel({
    required this.logId,
    required this.userId,
    required this.date,
    this.condition = 'normal',
    List<String>? conditions,
    required this.acneLevel,
    required this.notes,
    this.photoUrl,
  }) : conditions = (conditions != null && conditions.isNotEmpty)
            ? conditions
            : (condition.isNotEmpty
                ? condition
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : ['normal']);

  factory SkinLogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> parsedConditions = [];
    if (data['conditions'] is List) {
      parsedConditions = (data['conditions'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (data['condition'] is String &&
        (data['condition'] as String).isNotEmpty) {
      parsedConditions = (data['condition'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (parsedConditions.isEmpty) {
      parsedConditions = ['normal'];
    }

    return SkinLogModel(
      logId: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      condition: parsedConditions.join(','),
      conditions: parsedConditions,
      acneLevel: data['acneLevel'] ?? 0,
      notes: data['notes'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'condition': conditions.join(','),
      'conditions': conditions,
      'acneLevel': acneLevel,
      'notes': notes,
      'photoUrl': photoUrl,
    };
  }
}
