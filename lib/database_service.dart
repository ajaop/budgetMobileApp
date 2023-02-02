import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj_1/Budgets.dart';

import 'Transactions.dart';
import 'custom_alert_dialog.dart';

class DatabaseService {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  DatabaseService() {
    user = auth.currentUser;
  }

  Future<List<Budgets>> retrieveBudgets() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("expenses")
        .doc("budgets")
        .collection(user!.email.toString())
        .get();

    return snapshot.docs
        .map((docSnapshot) => Budgets.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<Transactions>> retrieveTransactionsCredit() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("expenses")
        .doc("transactions")
        .collection(user!.email.toString())
        .where('TransactionType', isEqualTo: 'Credit')
        .get();

    return snapshot.docs
        .map((docSnapshot) => Transactions.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<Transactions>> retrieveTransactionsDebit() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("expenses")
        .doc("transactions")
        .collection(user!.email.toString())
        .where('TransactionType', isEqualTo: 'Debit')
        .get();

    return snapshot.docs
        .map((docSnapshot) => Transactions.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<Transactions>> retrieveAllTransactions() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("expenses")
        .doc("transactions")
        .collection(user!.email.toString())
        .get();

    return snapshot.docs
        .map((docSnapshot) => Transactions.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<void> addTransaction(String title, String description, bool isDebit,
      String amount, DateTime date, context) async {
    String trasactionType = '';

    if (isDebit == true) {
      trasactionType = 'Debit';
    } else {
      trasactionType = 'Credit';
    }

    await FirebaseFirestore.instance
        .collection("expenses")
        .doc("transactions")
        .collection(user!.email.toString())
        .add({
      "User": user!.uid,
      "TransactionDescription": description,
      "TransactionTitle": title,
      "LowerCaseTrasactionTitle": title.toLowerCase(),
      "TransactionType": trasactionType,
      "TransactionAmount": amount,
      "TransactionDate": date,
    }).then((DocumentReference doc) {
      print('Transaction added successfully');
      errorDialog('Transaction Added successfully', false, context);
    }).onError((e, _) {
      print("Error writing document: $e");
      errorDialog(e.toString(), true, context);
    });
  }

  Future<void> checkResetTime() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user!.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              final data = doc.data()['lastResetTime'].toDate();
              if (daysBetween(data, DateTime.now()) >= 1) {
                FirebaseFirestore.instance
                    .collection("users")
                    .where('userId', isEqualTo: user!.uid)
                    .limit(1)
                    .get()
                    .then((value) => value.docs.forEach((doc) {
                          doc.reference.update({
                            'amountReset': 0,
                            'lastResetTime': DateTime.now()
                          });
                        }));
              }
            }));
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    int noOfDays = (to.difference(from).inHours / 24).round();
    print("no Of Days: ${noOfDays}");
    return noOfDays;
  }

  bool isSameDate(DateTime first, DateTime other) {
    return first.year == other.year &&
        first.month == other.month &&
        first.day == other.day;
  }

  void errorDialog(errorMessage, isError, context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        elevation: 0,
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        )));
  }
}
