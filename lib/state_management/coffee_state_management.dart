import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';

class CoffeeStateManagement with ChangeNotifier {
  List<CoffeeRecordsModel> items = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addData() {
    items.add(
      CoffeeRecordsModel(
        id: DateTime.now().microsecondsSinceEpoch,
        title: "Coffee Record ${items.length + 1}",
        des: "Details about Coffee Record ${items.length + 1}",
        amount: 10.0,
        date: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  Future<void> addCoffeeRecord(
    CoffeeRecordsModel coffeeRecord,
  ) async {
    await _firestore.collection('coffee_records').add({
      'id': coffeeRecord.id,
      'title': coffeeRecord.title,
      'des': coffeeRecord.des,
      'amount': coffeeRecord.amount,
      'date': Timestamp.fromDate(coffeeRecord.date),
    });
  }

  Stream<List<CoffeeRecordsModel>> getCoffeeRecords() {
    return _firestore.collection('coffee_records').snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            final data = doc.data();

            return CoffeeRecordsModel(
              id: data['id'] ?? doc.id.hashCode,
              title: data['title'] ?? 'Coffee',
              des: data['des'] ?? '',
              amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
              date: data['date'] is Timestamp
                  ? (data['date'] as Timestamp).toDate()
                  : DateTime.now(),
            );
          },
        ).toList();
      },
    );
  }
}