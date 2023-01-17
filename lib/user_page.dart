import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                                    onPressed: () {},
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
                                    onPressed: () {},
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
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text('Account Information'),
                          )
                        ],
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

    if (user!.photoURL.toString() == null) {
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
}
