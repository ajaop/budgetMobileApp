import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:proj_1/Budgets.dart';
import 'custom_alert_dialog.dart';
import 'database_service.dart';

class AddBudget extends StatefulWidget {
  const AddBudget({Key? key}) : super(key: key);

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final _formKey = GlobalKey<FormState>();
  final _budgetTitleController = TextEditingController();
  final _budgetAmtController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _dailyLimitController = TextEditingController();
  final _weeklyLimitController = TextEditingController();
  late final retrievedBudgetList;

  DatabaseService service = DatabaseService();
  bool _loading = false, isExist = false, isEditing = true;
  String buttonName = 'Create Budget', initialUserAmt = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  var startDate, minimumEndDate, endDate;

  void error(errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[600],
        elevation: 0,
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        )));
  }

  void getEditValuesIfExist() {
    if (ModalRoute.of(context)!.settings.arguments == null) {
      retrievedBudgetList = null;
    } else {
      retrievedBudgetList =
          ModalRoute.of(context)!.settings.arguments as Budgets;
    }

    if (retrievedBudgetList.toString().isEmpty || retrievedBudgetList == null) {
      print('empty');
    } else {
      var budgetAmt = NumberFormat.currency(locale: "en_NG", symbol: "₦")
          .format(double.parse(retrievedBudgetList.budgetAmount));
      var dailyLimitAmt = NumberFormat.currency(locale: "en_NG", symbol: "")
          .format(double.parse(retrievedBudgetList.dailyLimit));
      var weeklyLimitAmt = NumberFormat.currency(locale: "en_NG", symbol: "")
          .format(double.parse(retrievedBudgetList.weeklyLimit));

      startDate = DateTime.parse(retrievedBudgetList.startDate);

      endDate = DateTime.parse(retrievedBudgetList.endDate);
      minimumEndDate = startDate.add(Duration(days: 1));

      var inputFormat = DateFormat('dd/MM/yyyy');

      String startDateText = inputFormat.format(startDate);

      String endDateText = inputFormat.format(endDate);

      _budgetTitleController.text = retrievedBudgetList.budgetName;
      _budgetAmtController.selection =
          TextSelection.collapsed(offset: _budgetAmtController.text.length);

      _budgetAmtController.text = budgetAmt;
      _startDateController.text = startDateText;
      _endDateController.text = endDateText;
      _dailyLimitController.text = dailyLimitAmt;
      _weeklyLimitController.text = weeklyLimitAmt;

      setState(() {
        isEditing = false;
        buttonName = 'Edit Budget';
      });
    }
  }

  @override
  void dispose() {
    _budgetTitleController.dispose();
    _budgetAmtController.dispose();
    _dailyLimitController.dispose();
    _weeklyLimitController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getEditValuesIfExist();
    });
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: const BackButton(color: Color.fromARGB(255, 4, 44, 76)),
            backgroundColor: Colors.white,
            title: Text(
              buttonName,
              style: TextStyle(
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 44, 76)),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
              child: ListView(
            padding: const EdgeInsets.all(25.0),
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Budget Title',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              letterSpacing: 0.6,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: _budgetTitleController,
                        enabled: isEditing,
                        maxLength: 25,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z ]")),
                          LengthLimitingTextInputFormatter(100),
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Food & Drinks',
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Title is required';
                          } else if (value.startsWith(RegExp(r'[0-9]'))) {
                            return 'Title name is not valid';
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Total Budget Amount',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              letterSpacing: 0.6,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: _budgetAmtController,
                        inputFormatters: [
                          CurrencyTextInputFormatter(
                            locale: 'en_NG',
                            decimalDigits: 0,
                            symbol: '₦',
                          ),
                          LengthLimitingTextInputFormatter(21),
                        ],
                        onChanged: (text) {
                          if (_startDateController.text.isNotEmpty &&
                              _endDateController.text.isNotEmpty) {
                            var noOfDays =
                                service.daysBetween(startDate, endDate);
                            if (noOfDays == 0) {
                              calculateDailyWeeklyLimit(1, text);
                              return;
                            }
                            calculateDailyWeeklyLimit(noOfDays, text);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '12,000.00',
                        ),
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Total amount is required';
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Start Date',
                                    style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        letterSpacing: 0.6,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 67, 65, 65)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                TextFormField(
                                  controller: _startDateController,
                                  decoration: const InputDecoration(
                                    suffixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                    hintText: 'DD/MM/YYYY',
                                  ),
                                  keyboardType: TextInputType.datetime,
                                  readOnly: true,
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext builder) {
                                          return Container(
                                              height: MediaQuery.of(context)
                                                      .copyWith()
                                                      .size
                                                      .height /
                                                  3,
                                              child: CupertinoDatePicker(
                                                minimumDate: DateTime.now(),
                                                initialDateTime: DateTime.now(),
                                                onDateTimeChanged:
                                                    (DateTime newdate) {
                                                  var inputFormat =
                                                      DateFormat('dd/MM/yyyy');

                                                  startDate = newdate;
                                                  minimumEndDate = newdate
                                                      .add(Duration(days: 1));
                                                  String startDateText =
                                                      inputFormat
                                                          .format(newdate);

                                                  _startDateController.value =
                                                      TextEditingValue(
                                                    text: startDateText,
                                                    selection: TextSelection
                                                        .fromPosition(
                                                      TextPosition(
                                                          offset: startDateText
                                                              .toString()
                                                              .length),
                                                    ),
                                                  );

                                                  if (_budgetAmtController.text.isNotEmpty &&
                                                      _startDateController
                                                          .text.isNotEmpty &&
                                                      _endDateController
                                                          .text.isNotEmpty) {
                                                    var noOfDays =
                                                        service.daysBetween(
                                                            startDate, endDate);
                                                    if (noOfDays == 0) {
                                                      calculateDailyWeeklyLimit(
                                                          1,
                                                          _budgetAmtController
                                                              .text);
                                                      return;
                                                    }
                                                    calculateDailyWeeklyLimit(
                                                        noOfDays,
                                                        _budgetAmtController
                                                            .text);
                                                  }
                                                },
                                                mode: CupertinoDatePickerMode
                                                    .date,
                                              ));
                                        });
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onFieldSubmitted: (value) {},
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return 'Start date is required';
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'End Date',
                                    style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        letterSpacing: 0.6,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 67, 65, 65)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                TextFormField(
                                  controller: _endDateController,
                                  decoration: const InputDecoration(
                                    suffixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                    hintText: 'DD/MM/YYYY',
                                  ),
                                  keyboardType: TextInputType.datetime,
                                  readOnly: true,
                                  onTap: () {
                                    if (_startDateController.text
                                        .toString()
                                        .isNotEmpty) {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext builder) {
                                            return Container(
                                                height: MediaQuery.of(context)
                                                        .copyWith()
                                                        .size
                                                        .height /
                                                    3,
                                                child: CupertinoDatePicker(
                                                  minimumDate: minimumEndDate,
                                                  initialDateTime:
                                                      minimumEndDate,
                                                  onDateTimeChanged:
                                                      (DateTime newdate) {
                                                    var inputFormat =
                                                        DateFormat(
                                                            'dd/MM/yyyy');
                                                    endDate = newdate;
                                                    String endDateText =
                                                        inputFormat
                                                            .format(newdate);

                                                    _endDateController.value =
                                                        TextEditingValue(
                                                      text: endDateText,
                                                      selection: TextSelection
                                                          .fromPosition(
                                                        TextPosition(
                                                            offset: endDateText
                                                                .toString()
                                                                .length),
                                                      ),
                                                    );

                                                    if (_budgetAmtController.text.isNotEmpty &&
                                                        _startDateController
                                                            .text.isNotEmpty &&
                                                        _endDateController
                                                            .text.isNotEmpty) {
                                                      var noOfDays =
                                                          service.daysBetween(
                                                              startDate,
                                                              endDate);
                                                      if (noOfDays == 0) {
                                                        calculateDailyWeeklyLimit(
                                                            1,
                                                            _budgetAmtController
                                                                .text);
                                                        return;
                                                      }
                                                      calculateDailyWeeklyLimit(
                                                          noOfDays,
                                                          _budgetAmtController
                                                              .text);
                                                    }
                                                  },
                                                  mode: CupertinoDatePickerMode
                                                      .date,
                                                ));
                                          });
                                    } else {
                                      error('Select Start Date');
                                    }
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onFieldSubmitted: (value) {},
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return 'End date is required';
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Daily Limit',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              letterSpacing: 0.6,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: _dailyLimitController,
                        decoration: const InputDecoration(
                          prefixText: "₦",
                          prefixStyle:
                              TextStyle(color: Colors.black, fontSize: 17.0),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Daily limit is required';
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Weekly Limit',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              letterSpacing: 0.6,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: _weeklyLimitController,
                        decoration: const InputDecoration(
                          prefixText: "₦",
                          prefixStyle:
                              TextStyle(color: Colors.black, fontSize: 17.0),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Weekly limit is required';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 60.0,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 4, 44, 76),
                              minimumSize: const Size.fromHeight(50),
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold)),
                          onPressed: !_loading
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    String name =
                                        _budgetTitleController.text.toString();
                                    String amount = _budgetAmtController.text
                                        .toString()
                                        .replaceAll(',', '')
                                        .replaceAll('₦', '');

                                    String dailyAmt = _dailyLimitController.text
                                        .toString()
                                        .replaceAll(',', '')
                                        .replaceAll('₦', '');
                                    String weeklyAmt = _weeklyLimitController
                                        .text
                                        .toString()
                                        .replaceAll(',', '')
                                        .replaceAll('₦', '');
                                    storeValueInDb(
                                        name.trim(),
                                        amount.trim(),
                                        startDate.toString(),
                                        endDate.toString(),
                                        dailyAmt,
                                        weeklyAmt);
                                  }
                                }
                              : null,
                          child: Text(buttonName))
                    ],
                  ))
            ],
          )),
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

  void calculateDailyWeeklyLimit(var noOfDays, var amt) {
    double val = 0;
    double dailyLimit = 0;
    double weeklyLimit = 0;
    if (amt.isNotEmpty) {
      val = double.parse(amt.replaceAll(',', '').replaceAll('₦', ''));
    }

    dailyLimit = val / noOfDays;
    if (noOfDays < 7) {
      weeklyLimit = val / ((noOfDays / 7).ceilToDouble());
    } else {
      weeklyLimit = val / (noOfDays / 7);
    }

    _dailyLimitController.value = TextEditingValue(
      text: dailyLimit.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"),
      selection: TextSelection.fromPosition(
        TextPosition(offset: dailyLimit.toString().length),
      ),
    );
    _weeklyLimitController.value = TextEditingValue(
      text: weeklyLimit.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"),
      selection: TextSelection.fromPosition(
        TextPosition(offset: dailyLimit.toString().length),
      ),
    );
  }

  void storeValueInDb(budgetName, budgetAmt, startDate, endDate, dailyLimit,
      weeklyLimit) async {
    print("BudgetName: ${budgetName.toLowerCase()}");
    print("BudgetAmount: $budgetAmt");
    print("StartDate: $startDate");
    print("endDate: $endDate");
    print("Daily Limit: $dailyLimit");
    print("WeeklyLimit: $weeklyLimit");

    bool budgetNameExist = await doesNameAlreadyExist(budgetName);
    bool checkIfAmtIsGreater = await checkAmt(double.parse(budgetAmt));
    double remainingAmount;

    final User? user = auth.currentUser;

    if (!budgetNameExist) {
      if (checkIfAmtIsGreater) {
        remainingAmount =
            double.parse(initialUserAmt) - double.parse(budgetAmt);
        print('remaining amount is $remainingAmount');

        await FirebaseFirestore.instance
            .collection("users")
            .where('userId', isEqualTo: user!.uid)
            .limit(1)
            .get()
            .then((value) => value.docs.forEach((doc) {
                  doc.reference.update(
                    {
                      'amount': remainingAmount.toString(),
                    },
                  ).onError((error, stackTrace) {
                    _dialogBuilder(context, 'FAILURE', error.toString());
                  });
                }));

        await FirebaseFirestore.instance
            .collection("expenses")
            .doc("budgets")
            .collection(user.email.toString())
            .add({
          "User": user.uid,
          "BudgetName": budgetName,
          "lowerCaseBudgetName": budgetName.toString().toLowerCase(),
          "BudgetAmount": budgetAmt,
          "startDate": startDate,
          "endDate": endDate,
          "DailyLimit": dailyLimit,
          "WeeklyLimit": weeklyLimit
        }).then((DocumentReference doc) {
          print('Budget Created successfully');
          if (budgetName.length > 15) {
            budgetName = budgetName.substring(0, 7);
          }
          service.addTransaction(budgetName, 'Budget Created', true, budgetAmt,
              DateTime.now(), context);
          _dialogBuilder(context, 'SUCCESS', 'Budget Created Successfully');
        }).onError((e, _) {
          print("Error writing document: $e");
          _dialogBuilder(context, 'FAILURE', e.toString());
        });
      } else {
        _dialogBuilder(context, 'FAILURE', 'Insuffecient balance');
      }
    } else {
      if (buttonName == 'Edit Budget') {
        await editValueInDb(
            budgetName, budgetAmt, startDate, endDate, dailyLimit, weeklyLimit);
      } else {
        _dialogBuilder(context, 'FAILURE', 'budget name exists');
      }
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> editValueInDb(budgetName, budgetAmt, startDate, endDate,
      dailyLimit, weeklyLimit) async {
    double formerBudgetAmount = double.parse(retrievedBudgetList.budgetAmount),
        remainingUserAmount = 0;
    bool checkIfAmtIsGreater = true, isDebit = false;
    final User? user = auth.currentUser;

    if (formerBudgetAmount > double.parse(budgetAmt)) {
      remainingUserAmount = double.parse(initialUserAmt) +
          (formerBudgetAmount - double.parse(budgetAmt));
      isDebit = false;
    } else if (formerBudgetAmount < double.parse(budgetAmt)) {
      checkIfAmtIsGreater =
          await checkAmt((double.parse(budgetAmt) - formerBudgetAmount));
      remainingUserAmount = double.parse(initialUserAmt) -
          (double.parse(budgetAmt) - formerBudgetAmount);
      isDebit = true;
    }

    if (checkIfAmtIsGreater) {
      await FirebaseFirestore.instance
          .collection("users")
          .where('userId', isEqualTo: user!.uid)
          .limit(1)
          .get()
          .then((value) => value.docs.forEach((doc) {
                doc.reference.update(
                  {
                    'amount': remainingUserAmount.toString(),
                  },
                ).onError((error, stackTrace) {
                  _dialogBuilder(context, 'FAILURE', error.toString());
                });
              }));

      await FirebaseFirestore.instance
          .collection("expenses")
          .doc("budgets")
          .collection(user.email.toString())
          .where('lowerCaseBudgetName',
              isEqualTo: budgetName.toString().toLowerCase())
          .limit(1)
          .get()
          .then((value) => value.docs.forEach((doc) {
                doc.reference.update(
                  {
                    'User': user.uid,
                    'BudgetName': budgetName,
                    'lowerCaseBudgetName': budgetName.toLowerCase(),
                    'BudgetAmount': budgetAmt,
                    'startDate': startDate,
                    'endDate': endDate,
                    'DailyLimit': dailyLimit,
                    'WeeklyLimit': weeklyLimit
                  },
                ).then((value) {
                  if (formerBudgetAmount > double.parse(budgetAmt)) {
                    if (budgetName.length > 15) {
                      budgetName = budgetName.substring(0, 7);
                    }
                    service.addTransaction(
                        budgetName,
                        'Budget Edited',
                        isDebit,
                        (formerBudgetAmount - double.parse(budgetAmt))
                            .toString(),
                        DateTime.now(),
                        context);
                  } else if (formerBudgetAmount < double.parse(budgetAmt)) {
                    if (budgetName.length > 15) {
                      budgetName = budgetName.substring(0, 7);
                    }
                    service.addTransaction(
                        budgetName,
                        'Budget Edited',
                        isDebit,
                        (double.parse(budgetAmt) - formerBudgetAmount)
                            .toString(),
                        DateTime.now(),
                        context);
                  }

                  _dialogBuilder(
                      context, 'SUCCESS', 'Budget Edited Successfully');
                }).onError((error, stackTrace) {
                  _dialogBuilder(context, 'FAILURE', error.toString());
                });
              }));
    } else {
      _dialogBuilder(context, 'FAILURE', 'Insuffecient balance');
    }
  }

  Future<bool> doesNameAlreadyExist(String name) async {
    final User? user = auth.currentUser;

    await FirebaseFirestore.instance
        .collection("expenses")
        .doc("budgets")
        .collection(user!.email.toString())
        .where('lowerCaseBudgetName', isEqualTo: name.toLowerCase())
        .limit(1)
        .get()
        .then((docs) {
      if (docs.size >= 1) {
        isExist = true;
      } else {
        isExist = false;
      }
    }, onError: (e) {
      print("Error completing: $e");
      _dialogBuilder(context, 'FAILURE', e.toString());
    });

    return isExist;
  }

  Future<bool> checkAmt(double budgetAmt) async {
    final User? user = auth.currentUser;

    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user!.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              final data = doc.data()['amount'].toString();
              initialUserAmt = data;
            }));

    if (budgetAmt > double.parse(initialUserAmt)) {
      return false;
    } else {
      return true;
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
}
