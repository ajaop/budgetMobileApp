import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj_1/dashboard.dart';
import 'package:proj_1/finances_page.dart';
import 'package:proj_1/user_page.dart';
import 'Budgets.dart';
import 'database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double percent;
  int _index = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseService service = DatabaseService();
  Future<List<Budgets>>? budgetsList;
  List<Budgets>? retrievedBudgetList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();
    switch (_index) {
      case 0:
        widget = const Dashboard();
        break;

      case 1:
        widget = const FinancesPage();
        break;

      case 2:
        widget = const UserPage();
        break;
    }

    return Scaffold(
        body: widget,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'User',
            ),
          ],
          currentIndex: _index,
          onTap: (int index) => setState(() => _index = index),
          selectedItemColor: Colors.blue[500],
        ));
  }
}
