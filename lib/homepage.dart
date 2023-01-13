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

import 'custom_alert_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

void createBudget(id, budgetTitle, amtPerDay, amtSpent, totalAmt) {}

class Data {
  /*
  Map fetched_data = {
    "data": [
      {
        "id": 1,
        "title": "Food & Shopping",
        "amtPerDay": "140",
        "amtSpent": "120",
        "totalAmt": "1700"
      },
      {
        "id": 2,
        "title": "Fasion",
        "amtPerDay": "200",
        "amtSpent": "50",
        "totalAmt": "3000"
      },
      {
        "id": 3,
        "title": "Education",
        "amtPerDay": "10",
        "amtSpent": "50",
        "totalAmt": "17000"
      },
    ]
  };
  */

}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController tabController;
  late double percent;
  bool _loading = false;
  ScrollController? _controller;
  var _data;
  var userEmail;
  String totalAmt = '₦ 0.0';
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getDefaultValues();
    final User? user = auth.currentUser;
    setState(() {
      userEmail = user!.email;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;

    if (user!.uid.isNotEmpty) {
      print("user Id ${user.uid}");
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
    return Stack(
      children: [
        Scaffold(
            body: RefreshIndicator(
              onRefresh: () {
                return getDefaultValues();
              },
              child: SafeArea(
                child: ListView(
                  controller: _controller,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 15.0,
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Dashboard',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 35, 63, 105),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 1.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 35, 63, 105),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        25.0, 15.0, 25.0, 15.0),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 45.0,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(totalAmt,
                                              style: const TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontSize: 27.0,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white)),
                                        ),
                                        const SizedBox(
                                          height: 7.0,
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              'Out of 40,000,000 budget for this month',
                                              style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w200,
                                                  color: Colors.white)),
                                        ),
                                        const SizedBox(
                                          height: 45.0,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.blue,
                                                  minimumSize:
                                                      const Size(50, 45),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      letterSpacing: 0.5,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              onPressed: () {
                                                showModalBottomSheet<void>(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    enableDrag: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setModalState) {
                                                          return Padding(
                                                              padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        25.0),
                                                                child: Form(
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      const Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          'Amount',
                                                                          style: TextStyle(
                                                                              fontFamily: 'OpenSans',
                                                                              letterSpacing: 0.2,
                                                                              fontSize: 16.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Color.fromARGB(255, 67, 65, 65)),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10.0,
                                                                      ),
                                                                      TextFormField(
                                                                        inputFormatters: [
                                                                          CurrencyTextInputFormatter(
                                                                            locale:
                                                                                'en_NG',
                                                                            decimalDigits:
                                                                                0,
                                                                            symbol:
                                                                                '₦',
                                                                          ),
                                                                          LengthLimitingTextInputFormatter(
                                                                              21),
                                                                        ],
                                                                        controller:
                                                                            _amountController,
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          hintText:
                                                                              '12,000.00',
                                                                        ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        onFieldSubmitted:
                                                                            (value) {},
                                                                        validator:
                                                                            (value) {
                                                                          if (value!
                                                                              .trim()
                                                                              .isEmpty) {
                                                                            return 'Amount is required';
                                                                          }
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            40.0,
                                                                      ),
                                                                      ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              primary: Colors.blue,
                                                                              minimumSize: const Size.fromHeight(60),
                                                                              textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                                                          onPressed: !_loading
                                                                              ? () {
                                                                                  if (_formKey.currentState!.validate()) {
                                                                                    setState(() {
                                                                                      _loading = true;
                                                                                    });
                                                                                    setModalState(() {
                                                                                      _loading = true;
                                                                                    });

                                                                                    String amount = _amountController.text.toString().replaceAll(',', '').replaceAll('₦', '');

                                                                                    addAmount(double.parse(amount), setModalState);
                                                                                  }
                                                                                }
                                                                              : null,
                                                                          child: Text('Add Money')),
                                                                      SizedBox(
                                                                        height:
                                                                            30.0,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ));
                                                        }));
                                              },
                                              child: const Text('+ Add Money')),
                                        ),
                                        const SizedBox(
                                          height: 30.0,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                              ],
                            )),
                        SizedBox(
                          width: 350.0,
                          child: TabBar(
                            controller: tabController,
                            tabs: const [
                              Tab(text: 'Expenses'),
                              Tab(
                                text: 'Income',
                              )
                            ],
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: const Color.fromARGB(255, 35, 63, 105)),
                            unselectedLabelColor: Colors.grey[700],
                            labelColor: Colors.white,
                            labelStyle: const TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 500,
                          height: 400,
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        30.0, 0.0, 30.0, 0.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: const Color.fromARGB(
                                              255, 1, 8, 14),
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddBudget()),
                                          );
                                        },
                                        child: const Text('+ Add Budget'),
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 0, 15.0, 0),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    height: 270.0,
                                    child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("expenses")
                                            .doc("budgets")
                                            .collection(user.email.toString())
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            Center(
                                              child: Text('No Items'),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return const Text(
                                                'Something went wrong.');
                                          }

                                          return ListView.separated(
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              _data =
                                                  snapshot.data!.docs[index];
                                              print(_data);
                                              return const SizedBox(height: 15);
                                            },
                                            primary: false,
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: _itemBuilder,
                                          );
                                        }),
                                  ),
                                )
                              ]),
                              const Text("asssss")
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
              currentIndex: 0,
              selectedItemColor: Colors.blue[500],
            )),
        if (_loading)
          Center(
            child: SpinKitSquareCircle(
              color: Colors.blue[500],
              size: 100.0,
            ),
          ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    var item = _data;
    /* percent = ((double.parse(_data.getAmtSpent(index)) * 100) /
            double.parse(_data.getTotalAmt(index))) /
        10;*/
    percent = 0.7;
    print(percent);
    return SizedBox(
      width: 350,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: InkWell(
            onTap: () {
              debugPrint('Card tapped.');
            },
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: const Color.fromARGB(255, 35, 63, 105),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('images/shopping.svg',
                                height: 50, width: 50, fit: BoxFit.scaleDown),
                            const SizedBox(
                              width: 20.0,
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    item['BudgetName'],
                                    style: const TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text('${item['DailyLimit']} per day',
                                      style: const TextStyle(
                                          letterSpacing: 0.5,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70)),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 55.0,
                      lineWidth: 13.0,
                      animation: true,
                      animationDuration: 3000,
                      percent: percent,
                      animateFromLastPercent: true,
                      center: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 40.0,
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.blue,
                      widgetIndicator: const RotatedBox(
                        quarterTurns: 1,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      "Spent ${/*_data.getAmtSpent(index)*/ 100} from ${item['BudgetAmount']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  Future<void> getDefaultValues() async {
    setState(() {
      _loading = true;
    });

    final User? user = auth.currentUser;
    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user!.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              final data = doc.data()['amount'].toString();
              var currencyFormat =
                  NumberFormat.currency(locale: "en_NG", symbol: "₦")
                      .format(double.parse(data));

              setState(() {
                totalAmt = currencyFormat.toString();
              });
            }));

    setState(() {
      _loading = false;
    });
  }

  Future<void> addAmount(double amount, StateSetter setModalState) async {
    final User? user = auth.currentUser;
    String initialAmt = "";
    setState(() {
      userEmail = user!.email;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user!.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              final data = doc.data()['amount'].toString();
              initialAmt = data;
            }));

    amount = amount + double.parse(initialAmt);

    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              doc.reference.update({'amount': amount}).then((value) {
                setModalState(() {
                  _amountController.clear();
                });

                _dialogBuilder(context, 'SUCCESS', 'Amount Successfully Added');
                getDefaultValues();
              }, onError: (e) {
                _dialogBuilder(context, 'FAILURE', e.toString());
              });
            }));

    setState(() {
      _loading = false;
    });

    setModalState(() {
      _loading = false;
    });
  }

  Future<void> _dialogBuilder(
      BuildContext context, String title, String description) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
          return CustomDialog(title: title, description: description);
        });
  }
}
