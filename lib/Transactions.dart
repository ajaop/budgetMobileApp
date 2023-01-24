import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Transactions {
  final String transactionTitle;
  final String transactionDescription;
  final String transactionAmount;
  final String transactionType;
  final DateTime transactionDate;

  Transactions({
    required this.transactionTitle,
    required this.transactionDescription,
    required this.transactionAmount,
    required this.transactionType,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'TransactionTitle': transactionTitle,
      'TransactionDescription': transactionDescription,
      'TransactionAmount': transactionAmount,
      'TransactionType': transactionType,
      'TransactionDate': transactionDate
    };
  }

  Transactions.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : transactionTitle = doc.data()!["TransactionTitle"],
        transactionDescription = doc.data()!["TransactionDescription"],
        transactionAmount = doc.data()!["TransactionAmount"],
        transactionType = doc.data()!["TransactionType"],
        transactionDate = doc.data()!["TransactionDate"].toDate();

  void compareTo(Transactions transactions) {}
}
