import 'package:cloud_firestore/cloud_firestore.dart';

class Laborer {
  const Laborer({required this.id, required this.name});

  factory Laborer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Laborer(id: doc.id, name: data['name'] as String? ?? '');
  }

  final String id;
  final String name;
}
