import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class AddBudget extends StatefulWidget {
  const AddBudget({Key? key}) : super(key: key);

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final _formKey = GlobalKey<FormState>();
  final _budgetAmtController = TextEditingController();
  var _frequency = [
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
                        decimalDigits: 2,
                        symbol: 'KRW(원) ',
                      )
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '12,000.00',
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
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
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
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
                        if (_formKey.currentState!.validate()) {}
                      },
                      child: const Text('Create Budget'))
                ],
              ))
        ],
      )),
    );
  }
}
