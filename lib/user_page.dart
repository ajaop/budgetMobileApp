import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:proj_1/signin.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _imageLoaded = false;
  String fullName = '',
      firstName = '',
      lastName = '',
      buttonName = 'Edit Information';
  FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false, _obscureText = true, _editAccount = false;
  var img = null;

  @override
  void initState() {
    super.initState();
    getAllValues();
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
          appBar: AppBar(
            leading: const BackButton(color: Color.fromARGB(255, 4, 44, 76)),
            backgroundColor: Color.fromARGB(255, 242, 240, 240),
            automaticallyImplyLeading: false,
            title: const Text(
              'Profile',
              style: TextStyle(
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 44, 76)),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return getAllValues();
            },
            child: ListView(
              children: [
                SafeArea(
                    child: Column(
                  children: [
                    Container(
                      height: 270.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 223, 220, 220),
                        ),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0)),
                        color: Color.fromARGB(255, 242, 240, 240),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey, //New
                              blurRadius: 25.0,
                              offset: Offset(0, -10))
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30.0,
                          ),
                          Center(
                              child: _imageLoaded
                                  ? Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                            radius: 80.0,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  user?.photoURL.toString() ??
                                                      '',
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 160.0,
                                                height: 160.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )),
                                        Positioned(
                                            bottom: 0,
                                            right: -25,
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                _dialogBuilder(context);
                                              },
                                              elevation: 2.0,
                                              fillColor: Color(0xFFF5F6F9),
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                              ),
                                              padding: EdgeInsets.all(15.0),
                                              shape: CircleBorder(),
                                            ))
                                      ],
                                    )
                                  : Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const CircleAvatar(
                                          radius: 80.0,
                                          backgroundImage:
                                              AssetImage('images/profile.png'),
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            right: -25,
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                _dialogBuilder(context);
                                              },
                                              elevation: 2.0,
                                              fillColor: Color(0xFFF5F6F9),
                                              child: const Icon(
                                                Icons.camera_alt_outlined,
                                              ),
                                              padding: EdgeInsets.all(15.0),
                                              shape: const CircleBorder(),
                                            )),
                                      ],
                                    )),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 44, 76),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Container(
                            height: 65.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 223, 220, 220),
                                ),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _editAccount = false;
                                  buttonName = 'Edit Information';
                                });
                                _firstNameController.text = firstName;
                                _lastNameController.text = lastName;
                                showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    enableDrag: false,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(35.0),
                                      ),
                                    ),
                                    builder:
                                        (BuildContext context) =>
                                            StatefulBuilder(builder:
                                                (context, setModalState) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            25.0),
                                                    child: Form(
                                                        key: _formKey,
                                                        child: ListView(
                                                          shrinkWrap: true,
                                                          children: [
                                                            Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    'Account Information',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20.0,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        40.0,
                                                                  ),
                                                                  const Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'First Name',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'OpenSans',
                                                                        letterSpacing:
                                                                            0.6,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme: ThemeData().colorScheme.copyWith(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              44,
                                                                              79,
                                                                              106)),
                                                                    ),
                                                                    child:
                                                                        TextFormField(
                                                                      enabled:
                                                                          _editAccount,
                                                                      controller:
                                                                          _firstNameController,
                                                                      inputFormatters: <
                                                                          TextInputFormatter>[
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp("[a-zA-Z ]")),
                                                                        LengthLimitingTextInputFormatter(
                                                                            100),
                                                                      ],
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        focusedBorder:
                                                                            OutlineInputBorder(),
                                                                        prefixIcon:
                                                                            Icon(Icons.person_outline),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .text,
                                                                      textCapitalization:
                                                                          TextCapitalization
                                                                              .sentences,
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
                                                                          return 'First Name is required';
                                                                        } else if (value
                                                                            .startsWith(RegExp(r'[0-9]'))) {
                                                                          return 'First name is not valid';
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height:
                                                                        30.0,
                                                                  ),
                                                                  const Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Last Name',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'OpenSans',
                                                                        letterSpacing:
                                                                            0.6,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme: ThemeData().colorScheme.copyWith(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              44,
                                                                              79,
                                                                              106)),
                                                                    ),
                                                                    child:
                                                                        TextFormField(
                                                                      enabled:
                                                                          _editAccount,
                                                                      controller:
                                                                          _lastNameController,
                                                                      inputFormatters: <
                                                                          TextInputFormatter>[
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp("[a-zA-Z ]")),
                                                                        LengthLimitingTextInputFormatter(
                                                                            100),
                                                                      ],
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        focusedBorder:
                                                                            OutlineInputBorder(),
                                                                        prefixIcon:
                                                                            Icon(Icons.person_outline),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .text,
                                                                      textCapitalization:
                                                                          TextCapitalization
                                                                              .sentences,
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
                                                                          return 'Last Name is required';
                                                                        } else if (value
                                                                            .startsWith(RegExp(r'[0-9]'))) {
                                                                          return 'Last name is not valid';
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        60.0,
                                                                  ),
                                                                  ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              4,
                                                                              44,
                                                                              76),
                                                                          minimumSize: const Size.fromHeight(
                                                                              60),
                                                                          textStyle: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.w600)),
                                                                      onPressed: !_loading
                                                                          ? () {
                                                                              String name1, name2;
                                                                              name1 = _firstNameController.text.toString();

                                                                              name2 = _lastNameController.text.toString();
                                                                              if (_formKey.currentState!.validate()) {
                                                                                editAccountInfo(setModalState, name1.trim(), name2.trim());
                                                                              }
                                                                            }
                                                                          : null,
                                                                      child: Text(buttonName)),
                                                                  SizedBox(
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                ]),
                                                          ],
                                                        ))),
                                              );
                                            }));
                              },
                              child: Row(
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(15.0, 0, 8.0, 0),
                                    child: Icon(
                                      Icons.person_outline,
                                      size: 30.0,
                                      color: Color.fromARGB(255, 4, 44, 76),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(50.0, 0, 10.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Account Information',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(50.0, 0, 0.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            height: 65.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 223, 220, 220),
                                ),
                                borderRadius: BorderRadius.circular(20.0)),
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
                                    builder:
                                        (BuildContext context) =>
                                            StatefulBuilder(builder:
                                                (context, setModalState2) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            25.0),
                                                    child: Form(
                                                        key: _formKey,
                                                        child: ListView(
                                                          shrinkWrap: true,
                                                          children: [
                                                            Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    'Change Password',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20.0,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        40.0,
                                                                  ),
                                                                  const Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'New Password',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'OpenSans',
                                                                        letterSpacing:
                                                                            0.6,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme: ThemeData().colorScheme.copyWith(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              44,
                                                                              79,
                                                                              106)),
                                                                    ),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _passwordController,
                                                                      obscureText:
                                                                          _obscureText,
                                                                      decoration: InputDecoration(
                                                                          prefixIcon: const Icon(Icons.password),
                                                                          suffixIcon: IconButton(
                                                                              onPressed: () {
                                                                                setModalState2(() {
                                                                                  _obscureText = !_obscureText;
                                                                                });
                                                                              },
                                                                              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)),
                                                                          border: const OutlineInputBorder(),
                                                                          hintText: '*******'),
                                                                      inputFormatters: [
                                                                        LengthLimitingTextInputFormatter(
                                                                            100),
                                                                      ],
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value!.isEmpty ||
                                                                            value.length <
                                                                                6) {
                                                                          return 'Password must be at least 6  character';
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height:
                                                                        30.0,
                                                                  ),
                                                                  const Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Confirm Password',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'OpenSans',
                                                                        letterSpacing:
                                                                            0.6,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme: ThemeData().colorScheme.copyWith(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              44,
                                                                              79,
                                                                              106)),
                                                                    ),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _confirmPasswordController,
                                                                      obscureText:
                                                                          _obscureText,
                                                                      decoration: InputDecoration(
                                                                          prefixIcon: const Icon(Icons.password),
                                                                          suffixIcon: IconButton(
                                                                              onPressed: () {
                                                                                setModalState2(() {
                                                                                  _obscureText = !_obscureText;
                                                                                });
                                                                              },
                                                                              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)),
                                                                          border: const OutlineInputBorder(),
                                                                          hintText: '*******'),
                                                                      inputFormatters: [
                                                                        LengthLimitingTextInputFormatter(
                                                                            100),
                                                                      ],
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value !=
                                                                                _passwordController.text.toString() ||
                                                                            value!.isEmpty) {
                                                                          return 'Passwords don\'t match';
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        60.0,
                                                                  ),
                                                                  ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              4,
                                                                              44,
                                                                              76),
                                                                          minimumSize: const Size.fromHeight(
                                                                              60),
                                                                          textStyle: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.w600)),
                                                                      onPressed: !_loading
                                                                          ? () {
                                                                              if (_formKey.currentState!.validate()) {
                                                                                String pass = _passwordController.text.toString();
                                                                                _changePassword(setModalState2, pass.trim());
                                                                              }
                                                                            }
                                                                          : null,
                                                                      child: const Text('Edit Password')),
                                                                  SizedBox(
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                ]),
                                                          ],
                                                        ))),
                                              );
                                            }));
                              },
                              child: Row(
                                children: const [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15.0, 0, 8.0, 0),
                                    child: Icon(
                                      Icons.password,
                                      size: 30.0,
                                      color: Color.fromARGB(255, 4, 44, 76),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(60.0, 0, 20.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Change Password',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(53.0, 0, 0.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            height: 65.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 223, 220, 220),
                                ),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: InkWell(
                              onTap: () {
                                _signOutDialogBuilder(context);
                              },
                              child: Row(
                                children: const [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15.0, 0, 8.0, 0),
                                    child: Icon(
                                      Icons.logout,
                                      size: 30.0,
                                      color: Color.fromARGB(255, 4, 44, 76),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(87.0, 0, 38.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Sign Out',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(93.0, 0, 0.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            height: 65.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 223, 220, 220),
                                ),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: InkWell(
                              onTap: () {
                                _ResetAmountDialogBuilder(context);
                              },
                              child: Row(
                                children: const [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15.0, 0, 8.0, 0),
                                    child: Icon(
                                      Icons.money,
                                      size: 30.0,
                                      color: Color.fromARGB(255, 4, 44, 76),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(70.0, 0, 38.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Reset Amount',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(60, 0, 0.0, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )),
              ],
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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5.0,
                          primary: Color.fromARGB(255, 246, 241, 241),
                          minimumSize: const Size(150, 65),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        onPressed: () {
                          setState(() {
                            _getFromCamera();
                          });
                        },
                        child: Row(children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Camera',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold))
                        ])),
                    const SizedBox(
                      width: 20.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            primary: Color.fromARGB(255, 241, 239, 239),
                            minimumSize: const Size(150, 65),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () {
                          setState(() {
                            _getFromGallery();
                          });
                        },
                        child: Row(children: const [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Gallery',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold))
                        ])),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Future<void> _signOutDialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(50.0, 20, 50.0, 20),
                  child: Center(
                    child: const Text(
                      'Are you sure you want to sign out ? ',
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
                            primary: Color.fromARGB(255, 4, 44, 76),
                            minimumSize: const Size(100, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () {
                          _signOut();
                        },
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
  }

  Future<void> _ResetAmountDialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          barrierColor:
          Colors.black26;
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(50.0, 20, 50.0, 20),
                  child: Center(
                    child: const Text(
                      'are you sure you want to reset amount ? ',
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
                            primary: Color.fromARGB(255, 4, 44, 76),
                            minimumSize: const Size(100, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () {
                          Navigator.pop(context);

                          _resetAmount();
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(fontSize: 17.0),
                        )),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'NOTE: YOU ARE ONLY ALLOWED 3 RESETS PER DAY ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900]),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                )
              ],
            ),
          );
        });
  }

  Future<void> getAllValues() async {
    setState(() {
      _loading = true;
    });
    final User? user = auth.currentUser;

    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user!.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              lastName = doc.data()['lastname'].toString();
              firstName = doc.data()['firstname'].toString();
            }))
        .onError((error, stackTrace) => errorDialog(error, true));

    fullName = lastName + " " + firstName;

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

    setState(() {
      _loading = false;
    });
  }

  Future<void> editAccountInfo(
      StateSetter setModalState, String firstName, String lastName) async {
    final User? user = auth.currentUser;

    if (_editAccount == false) {
      setModalState(() {
        _editAccount = true;
        buttonName = 'Submit';
      });
    } else {
      setState(() {
        _loading = true;
      });
      setModalState(() {
        _loading = true;
      });
      await FirebaseFirestore.instance
          .collection("users")
          .where('userId', isEqualTo: user!.uid)
          .limit(1)
          .get()
          .then((value) => value.docs.forEach((doc) {
                doc.reference.update(
                  {'firstname': firstName, 'lastname': lastName},
                ).then((value) {
                  setModalState(() {
                    _loading = false;
                    _editAccount = false;
                    buttonName = 'Edit Information';
                  });
                });
              }));

      setState(() {
        _loading = false;
        _editAccount = false;
        buttonName = 'Edit Information';
      });

      Navigator.pop(context);
      getAllValues();
    }
  }

  void _changePassword(StateSetter setModalState2, String password) async {
    setState(() {
      _loading = true;
    });
    setModalState2(() {
      _loading = true;
    });

    final User? user = auth.currentUser;

    await user!.updatePassword(password).then((_) {
      Navigator.pop(context);
      errorDialog('Password Change Successful', false);
    }).catchError((error) {
      errorDialog(error.toString(), true);
    });

    setState(() {
      _loading = false;
    });

    setModalState2(() {
      _loading = false;
    });
  }

  _getFromGallery() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        requestFullMetadata: false);
    if (file != null) {
      setState(() {
        uploadImage(file);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    Navigator.pop(context);
    var path;
    XFile? file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        requestFullMetadata: false);
    if (file != null) {
      setState(() {
        path = file.name;
        uploadImage(file);
      });
    }
  }

  Future<void> uploadImage(XFile file) async {
    setState(() {
      _loading = true;
    });

    final User? user = auth.currentUser;
    var imageFile, imagePath;
    String imgExtension;

    imageFile = File(file.path);
    imgExtension = p.extension(file.name);
    imagePath = 'users/profile/${user!.uid.toString() + imgExtension}';

    final uploadImage =
        FirebaseStorage.instance.ref().child(imagePath).putFile(imageFile);

    final snapshot = await uploadImage.whenComplete(() => null);

    final urlDownload = await snapshot.ref.getDownloadURL();

    user
        .updatePhotoURL(urlDownload)
        .then(
          (value) => getAllValues(),
        )
        .onError((error, stackTrace) => errorDialog(error, true));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
    });

    await FirebaseAuth.instance.signOut();
    final User? user = auth.currentUser;
    if (user?.uid.isEmpty == null) {
      _imageLoaded == false;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => SignIn()));
    } else {
      print("user Id ${user!.uid}");
    }
  }

  Future<void> _resetAmount() async {
    final User? user = auth.currentUser;
    int data = 0;

    setState(() {
      _loading = true;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: user!.uid)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((doc) {
              data = doc.data()['amountReset'];
            }));

    if (data <= 3) {
      await FirebaseFirestore.instance
          .collection("users")
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get()
          .then((value) => value.docs.forEach((doc) {
                doc.reference.update({
                  'amountReset': data + 1,
                  'lastResetTime': DateTime.now()
                }).then((value) {}, onError: (e) {
                  errorDialog(e.toString(), true);
                });
              }));

      await FirebaseFirestore.instance
          .collection("users")
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get()
          .then((value) => value.docs.forEach((doc) {
                doc.reference.update({'amount': '0'}).then((value) {
                  errorDialog('RESET $data OUT OF 3 SUCCESSFUL', true);
                }, onError: (e) {
                  errorDialog(e.toString(), true);
                });
              }));
    } else {
      errorDialog('RESET LIMIT EXCEEDED, TRY AGAIN IN THE NEXT 24 HOURS', true);
    }
    setState(() {
      _loading = false;
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
}
