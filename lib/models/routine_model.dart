import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final bool done;

  Product({required this.name, required this.done});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(name: map['name'] ?? '', done: map['done'] ?? false);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'done': done};
  }
}

class RoutineModel {
  final String routineId;
  final String userId;
  final String title;
  final String time;
  final List<Product> products;
  final DateTime? lastResetDate;

  RoutineModel({
    required this.routineId,
    required this.userId,
    required this.title,
    required this.time,
    required this.products,
    this.lastResetDate,
  });

  factory RoutineModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RoutineModel(
      routineId: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      products: (data['products'] as List<dynamic>?)
              ?.map((p) => Product.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      lastResetDate: data['lastResetDate'] != null
          ? (data['lastResetDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'time': time,
      'products': products.map((p) => p.toMap()).toList(),
      'lastResetDate': lastResetDate != null
          ? Timestamp.fromDate(lastResetDate!)
          : Timestamp.now(),
    };
  }
}
