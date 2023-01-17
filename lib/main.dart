import 'package:flutter/material.dart';
import 'package:proj_1/homepage.dart';
import 'package:proj_1/signin.dart';
import 'package:proj_1/user_page.dart';
import 'signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProjApp());
}

class ProjApp extends StatelessWidget {
  const ProjApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      '/': (context) => const SignIn(),
      '/homepage': (context) => HomePage(),
      '/userpage': (context) => UserPage()
    });
  }
}
