import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_1/Budgets.dart';

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

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    int noOfDays = (to.difference(from).inHours / 24).round() + 1;
    print("no Of Days: ${noOfDays}");
    return noOfDays;
  }
}
