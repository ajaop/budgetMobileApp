import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMoney extends StatefulWidget {
  const AddMoney({Key? key}) : super(key: key);

  @override
  State<AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
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
            title: const Text(
              'Add Money',
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
            padding: EdgeInsets.all(25.0),
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Description',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              letterSpacing: 0.6,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 67, 65, 65)),
                        ),
                      )
                    ],
                  ))
            ],
          )),
        )
      ],
    );
  }
}
