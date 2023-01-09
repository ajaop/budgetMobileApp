import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscureText = true;
  dynamic db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void register(username, pass) async {
    var firstNameText = _firstNameController.text.toString();
    var lastNameText = _lastNameController.text.toString();
    var emailText = _emailController.text.toString();

    try {
      final credential = await auth
          .createUserWithEmailAndPassword(email: username, password: pass)
          .then((value) =>
              print('user with user id ${value.user!.uid} is logged in'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        error('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        error('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        error('Invalid Email');
      } else {
        error(e.message);
        print(e);
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _loading = false;
    });

    sendToDB(firstNameText, lastNameText, emailText);
  }

  void sendToDB(firstname, lastname, email) {
    setState(() {
      _loading = true;
    });

    final User? user = auth.currentUser;
    if (user!.uid.isNotEmpty) {
      final docs = db.collection("users").add({
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "userId": user.uid,
        "amount": 0
      }).then((DocumentReference doc) {
        Navigator.pushReplacementNamed(context, '/homepage');
      });

      setState(() {
        _loading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        body: SafeArea(
            child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign Up',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            letterSpacing: 0.6,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 4, 44, 76)),
                      ),
                    ),
                    const SizedBox(
                      height: 80.0,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Firstname',
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            letterSpacing: 0.6,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'John',
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      onFieldSubmitted: (value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Firstname is required';
                        }
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lastname',
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            letterSpacing: 0.6,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Doe',
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (value) {},
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Lastname is required';
                        }
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email',
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            letterSpacing: 0.6,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                        hintText: 'test@gmail.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (value) {},
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              letterSpacing: 0.6,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        )),
                    const SizedBox(
                      height: 2.0,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(_obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                          border: const OutlineInputBorder(),
                          hintText: '*******'),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password must be at least 6  character';
                        }
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Text(
                      'Creating an account means you agree to the Terms of Service and our Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          letterSpacing: 0.2,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
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
                                  register(_emailController.text.toString(),
                                      _passwordController.text.toString());
                                }
                              }
                            : null,
                        child: const Text('Create Account')),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account ?"),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Sign in')),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        )),
      ),
      if (_loading)
        Center(
          child: SpinKitSquareCircle(
            color: Colors.blue[500],
            size: 100.0,
          ),
        )
    ]);
  }
}
