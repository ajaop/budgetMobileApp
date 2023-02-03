import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:proj_1/Transactions.dart';
import 'package:proj_1/finances_page.dart';
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
  String totalAmt = '₦ 0.0',
      budgetAmt = '₦ 0.0',
      dailyAmt = '₦ 0.0',
      weeklyAmt = '₦ 0.0',
      amtSpent = '₦ 0.0',
      totalAmountSpentFormatted = '₦ 0.0';
  int _index = 0;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountDescriptionController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseService service = DatabaseService();
  Future<List<Budgets>>? budgetsList;
  List<Budgets>? retrievedBudgetList;
  Future<List<Transactions>>? transactionsCreditList;
  List<Transactions>? retrievedTransactionsCreditList;
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
    transactionsCreditList = service.retrieveTransactionsCredit();
    retrievedTransactionsCreditList =
        await service.retrieveTransactionsCredit();

    retrievedTransactionsCreditList!.sort(
      (a, b) {
        return b.transactionDate.compareTo(a.transactionDate);
      },
    );

    retrievedBudgetList!.sort(
      (a, b) {
        return b.presentDate.compareTo(DateTime.parse(a.startDate));
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountDescriptionController.dispose();
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
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/userpage');
                                      },
                                      child: CircleAvatar(
                                        radius: 40.0,
                                        foregroundColor:
                                            Color.fromARGB(255, 223, 220, 220),
                                        child: CachedNetworkImage(
                                          imageUrl: user!.photoURL.toString(),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: 80.0,
                                            height: 80.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/userpage');
                                      },
                                      child: const CircleAvatar(
                                        radius: 40.0,
                                        foregroundColor:
                                            Color.fromARGB(255, 223, 220, 220),
                                        backgroundImage:
                                            AssetImage('images/profile.png'),
                                      ),
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
                                                                child: ListView(
                                                                    shrinkWrap:
                                                                        true,
                                                                    children: [
                                                                      Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Text(
                                                                              'Amount',
                                                                              style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.2, fontSize: 16.0, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 67, 65, 65)),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10.0,
                                                                          ),
                                                                          Theme(
                                                                            data:
                                                                                Theme.of(context).copyWith(
                                                                              colorScheme: ThemeData().colorScheme.copyWith(primary: Color.fromARGB(255, 44, 79, 106)),
                                                                            ),
                                                                            child:
                                                                                TextFormField(
                                                                              inputFormatters: [
                                                                                CurrencyTextInputFormatter(
                                                                                  locale: 'en_NG',
                                                                                  decimalDigits: 0,
                                                                                  symbol: '₦',
                                                                                ),
                                                                                LengthLimitingTextInputFormatter(21),
                                                                              ],
                                                                              controller: _amountController,
                                                                              decoration: const InputDecoration(
                                                                                border: OutlineInputBorder(),
                                                                                hintText: '12,000.00',
                                                                              ),
                                                                              keyboardType: TextInputType.number,
                                                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                              onFieldSubmitted: (value) {},
                                                                              validator: (value) {
                                                                                if (value!.trim().isEmpty) {
                                                                                  return 'Amount is required';
                                                                                } else if (value.replaceAll('₦', '') == '0') {
                                                                                  return 'Amount can not be 0';
                                                                                }
                                                                              },
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                40.0,
                                                                          ),
                                                                          const Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Text(
                                                                              'Description',
                                                                              style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.2, fontSize: 16.0, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 67, 65, 65)),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10.0,
                                                                          ),
                                                                          Theme(
                                                                            data:
                                                                                Theme.of(context).copyWith(
                                                                              colorScheme: ThemeData().colorScheme.copyWith(primary: Color.fromARGB(255, 44, 79, 106)),
                                                                            ),
                                                                            child:
                                                                                TextFormField(
                                                                              controller: _amountDescriptionController,
                                                                              maxLength: 15,
                                                                              inputFormatters: <TextInputFormatter>[
                                                                                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                                                                                LengthLimitingTextInputFormatter(100),
                                                                              ],
                                                                              decoration: const InputDecoration(
                                                                                border: OutlineInputBorder(),
                                                                                hintText: 'Bonus Amount',
                                                                              ),
                                                                              keyboardType: TextInputType.text,
                                                                              textCapitalization: TextCapitalization.sentences,
                                                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                              onFieldSubmitted: (value) {},
                                                                              validator: (value) {
                                                                                if (value!.trim().isEmpty) {
                                                                                  return 'Description is required';
                                                                                } else if (value.startsWith(RegExp(r'[0-9]'))) {
                                                                                  return 'Description is not valid';
                                                                                }
                                                                              },
                                                                            ),
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
                                                                                  primary: Color.fromARGB(255, 4, 44, 76),
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

                                                                                        String amount = _amountController.text.toString().replaceAll(',', '').replaceAll('₦', '').trim();
                                                                                        String description = _amountDescriptionController.text.toString().trim();

                                                                                        addAmount(double.parse(amount), description, setModalState);
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
                                                                    ]),
                                                              ),
                                                            ));
                                                      }));
                                            },
                                            child: const Text('+ Add Money')),
                                      ),
                                      const SizedBox(
                                        height: 30.0,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            '${DateFormat('yMMMMd').format(DateTime.now())}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                letterSpacing: 0.5,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white)),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
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
                        height: 500,
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
                                        ).then((_) {
                                          setState(() {
                                            getAllData();
                                          });
                                        });
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
                                  height: 400.0,
                                  child: FutureBuilder(
                                      future: budgetsList,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Budgets>>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            retrievedBudgetList?.isEmpty ==
                                                null) {
                                          const Center(
                                            child: Text(
                                              'No Budgets Yet',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 20.0),
                                            ),
                                          );
                                        }
                                        if (retrievedBudgetList?.isEmpty ??
                                            true) {
                                          return const Center(
                                            child: Text(
                                              'No Budgets Yet',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 20.0),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Center(
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return const SizedBox(
                                                    height: 15);
                                              },
                                              primary: false,
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  retrievedBudgetList?.length ??
                                                      0,
                                              itemBuilder: _itemBuilder,
                                            ),
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
                            Column(
                              children: [
                                SizedBox(
                                  height: 5.0,
                                ),
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
                                                    const FinancesPage()),
                                          ).then((_) {
                                            setState(() {
                                              getAllData();
                                            });
                                          });
                                        },
                                        child: const Text('View All'),
                                      ),
                                    )),
                                Container(
                                  height: 350.0,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15.0, 0, 15.0, 0),
                                    child: FutureBuilder(
                                        future: transactionsCreditList,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<Transactions>>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              retrievedTransactionsCreditList
                                                      ?.isEmpty ==
                                                  null) {
                                            const Center(
                                              child: Text(
                                                'No Transactions Yet',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 20.0),
                                              ),
                                            );
                                          }
                                          if (retrievedTransactionsCreditList
                                                  ?.isEmpty ??
                                              true) {
                                            return const Center(
                                              child: Text(
                                                'No Transactions Yet',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 20.0),
                                              ),
                                            );
                                          }
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return ListView.separated(
                                              shrinkWrap: true,
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return const SizedBox(
                                                    height: 15);
                                              },
                                              primary: false,
                                              scrollDirection: Axis.vertical,
                                              itemCount:
                                                  retrievedTransactionsCreditList
                                                          ?.length ??
                                                      0,
                                              itemBuilder:
                                                  _transactionItemBuilder,
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
                                ),
                              ],
                            )
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
    DateTime start = DateTime.parse(retrievedBudgetList![index].startDate);

    DateTime end = DateTime.parse(retrievedBudgetList![index].endDate);

    int daysFromToday = service.daysBetween(DateTime.now(), end);
    int daysFromStart = service.daysBetween(start, DateTime.now()) + 1;
    double amountSpent = 0.0, remainingAmount = 0.0;
    if (daysFromStart.isNegative) {
      amountSpent = 0;
    } else {
      if (daysFromToday == 0) {
        deleteBudget(retrievedBudgetList![index].budgetName, 0, 'completed');
      } else {
        if (daysFromStart > 0) {
          amountSpent = double.parse(retrievedBudgetList![index].dailyLimit) *
              daysFromStart;
        }
      }
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
    if (percent >= 2.0) {
      percent = 1.0;
    }
    remainingAmount =
        (double.parse(retrievedBudgetList![index].budgetAmount)) - amountSpent;

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
                                                        const AddBudget(),
                                                    settings: RouteSettings(
                                                        arguments:
                                                            retrievedBudgetList![
                                                                index])))
                                            .then((_) {
                                          setState(() {
                                            getAllData();
                                          });
                                        });
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
                                        Navigator.pop(context);
                                        _deleteBudgetDialogBuilder(
                                            context,
                                            retrievedBudgetList![index]
                                                .budgetName,
                                            remainingAmount);
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
                      color: Color.fromARGB(255, 35, 63, 105),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15.0))),
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
                      '${amtSpent} Spent from ${budgetAmt}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        letterSpacing: 0.3,
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

  Widget _transactionItemBuilder(BuildContext context, int index) {
    var transactionAmt = NumberFormat.currency(locale: "en_NG", symbol: "₦")
        .format(double.parse(
            retrievedTransactionsCreditList![index].transactionAmount));

    String transactionName =
        retrievedTransactionsCreditList![index].transactionTitle;
    String imageText = '';

    var names = transactionName.split(' ');
    if (names.length >= 2) {
      imageText = (names[0][0] + names[1][0]).toUpperCase();
    } else {
      imageText =
          (names[0][0] + names[0][(transactionName.length - 1)]).toUpperCase();
    }
    String formattedTransacDate = DateFormat.yMMMd()
        .format(retrievedTransactionsCreditList![index].transactionDate);

    String formattedTransacTime = DateFormat.Hm()
        .format(retrievedTransactionsCreditList![index].transactionDate);

    bool isSameDate = true;
    final DateTime presentDate =
        retrievedTransactionsCreditList![index].transactionDate;

    if (service.daysBetween(
            retrievedTransactionsCreditList![index].transactionDate,
            DateTime.now()) ==
        0) {
      formattedTransacDate = 'Today';
    } else if (service.daysBetween(
            retrievedTransactionsCreditList![index].transactionDate,
            DateTime.now()) ==
        1) {
      formattedTransacDate = 'Yesterday';
    }

    if (index == 0) {
      isSameDate = false;
    } else {
      final DateTime prevDate =
          retrievedTransactionsCreditList![index - 1].transactionDate;
      final DateTime presentDate =
          retrievedTransactionsCreditList![index].transactionDate;
      isSameDate = service.isSameDate(presentDate, prevDate);
    }

    if (index == 0 || !(isSameDate)) {
      isSameDate = false;
    }

    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Visibility(
              visible: !isSameDate,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    formattedTransacDate,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0),
                  ),
                ),
              )),
          Container(
            height: 65.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 223, 220, 220),
                ),
                borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 15.0, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    minRadius: 25.0,
                    child: Text(imageText),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              transactionName,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                retrievedTransactionsCreditList![index]
                                    .transactionDescription,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '+  $transactionAmt',
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              formattedTransacTime,
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

    service.checkResetTime();

    setState(() {
      _loading = false;
    });
  }

  Future<void> addAmount(
      double amount, String title, StateSetter setModalState) async {
    final User? user = auth.currentUser;
    String initialAmt = "";
    double amountAdded = amount;
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
                  _amountDescriptionController.clear();
                });

                _dialogBuilder(context, 'SUCCESS', 'Amount Successfully Added');
                getAllData();
              }, onError: (e) {
                _dialogBuilder(context, 'FAILURE', e.toString());
              });
            }));

    await service.addTransaction(title, 'Money Added', false,
        amountAdded.toString(), DateTime.now(), context);

    setState(() {
      _loading = false;
    });

    setModalState(() {
      _loading = false;
    });
  }

  Future<void> deleteBudget(
      String budgetName, double remainingAmt, String reason) async {
    final User? user = auth.currentUser;
    String currentUserAmount = totalAmt.replaceAll(',', '').replaceAll('₦', '');

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

    double remainingUserAmount = remainingAmt + double.parse(currentUserAmount);

    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              doc.reference.update(
                {
                  'amount': remainingUserAmount.toString(),
                },
              ).onError((error, stackTrace) {
                _dialogBuilder(context, 'FAILURE', error.toString());
              }).then((value) {
                if (remainingAmt > 0) {
                  if (budgetName.length > 15) {
                    budgetName = budgetName.substring(0, 7);
                  }
                  service.addTransaction(budgetName, 'Budget Deleted', false,
                      remainingAmt.toString(), DateTime.now(), context);
                }
              });
            }));

    setState(() {
      _loading = false;
    });

    getAllData();

    if (reason == 'completed') {
      _dialogBuilder(
          context, 'SUCCESS', 'Budget $budgetName Completed Successfully');
    } else {
      _dialogBuilder(context, 'SUCCESS', 'Budget Deleted Successfully');
    }
  }

  Future<void> _dialogBuilder(
      BuildContext context, String title, String description) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
          return CustomDialog(title: title, description: description);
        });
  }

  void errorDialog(errorMessage, isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        elevation: 0,
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        )));
  }

  Future<void> _deleteBudgetDialogBuilder(
      BuildContext context, String budgetName, double remainingAmount) {
    print(budgetName);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
          return StatefulBuilder(builder: (context, setDialogState) {
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(50.0, 20, 50.0, 20),
                    child: Center(
                      child: Text(
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
                                  Navigator.pop(context);
                                  setState(() {
                                    _loading = true;
                                  });

                                  deleteBudget(
                                      budgetName, remainingAmount, 'delete');
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
        });
  }
}
