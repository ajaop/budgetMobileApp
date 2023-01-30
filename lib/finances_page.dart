import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'Transactions.dart';
import 'database_service.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({Key? key}) : super(key: key);

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  ScrollController? _controller;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _transactionTypeController = TextEditingController();
  final _searchTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var startDate, minimumEndDate, endDate;
  DatabaseService service = DatabaseService();
  Future<List<Transactions>>? transactionsList;
  List<Transactions>? retrievedtransactionsList;
  bool isFilterDate = false, isFilterName = true, _loading = false;

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  Future<void> getAllData() async {
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    setState(() {
      _loading = true;
    });
    transactionsList = service.retrieveAllTransactions();
    retrievedtransactionsList = await service.retrieveAllTransactions();

    retrievedtransactionsList!.sort(
      (a, b) {
        return b.transactionDate.compareTo(a.transactionDate);
      },
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _searchTextController.dispose();
    _transactionTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              leading:
                  const BackButton(color: Color.fromARGB(255, 242, 240, 240)),
              backgroundColor: Color.fromARGB(255, 242, 240, 240),
              title: const Text(
                'Transactions',
                style: TextStyle(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 4, 44, 76)),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.filter_list_outlined,
                    color: Color.fromARGB(255, 4, 44, 76),
                  ),
                  onPressed: () {
                    _showPopupMenu();
                  },
                )
              ],
              centerTitle: true,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () {
                return getAllData();
              },
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Visibility(
                      visible: isFilterName,
                      child: Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                      controller: _searchTextController,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(20),
                                      ],
                                      onChanged: (value) =>
                                          filterTransaction(value),
                                      decoration: const InputDecoration(
                                        hintText: 'Foods & Drinks',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      )),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: ElevatedButton(
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color.fromARGB(255, 35, 63, 105),
                                    minimumSize:
                                        const Size(80, double.infinity),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(15.0),
                                            bottomRight:
                                                Radius.circular(15.0))),
                                  ),
                                  child: Icon(Icons.search_outlined)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isFilterDate,
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              const Text('From',
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      letterSpacing: 0.6,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 67, 65, 65))),
                              SizedBox(
                                height: 5.0,
                              ),
                              TextFormField(
                                controller: _startDateController,
                                decoration: const InputDecoration(
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
                                              onDateTimeChanged:
                                                  (DateTime newdate) {
                                                var inputFormat =
                                                    DateFormat('dd/MM/yyyy');

                                                startDate = newdate;
                                                String startDateText =
                                                    inputFormat.format(newdate);

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
                                              },
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                            ));
                                      });
                                },
                              )
                            ],
                          )),
                          SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    letterSpacing: 0.6,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 67, 65, 65)),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              TextFormField(
                                controller: _endDateController,
                                decoration: const InputDecoration(
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
                                              minimumDate: startDate,
                                              initialDateTime: startDate,
                                              onDateTimeChanged:
                                                  (DateTime newdate) {
                                                var inputFormat =
                                                    DateFormat('dd/MM/yyyy');

                                                endDate = newdate;
                                                String endDateText =
                                                    inputFormat.format(newdate);

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
                                              },
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                            ));
                                      });
                                },
                              )
                            ],
                          )),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
                            child: ElevatedButton(
                                onPressed: () {
                                  filterTransactionyDate(startDate, endDate);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromARGB(255, 35, 63, 105),
                                  minimumSize: const Size(85, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                ),
                                child: const Icon(Icons.search_outlined)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: FutureBuilder(
                          future: transactionsList,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Transactions>> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                retrievedtransactionsList?.isEmpty == null) {
                              return Container(
                                child: const Center(
                                  child: Text(
                                    'No Transactions Yet',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 20.0),
                                  ),
                                ),
                              );
                            }
                            if (retrievedtransactionsList?.isEmpty ?? true) {
                              return Container(
                                child: const Center(
                                  child: Text(
                                    'No Transactions Yet',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 20.0),
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              return ListView.separated(
                                shrinkWrap: true,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(height: 15);
                                },
                                primary: false,
                                scrollDirection: Axis.vertical,
                                itemCount:
                                    retrievedtransactionsList?.length ?? 0,
                                itemBuilder: _transactionItemBuilder,
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
                  ],
                ),
              )),
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

  void _showPopupMenu() async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(500, 100, 10, 100),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      items: [
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSortPopupMenu();
              },
              child: Row(
                children: const [
                  Text(
                    "Sort By",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.black,
                    size: 25,
                  )
                ],
              )),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _showSortPopupMenu() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(500, 100, 10, 100),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      items: [
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                setState(() {
                  isFilterDate = false;
                  isFilterName = true;
                });

                Navigator.pop(context);
              },
              child: Row(
                children: const [
                  Text(
                    "Name",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                setState(() {
                  isFilterDate = true;
                  isFilterName = false;
                });
                Navigator.pop(context);
              },
              child: Row(
                children: const [
                  Text(
                    "Date",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showtransactionType();
              },
              child: Row(
                children: const [
                  Text(
                    "Transaction Type",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.black,
                    size: 25,
                  )
                ],
              )),
        ),
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ComplexTransacModal();
              },
              child: Row(
                children: const [
                  Text(
                    "Complex Search",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _showtransactionType() async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(500, 100, 10, 100),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      items: [
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                setState(() {
                  isFilterName = false;
                  isFilterDate = false;
                });
                Navigator.pop(context);
                getCredit();
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.credit_score_outlined,
                    color: Color.fromARGB(255, 27, 94, 32),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "Credits",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                setState(() {
                  isFilterName = false;
                  isFilterDate = false;
                });
                Navigator.pop(context);
                getDebit();
              },
              child: Row(
                children: const [
                  Icon(Icons.credit_score_outlined,
                      color: Color.fromARGB(255, 183, 28, 28)),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "Debits",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _showtransactionType2() async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        500,
        800,
        10,
        10,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      items: [
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _transactionTypeController.text = 'Credit';
                });
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.credit_score_outlined,
                    color: Color.fromARGB(255, 27, 94, 32),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "Credit",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
        PopupMenuItem(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _transactionTypeController.text = 'Debit';
                });
              },
              child: Row(
                children: const [
                  Icon(Icons.credit_score_outlined,
                      color: Color.fromARGB(255, 183, 28, 28)),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "Debit",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              )),
        ),
      ],
      elevation: 8.0,
    );
  }

  Widget _transactionItemBuilder(BuildContext context, int index) {
    var transactionAmt = NumberFormat.currency(locale: "en_NG", symbol: "₦")
        .format(
            double.parse(retrievedtransactionsList![index].transactionAmount));

    String transactionName = retrievedtransactionsList![index].transactionTitle;
    String imageText = '';

    var names = transactionName.split(' ');
    if (names.length >= 2) {
      imageText = (names[0][0] + names[1][0]).toUpperCase();
    } else {
      imageText =
          (names[0][0] + names[0][(transactionName.length - 1)]).toUpperCase();
    }
    String formattedTransacDate = DateFormat.yMMMd()
        .format(retrievedtransactionsList![index].transactionDate);

    String formattedTransacTime = DateFormat.Hm()
        .format(retrievedtransactionsList![index].transactionDate);

    var amtColor;
    String amtSign;
    bool isSameDate = true;
    final DateTime presentDate =
        retrievedtransactionsList![index].transactionDate;

    if (retrievedtransactionsList![index].transactionType == 'Credit') {
      amtColor = Colors.green[900];
      amtSign = '+';
    } else {
      amtColor = Colors.red[900];
      amtSign = '-';
    }

    if (service.daysBetween(retrievedtransactionsList![index].transactionDate,
            DateTime.now()) ==
        0) {
      formattedTransacDate = 'Today';
    } else if (service.daysBetween(
            retrievedtransactionsList![index].transactionDate,
            DateTime.now()) ==
        1) {
      formattedTransacDate = 'Yesterday';
    }

    if (index == 0) {
      isSameDate = false;
    } else {
      final DateTime prevDate =
          retrievedtransactionsList![index - 1].transactionDate;
      final DateTime presentDate =
          retrievedtransactionsList![index].transactionDate;
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
                                retrievedtransactionsList![index]
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
                              '$amtSign  $transactionAmt',
                              style: TextStyle(
                                  color: amtColor, fontWeight: FontWeight.bold),
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

  Future<void> filterTransaction(String enteredKeyword) async {
    retrievedtransactionsList = await service.retrieveAllTransactions();
    List<Transactions> results = [];
    if (enteredKeyword.isEmpty) {
      results = await service.retrieveAllTransactions();
    } else {
      results = retrievedtransactionsList!
          .where((transaction) => transaction.transactionTitle
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      results.sort(
        (a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        },
      );
    }

    // Refresh the UI
    setState(() {
      retrievedtransactionsList = results;
    });
  }

  Future<void> getCredit() async {
    Future<List<Transactions>>? transactionsCreditList;
    List<Transactions>? retrievedtransactionsCreditList;

    setState(() {
      _loading = true;
    });

    transactionsCreditList = service.retrieveTransactionsCredit();
    retrievedtransactionsCreditList =
        await service.retrieveTransactionsCredit();

    retrievedtransactionsCreditList.sort(
      (a, b) {
        return b.transactionDate.compareTo(a.transactionDate);
      },
    );

    setState(() {
      transactionsList = transactionsCreditList;
      retrievedtransactionsList = retrievedtransactionsCreditList;

      _loading = false;
    });
  }

  Future<void> getDebit() async {
    Future<List<Transactions>>? transactionsDebitList;
    List<Transactions>? retrievedtransactionsDebitList;

    setState(() {
      _loading = true;
    });

    transactionsDebitList = service.retrieveTransactionsDebit();
    retrievedtransactionsDebitList = await service.retrieveTransactionsDebit();

    retrievedtransactionsDebitList.sort(
      (a, b) {
        return b.transactionDate.compareTo(a.transactionDate);
      },
    );

    setState(() {
      transactionsList = transactionsDebitList;
      retrievedtransactionsList = retrievedtransactionsDebitList;

      _loading = false;
    });
  }

  Future<void> filterTransactionyDate(DateTime from, DateTime to) async {
    retrievedtransactionsList = await service.retrieveAllTransactions();
    List<Transactions> results = [];
    if (from.toString().isEmpty || to.toString().isEmpty) {
      results = await service.retrieveAllTransactions();
    } else {
      results = retrievedtransactionsList!
          .where((transaction) =>
              transaction.transactionDate.isAfter(from) &&
              transaction.transactionDate.isBefore(to))
          .toList();
      results.sort(
        (a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        },
      );
    }

    // Refresh the UI
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      retrievedtransactionsList = results;
    });
  }

  Future<void> filterComplexTransaction(
      DateTime from, DateTime to, String transactionType) async {
    setState(() {
      _loading = true;
    });
    retrievedtransactionsList = await service.retrieveAllTransactions();
    List<Transactions> results = [];
    if (from.toString().isEmpty || to.toString().isEmpty) {
      results = await service.retrieveAllTransactions();
    } else {
      results = retrievedtransactionsList!
          .where((transaction) =>
              transaction.transactionDate.isAfter(from) &&
              transaction.transactionDate.isBefore(to) &&
              transaction.transactionType.contains(transactionType))
          .toList();
      results.sort(
        (a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        },
      );
    }

    // Refresh the UI
    setState(() {
      _loading = false;
      _startDateController.clear();
      _endDateController.clear();
      _transactionTypeController.clear();
      retrievedtransactionsList = results;
    });
  }

  Future<void> ComplexTransacModal() {
    return showModalBottomSheet<void>(
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
              return Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 40.0,
                          ),
                          Row(
                            children: [
                              Text(
                                'Date :',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                  child: TextFormField(
                                controller: _startDateController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Start Date',
                                    suffixIcon: Icon(Icons.arrow_drop_down)),
                                keyboardType: TextInputType.datetime,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (value) {},
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Start Date is required';
                                  }
                                },
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
                                              onDateTimeChanged:
                                                  (DateTime newdate) {
                                                var inputFormat =
                                                    DateFormat('dd/MM/yyyy');

                                                startDate = newdate;
                                                String startDateText =
                                                    inputFormat.format(newdate);

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
                                              },
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                            ));
                                      });
                                },
                              )),
                              SizedBox(
                                width: 15.0,
                              ),
                              Expanded(
                                  child: TextFormField(
                                controller: _endDateController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'End Date',
                                    suffixIcon: Icon(Icons.arrow_drop_down)),
                                keyboardType: TextInputType.datetime,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (value) {},
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'End Date is required';
                                  }
                                },
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
                                              minimumDate: startDate,
                                              initialDateTime: startDate,
                                              onDateTimeChanged:
                                                  (DateTime newdate) {
                                                var inputFormat =
                                                    DateFormat('dd/MM/yyyy');

                                                endDate = newdate;
                                                String endDateText =
                                                    inputFormat.format(newdate);

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
                                              },
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                            ));
                                      });
                                },
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Row(
                            children: [
                              Text(
                                'Transaction Type :',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                  child: TextFormField(
                                controller: _transactionTypeController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Select Type',
                                    suffixIcon: Icon(Icons.arrow_drop_down)),
                                keyboardType: TextInputType.datetime,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (value) {},
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Transaction type is required';
                                  }
                                },
                                readOnly: true,
                                onTap: () {
                                  _showtransactionType2();
                                },
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 60.0,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  primary: Color.fromARGB(255, 35, 63, 105),
                                  minimumSize: const Size.fromHeight(60),
                                  textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              onPressed: !_loading
                                  ? () {
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.pop(context);
                                        filterComplexTransaction(
                                            startDate,
                                            endDate,
                                            _transactionTypeController.text
                                                .toString());
                                      }
                                    }
                                  : null,
                              child: Text('GO')),
                          SizedBox(
                            height: 70.0,
                          )
                        ],
                      ),
                    )),
              );
            }));
  }
}
