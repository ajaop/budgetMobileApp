import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _imageLoaded = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  var img = null;

  @override
  void initState() {
    super.initState();
    getAllValues();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;

    print('user pictures ${user!.photoURL.toString()}');

    if (user.uid.isNotEmpty) {
      print("user Id ${user.uid}");
    } else {
      Navigator.pushReplacementNamed(context, '/');
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
          body: SafeArea(
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
                child: Center(
                    child: _imageLoaded
                        ? Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 80.0,
                                backgroundImage:
                                    NetworkImage(user.photoURL.toString()),
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
                          debugPrint('Account info tapped.');
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(90.0, 0, 30.0, 0),
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
                              padding: EdgeInsets.fromLTRB(50.0, 0, 0.0, 0),
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
                          debugPrint('Log out tapped.');
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(150.0, 0, 30.0, 0),
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
                              padding: EdgeInsets.fromLTRB(93.0, 0, 0.0, 0),
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
        )
      ],
    );
  }

  Future<void> getAllValues() async {
    final User? user = auth.currentUser;

    if (user!.photoURL?.isEmpty == null) {
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
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 15.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5.0,
                          primary: Color.fromARGB(255, 246, 241, 241),
                          minimumSize: const Size(150, 65),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        onPressed: () {
                          _getFromCamera;
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
                          _getFromGallery;
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
                SizedBox(
                  height: 50.0,
                )
              ],
            ),
          );
        });
  }

  _getFromGallery() async {
    File imageFile;
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (file != null) {
      setState(() {
        imageFile = File(file.path);
        print('image $imageFile');
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    File imageFile;
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (file != null) {
      setState(() {
        imageFile = File(file.path);
        print('image $imageFile');
      });
    }
  }
}
