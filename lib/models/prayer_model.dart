import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerModel {
  final String prayerId;
  final String title;
  final String category; // 'affirmation', 'reflection', 'prayer'
  final String arabicText;
  final String latinText;
  final String translation;
  final String? guidance;
  final int targetCount;
  final String? audioUrl;

  PrayerModel({
    required this.prayerId,
    required this.title,
    this.category = 'prayer',
    required this.arabicText,
    required this.latinText,
    required this.translation,
    this.guidance,
    this.targetCount = 3,
    this.audioUrl,
  });

  factory PrayerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PrayerModel(
      prayerId: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'prayer',
      arabicText: data['arabicText'] ?? '',
      latinText: data['latinText'] ?? '',
      translation: data['translation'] ?? '',
      guidance: data['guidance'],
      targetCount: data['targetCount'] ?? 3,
      audioUrl: data['audioUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'arabicText': arabicText,
      'latinText': latinText,
      'translation': translation,
      'guidance': guidance,
      'targetCount': targetCount,
      'audioUrl': audioUrl,
    };
  }
}
