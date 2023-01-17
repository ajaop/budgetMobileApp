import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:proj_1/add_budget_page.dart';
import 'package:intl/intl.dart';
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
  late TabController tabController;
  late double percent;
  bool _loading = false;
  ScrollController? _controller;
  var userEmail;
  String totalAmt = '₦ 0.0';
  String budgetAmt = '₦ 0.0';
  String dailyAmt = '₦ 0.0';
  String weeklyAmt = '₦ 0.0';
  String amtSpent = '₦ 0.0';
  int _index = 0;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseService service = DatabaseService();
  Future<List<Budgets>>? budgetsList;
  List<Budgets>? retrievedBudgetList;
  bool _imageLoaded = false;
  var img = null;
  var placeholder = AssetImage('images/profile.png');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;

    print('user pictures ${user!.photoURL.toString()}');

    if (user.uid.isNotEmpty) {
      print("user Id ${user.uid}");
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
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
