import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/baby_records.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // var records;
  @override
  Widget build(BuildContext context) {
    CollectionReference jobs = FirebaseFirestore.instance.collection('baby');

    return Scaffold(
      appBar: AppBar(title: Text('Jobs')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        List<Records> records = [];

        for (DocumentSnapshot doc in snapshot.data!.docs) {
          records.add(Records.fromSnapshot(doc));
        }

        return _buildList(records);
      },
    );
  }

  Widget _buildList(List<Records> records) {
    return ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];

          return ListTile(
            title: Text(record.name),
            subtitle: Text('Vote: ${record.votes}'),
            onTap: () async {
              // Create an updated Record object
              Records updatedRecord = record.copyWith(votes: record.votes + 1);

              // Update Firestore using .toJson()
              await FirebaseFirestore.instance.collection('baby').doc(record.id).update(updatedRecord.toJson());
            },
          );
        });
  }
}
