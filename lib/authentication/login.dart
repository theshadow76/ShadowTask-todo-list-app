import 'dart:developer';
import 'dart:io';

import 'package:Shadowtask/home/home.dart';
import 'package:Shadowtask/premium_detector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../validation/validator.dart';
import '../widgets/auth_bottom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_models/user_model.dart' as localUser;

import '../db_helpers/user_db_helper.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = true;
  bool _errored = false;
  String _errorMessage = "";
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future login() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = localUser.User(email: email, password: password);
      var results = await UsersDatabase.instance.create(user);

      prefs.setBool("logged", true);
      prefs.setString("email", email);
      prefs.setString("password", password);
      prefs.setBool("registered", true);
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          checkPremiumStatusOnline().then((value) => {
                log("$value"),
                pushOnboarding(value),
                prefs.setBool("isPremium", value),
                log(" first login check online result $value")
              });
        }
      } on SocketException catch (_) {
        checkPremiumOffline().then((value) => {
              pushOnboarding(value),
              log(" first login check offline result $value")
            });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        String valid = loginValidator(email, password);

        if (valid.contains("Error")) {
          setState(() {
            _errored = true;
            _errorMessage = valid;
          });
        } else {
          var alreadyExist = await UsersDatabase.instance.userExistance(email);
          if (alreadyExist == null) {
            Fluttertoast.showToast(
                msg: "No such User!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {
              _errorMessage = "";
            });
          } else {
            var validUser =
                await UsersDatabase.instance.loginUser(email, password);
            if (validUser.email == email && validUser.password == password) {
              Fluttertoast.showToast(
                  msg: "Welcome!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0);
              prefs.setBool("logged", true);
              prefs.setString("email", email);
              prefs.setString("password", password);
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  checkPremiumStatusOnline().then((value) => {
                        pushOnboarding(value),
                        prefs.setBool("isPremium", value),
                        log(" second login check online result $value")
                      });
                }
              } on SocketException catch (_) {
                checkPremiumOffline().then((value) => {
                      pushOnboarding(value),
                      log(" second login check offline result $value")
                    });
              }
            } else {
              setState(() {
                _errored = true;
                _errorMessage = "Invalid Username or Password!";
              });
            }
          }
        }
      }
    }
  }

  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool("logged") ?? false;
    if (isLogged) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          checkPremiumStatusOnline().then((value) => {
                pushOnboarding(value),
                prefs.setBool("isPremium", value),
                log(" checklogin check online result $value")
              });
        }
      } on SocketException catch (_) {
        checkPremiumOffline().then((value) => {
              pushOnboarding(value),
              log("  checklogin check offline result $value")
            });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  pushOnboarding(bool isPremium) {
    // Navigator.pushReplacementNamed(context, "/home",
    //     arguments: Home(isPremium: isPremium));

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: ((context) => Home(isPremium: isPremium))));
    log("crossed login");
  }

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  loginCard(size),
                  const CustomAuthBTMBar()
                ],
              ),
            ),
    );
  }

  Widget loginCard(Size size) {
    return Card(
      child: SizedBox(
        // height: _size.height * 0.8,
        width: size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 8, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Shadow Task",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 20, right: 20),
              child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: "Email")),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 20, right: 20),
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(hintText: "Password"),
              ),
            ),
            Visibility(
                visible: _errored,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: const Text("LOG IN")),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: Card(
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: Image.asset("assets/images/google_xxl.png"),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Sign with Google",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 25, 8, 25),
              child: RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                    const TextSpan(text: "Don't have an account? "),
                    TextSpan(
                        text: "Register here!",
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(
                                context, "/register");
                          })
                  ])),
            )
          ],
        ),
      ),
    );
  }
}
