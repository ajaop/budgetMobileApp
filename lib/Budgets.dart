import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Budgets {
  final String budgetName;
  final String budgetAmount;
  final String dailyLimit;
  final String weeklyLimit;
  final String startDate;
  final String endDate;
  final DateTime presentDate;

  Budgets(
      {required this.budgetName,
      required this.budgetAmount,
      required this.dailyLimit,
      required this.weeklyLimit,
      required this.startDate,
      required this.endDate,
      required this.presentDate});

  Map<String, dynamic> toMap() {
    return {
      'BudgetName': budgetName,
      'BudgetAmount': budgetAmount,
      'DailyLimit': dailyLimit,
      'WeeklyLimit': weeklyLimit,
      'startDate': startDate,
      'endDate': endDate
    };
  }

  Budgets.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : budgetName = doc.data()!["BudgetName"],
        budgetAmount = doc.data()!["BudgetAmount"],
        dailyLimit = doc.data()!["DailyLimit"],
        weeklyLimit = doc.data()!["WeeklyLimit"],
        startDate = doc.data()!["startDate"],
        endDate = doc.data()!["endDate"],
        presentDate = DateTime.now();
}
