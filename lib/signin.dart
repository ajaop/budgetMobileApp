import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:proj_1/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscureText = true;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login(username, pass) async {
    try {
      final credential = await auth
          .signInWithEmailAndPassword(email: username, password: pass)
          .then(
              (value) => Navigator.pushReplacementNamed(context, '/homepage'));

      final User? user = auth.currentUser;
      dynamic id = user!.uid;
      print("User with $id is logged in");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        print('No user found');
        error('Wrong email or password.');
      } else {
        print(e);
        error(e.message);
      }
    }
    setState(() {
      _loading = false;
    });
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

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Welcome Back',
                      style: TextStyle(
                          letterSpacing: 0.6,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 44, 76)),
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email is required';
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      }
                    },
                  ),
                  const SizedBox(
                    height: 35.0,
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

                                login(_emailController.text.toString(),
                                    _passwordController.text.toString());
                              }
                            }
                          : null,
                      child: const Text('Sign in')),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Dont have an account ?"),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        const SignupScreen())));
                          },
                          child: const Text('Sign up'))
                    ],
                  )
                ],
              ),
            ),
          )),
        ),
        if (_loading)
          Center(
            child: SpinKitSquareCircle(
              color: Colors.blue[500],
              size: 100.0,
            ),
          )
      ],
    );
  }
}
