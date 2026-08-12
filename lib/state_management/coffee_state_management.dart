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

  // CREATE
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

  // UPDATE
  Future<void> updateCoffeeRecord(
    CoffeeRecordsModel coffeeRecord,
  ) async {
    final querySnapshot = await _firestore
        .collection('coffee_records')
        .where('id', isEqualTo: coffeeRecord.id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    final docId = querySnapshot.docs.first.id;

    await _firestore.collection('coffee_records').doc(docId).update({
      'id': coffeeRecord.id,
      'title': coffeeRecord.title,
      'des': coffeeRecord.des,
      'amount': coffeeRecord.amount,
      'date': Timestamp.fromDate(coffeeRecord.date),
    });
  }

  // DELETE
  Future<void> deleteCoffeeRecord(int id) async {
    final querySnapshot = await _firestore
        .collection('coffee_records')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    final docId = querySnapshot.docs.first.id;

    await _firestore
        .collection('coffee_records')
        .doc(docId)
        .delete();
  }

  // READ - Real-time data
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