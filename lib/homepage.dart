import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj_1/dashboard.dart';
import 'package:proj_1/user_page.dart';

import 'Budgets.dart';
import 'custom_alert_dialog.dart';
import 'database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
        widget = Dashboard();
        break;

      case 1:
        //  Navigator.pushNamed(context, '/userpage');
        break;

      case 2:
        widget = UserPage();
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
              icon: Icon(Icons.shopping_bag),
              label: 'Finances',
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
