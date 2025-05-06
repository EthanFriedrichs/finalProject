import 'package:cloud_firestore/cloud_firestore.dart';

class Records {
  final String name;
  final int votes;
  final String id;

  Records({required this.id, required this.name, required this.votes});

  factory Records.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Records(
      id: snapshot.id,
      name: data['name'] ?? '',
      votes: data['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'votes': votes,
    };
  }

  Records copyWith({String? name, int? votes}) {
    return Records(
      id: id,
      name: name ?? this.name,
      votes: votes ?? this.votes,
    );
  }
}
