import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:proj_1/Budgets.dart';
import 'package:intl/intl.dart';
import 'package:proj_1/signin.dart';

import 'add_budget_page.dart';
import 'custom_alert_dialog.dart';
import 'database_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getAllData();
  }

  Future<void> getAllData() async {
    setState(() {
      _loading = true;
    });
    getDefaultValues();
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    budgetsList = service.retrieveBudgets();
    retrievedBudgetList = await service.retrieveBudgets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;

    if (user?.uid.isEmpty == null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => SignIn()));
      });
    } else {
      print("user Id ${user!.uid}");
    }

    return Stack(
      children: [
        Scaffold(
          body: RefreshIndicator(
            onRefresh: () {
              return getAllData();
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
                      Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(25.0, 0, 8.0, 0),
                              child: _imageLoaded
                                  ? CircleAvatar(
                                      radius: 40.0,
                                      foregroundColor:
                                          Color.fromARGB(255, 223, 220, 220),
                                      backgroundImage: NetworkImage(
                                          user!.photoURL.toString()),
                                    )
                                  : const CircleAvatar(
                                      radius: 40.0,
                                      foregroundColor:
                                          Color.fromARGB(255, 223, 220, 220),
                                      backgroundImage:
                                          AssetImage('images/profile.png'),
                                    )),
                          const SizedBox(
                            width: 50.0,
                          ),
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 35, 63, 105),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 1.0),
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
                                                minimumSize: const Size(50, 45),
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
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(35.0),
                                                    ),
                                                  ),
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
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Amount',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'OpenSans',
                                                                            letterSpacing:
                                                                                0.2,
                                                                            fontSize:
                                                                                16.0,
                                                                            fontWeight: FontWeight
                                                                                .w600,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                67,
                                                                                65,
                                                                                65)),
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
                                                                          TextInputType
                                                                              .number,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
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
                        height: 450,
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
                                        primary:
                                            const Color.fromARGB(255, 1, 8, 14),
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
                                padding:
                                    const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  height: 350.0,
                                  child: FutureBuilder(
                                      future: budgetsList,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Budgets>>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            retrievedBudgetList?.isEmpty ==
                                                null) {
                                          Center(
                                            child: Text('No Items'),
                                          );
                                        }
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return ListView.separated(
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return const SizedBox(height: 15);
                                            },
                                            primary: false,
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                retrievedBudgetList?.length ??
                                                    0,
                                            itemBuilder: _itemBuilder,
                                          );
                                        } else {
                                          return Center(
                                            child: SpinKitSquareCircle(
                                              color: Colors.blue[500],
                                              size: 60.0,
                                            ),
                                          );
                                        }
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
        ),
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
    String startDay = retrievedBudgetList![index].startDate.substring(0, 2);
    String startMonth = retrievedBudgetList![index].startDate.substring(3, 5);
    String startYear = retrievedBudgetList![index].startDate.substring(6, 10);
    DateTime start = DateTime.parse('$startYear-$startMonth-$startDay');

    String endDay = retrievedBudgetList![index].endDate.substring(0, 2);
    String endMonth = retrievedBudgetList![index].endDate.substring(3, 5);
    String endYear = retrievedBudgetList![index].endDate.substring(6, 10);
    DateTime end = DateTime.parse('$endYear-$endMonth-$endDay');

    int daysFromToday = service.daysBetween(end, DateTime.now());
    double amountSpent = 0.0;
    if (daysFromToday.isNegative) {
      amountSpent = 0;
    } else {
      double amountSpent =
          double.parse(retrievedBudgetList![index].dailyLimit) * daysFromToday;
    }

    budgetAmt = NumberFormat.currency(locale: "en_NG", symbol: "₦")
        .format(double.parse(retrievedBudgetList![index].budgetAmount));
    dailyAmt = NumberFormat.currency(locale: "en_NG", symbol: "₦")
        .format(double.parse(retrievedBudgetList![index].dailyLimit));
    weeklyAmt = NumberFormat.currency(locale: "en_NG", symbol: "₦")
        .format(double.parse(retrievedBudgetList![index].weeklyLimit));
    amtSpent =
        NumberFormat.currency(locale: "en_NG", symbol: "₦").format(amountSpent);
    percent =
        amountSpent / double.parse(retrievedBudgetList![index].budgetAmount);

    return SizedBox(
      width: 350,
      child: Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  enableDrag: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35.0),
                    ),
                  ),
                  builder: (BuildContext context) =>
                      StatefulBuilder(builder: (context, setModalState) {
                        return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 40.0,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          primary:
                                              Color.fromARGB(255, 35, 63, 105),
                                          minimumSize:
                                              const Size.fromHeight(60),
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddBudget()));
                                      },
                                      child: Text('Edit Budget')),
                                  SizedBox(
                                    height: 50.0,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        primary: Colors.red[900],
                                        minimumSize: const Size.fromHeight(60),
                                        textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () {
                                        _deleteBudgetDialogBuilder(
                                            context,
                                            retrievedBudgetList![index]
                                                .budgetName,
                                            setModalState);
                                      },
                                      child: Text('Delete Budget')),
                                  SizedBox(
                                    height: 70.0,
                                  )
                                ],
                              ),
                            ));
                      }));
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
                                    retrievedBudgetList![index].budgetName,
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
                                  child: Text('${dailyAmt} per day',
                                      style: const TextStyle(
                                          letterSpacing: 0.5,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70)),
                                )
                              ],
                            ),
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
                      '${amountSpent} Spent from ${budgetAmt}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      'Start Date : ${DateFormat.yMMMMd().format(start)}',
                      style: const TextStyle(
                          letterSpacing: 0.5,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'End Date : ${DateFormat.yMMMMd().format(end)}',
                      style: const TextStyle(
                          letterSpacing: 0.5,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
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

    if (user.photoURL?.isEmpty == null) {
      setState(() => _imageLoaded = false);
    } else {
      img = Image.network(user.photoURL.toString());

      img.image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (mounted) {
          setState(() => _imageLoaded = true);
        }
      }));
    }

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

  Future<void> deleteBudget(String budgetName) async {
    /* final User? user = auth.currentUser;

    await FirebaseFirestore.instance
        .collection("expenses")
        .doc("budgets")
        .collection(user!.email.toString())
        .where('lowerCaseBudgetName', isEqualTo: budgetName.toLowerCase())
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              doc.reference.delete().then((value) {});
            }));
            */
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

  Future<void> _deleteBudgetDialogBuilder(
      BuildContext context, String budgetName, setModalState) {
    print(budgetName);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
          return Dialog(
            elevation: 0,
            backgroundColor: Color(0xffffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(50.0, 20, 50.0, 20),
                  child: Center(
                    child: const Text(
                      'Are you sure you want to Delete this budget ? ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 60.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            primary: Color.fromARGB(255, 183, 181, 181),
                            minimumSize: const Size(100, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('No', style: TextStyle(fontSize: 17.0))),
                    SizedBox(
                      width: 20.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            primary: Colors.red[900],
                            minimumSize: const Size(100, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: !_loading
                            ? () {
                                setState(() {
                                  _loading = true;
                                });

                                setModalState(() {
                                  _loading = true;
                                });

                                deleteBudget(budgetName);
                              }
                            : null,
                        child: Text(
                          'Yes',
                          style: TextStyle(fontSize: 17.0),
                        )),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                )
              ],
            ),
          );
        });
  }
}
