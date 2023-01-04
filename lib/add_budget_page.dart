import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';

class AddBudget extends StatefulWidget {
  const AddBudget({Key? key}) : super(key: key);

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final _formKey = GlobalKey<FormState>();
  var dateNow;
  final _budgetTitleController = TextEditingController();
  final _budgetAmtController = TextEditingController();
  final _startDateController = TextEditingController();
  final _dailyLimitController = TextEditingController();
  final _weeklyLimitController = TextEditingController();
  dynamic db = FirebaseFirestore.instance;
  final _frequency = [
    "1 Week",
    "2 Weeks",
    "1 Month",
    "2 Months",
    "3 Months",
    "4 Months",
    "5 Months",
    "1 Year"
  ];

  String dropdownvalue = '1 Week';

  @override
  void dispose() {
    _budgetTitleController.dispose();
    _budgetAmtController.dispose();
    _dailyLimitController.dispose();
    _weeklyLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Color.fromARGB(255, 4, 44, 76)),
        backgroundColor: Colors.white,
        title: const Text(
          'Add Budget',
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Food & Drinks',
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (value) {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Title is required';
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
                    ],
                    onChanged: (text) {
                      calculateDailyWeeklyLimit(text);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '12,000.00',
                    ),
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.sentences,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (value) {},
                    validator: (value) {
                      if (value!.isEmpty) {
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
                              readOnly:
                                  true, //set it true, so that user will not able to edit text
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
                                              String day =
                                                  newdate.day.toString();

                                              String month =
                                                  newdate.month.toString();

                                              String year =
                                                  newdate.year.toString();
                                              String startDate = day +
                                                  '/' +
                                                  month +
                                                  '/' +
                                                  year;

                                              _startDateController.value =
                                                  TextEditingValue(
                                                text: startDate,
                                                selection:
                                                    TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: startDate
                                                          .toString()
                                                          .length),
                                                ),
                                              );
                                            },
                                            mode: CupertinoDatePickerMode.date,
                                          ));
                                    });
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onFieldSubmitted: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Title is required';
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
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                                hintText: '12/11/23',
                              ),
                              keyboardType: TextInputType.datetime,
                              textCapitalization: TextCapitalization.sentences,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onFieldSubmitted: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Title is required';
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
                      'Budget Timeframe',
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
                  DropdownButtonFormField(
                    value: dropdownvalue,
                    items: _frequency.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                      calculateDailyWeeklyLimit(_budgetAmtController.text);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '1 month',
                    ),
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
                      if (value!.isEmpty) {
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
                      if (value!.isEmpty) {
                        return 'Weekly limit is required';
                      }
                    },
                  ),
                  SizedBox(
                    height: 60.0,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 4, 44, 76),
                          minimumSize: const Size.fromHeight(50),
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String name = _budgetTitleController.text.toString();
                          String amount = _budgetAmtController.text
                              .toString()
                              .replaceAll(',', '')
                              .replaceAll('₦', '');
                          String frequency = dropdownvalue;
                          String dailyAmt = _dailyLimitController.text
                              .toString()
                              .replaceAll(',', '')
                              .replaceAll('₦', '');
                          String weeklyAmt = _weeklyLimitController.text
                              .toString()
                              .replaceAll(',', '')
                              .replaceAll('₦', '');
                          storeValueInDb(
                              name, amount, frequency, dailyAmt, weeklyAmt);
                        }
                      },
                      child: const Text('Create Budget'))
                ],
              ))
        ],
      )),
    );
  }

  void calculateDailyWeeklyLimit(var text) {
    double val = 0;
    double dailyLimit = 0;
    double weeklyLimit = 0;
    if (text.isNotEmpty) {
      val = double.parse(text.replaceAll(',', '').replaceAll('₦', ''));
    }
    if (dropdownvalue == "1 Week") {
      dailyLimit = val / 7;
      weeklyLimit = val / 1;
    } else if (dropdownvalue == "2 Weeks") {
      dailyLimit = val / 14;
      weeklyLimit = val / 2;
    } else if (dropdownvalue == "1 Month") {
      dailyLimit = val / 30;
      weeklyLimit = val / 4;
    } else if (dropdownvalue == "3 Months") {
      dailyLimit = val / 90;
      weeklyLimit = val / 12;
    } else if (dropdownvalue == "4 Months") {
      dailyLimit = val / 120;
      weeklyLimit = val / 16;
    } else if (dropdownvalue == "5 Months") {
      dailyLimit = val / 150;
      weeklyLimit = val / 20;
    } else if (dropdownvalue == "1 Year") {
      dailyLimit = val / 365;
      weeklyLimit = val / 52.143;
    }

    _dailyLimitController.value = TextEditingValue(
      text: dailyLimit.toStringAsFixed(2).replaceAllMapped(
          new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"),
      selection: TextSelection.fromPosition(
        TextPosition(offset: dailyLimit.toString().length),
      ),
    );
    _weeklyLimitController.value = TextEditingValue(
      text: weeklyLimit.toStringAsFixed(2).replaceAllMapped(
          new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"),
      selection: TextSelection.fromPosition(
        TextPosition(offset: dailyLimit.toString().length),
      ),
    );
  }

  void storeValueInDb(
      budgetName, budgetAmt, frequency, dailyLimit, weeklyLimit) {
    print("BudgetName: $budgetName");
    print("BudgetAmount: $budgetAmt");
    print("Frequency: $frequency");
    print("Daily Limit: $dailyLimit");
    print("WeeklyLimit: $weeklyLimit");

    db
        .collection("users")
        .add({
          "BudgetName": budgetName,
          "BudgetAmount": budgetAmt,
          "Frequency": frequency,
          "DailyLimit": dailyLimit,
          "WeeklyLimit": weeklyLimit
        })
        .then((DocumentReference doc) => print('Budget Created successfully'))
        .onError((e, _) => print("Error writing document: $e"));
  }
}
