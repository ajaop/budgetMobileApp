import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:proj_1/add_budget_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

void createBudget(id, budgetTitle, amtPerDay, amtSpent, totalAmt) {}

class Data {
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
  List? _data;
  Data() {
    _data = fetched_data["data"];
  }

  int getId(int index) {
    return _data![index]["id"];
  }

  String getTitle(int index) {
    return _data![index]["title"];
  }

  String getAmtPerDay(int index) {
    return _data![index]["amtPerDay"];
  }

  String getAmtSpent(int index) {
    return _data![index]["amtSpent"];
  }

  String getTotalAmt(int index) {
    return _data![index]["totalAmt"];
  }

  int getLength() {
    return _data!.length;
  }
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController tabController;
  late double percent;
  ScrollController? _controller;
  Data _data = new Data();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;
    if (user!.uid.isNotEmpty) {
      print("user Id ${user.uid}");
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
    return Scaffold(
        body: SafeArea(
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
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 1.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 35, 63, 105),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  25.0, 15.0, 25.0, 15.0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 45.0,
                                  ),
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text('2,000,000',
                                        style: TextStyle(
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
                                                fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) =>
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              25.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Amount',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'OpenSans',
                                                                  letterSpacing:
                                                                      0.2,
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          67,
                                                                          65,
                                                                          65)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10.0,
                                                          ),
                                                          TextFormField(
                                                              inputFormatters: [
                                                                CurrencyTextInputFormatter(
                                                                  locale:
                                                                      'en_NG',
                                                                  decimalDigits:
                                                                      0,
                                                                  symbol: '₦',
                                                                ),
                                                                LengthLimitingTextInputFormatter(
                                                                    21),
                                                              ],
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
                                                              }),
                                                          SizedBox(
                                                            height: 40.0,
                                                          ),
                                                          ElevatedButton(
                                                              onPressed: () {},
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      primary:
                                                                          Colors
                                                                              .blue,
                                                                      minimumSize:
                                                                          const Size.fromHeight(
                                                                              60),
                                                                      textStyle: const TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold)),
                                                              child: Text(
                                                                  'Add Money')),
                                                          SizedBox(
                                                            height: 30.0,
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                          );
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
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              height: 270.0,
                              child: ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(height: 15);
                                },
                                primary: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: _data.getLength(),
                                itemBuilder: _itemBuilder,
                              ),
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
        ));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    percent = ((double.parse(_data.getAmtSpent(index)) * 100) /
            double.parse(_data.getTotalAmt(index))) /
        10;
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
                                    _data.getTitle(index),
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
                                  child: Text(
                                      '${_data.getAmtPerDay(index)} per day',
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
                      "Spent ${_data.getAmtSpent(index)} from ${_data.getTotalAmt(index)}",
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
}

Widget _buildPopupDialog(BuildContext context) {
  return new AlertDialog(
    title: const Text('Popup example'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Hello"),
      ],
    ),
    actions: <Widget>[
      new TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}
