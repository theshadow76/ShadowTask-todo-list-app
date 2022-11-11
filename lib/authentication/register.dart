import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../data_models/user_model.dart';
import '../db_helpers/task_db_helper.dart';
import '../db_helpers/user_db_helper.dart';
import '../validation/validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireStore;

import '../widgets/auth_bottom.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  fireStore.FirebaseAuth auth = fireStore.FirebaseAuth.instance;

  bool _errored = false;
  String _errorMessage = "";
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  Future register() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmpasswordController.text;
    String valid = signupValidator(email, password, confirmPassword);
    if (valid.contains("Error")) {
      setState(() {
        _errored = true;
        _errorMessage = valid;
      });
    } else {
      var alreadyExist = await UsersDatabase.instance.userExistance(email);
      if (alreadyExist == null) {
        final user = User(email: email, password: password);
        var results = await UsersDatabase.instance.create(user);
        Fluttertoast.showToast(
            msg: "Register Success!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushReplacementNamed(context, "/");
        log("Register ID ${results.id}");
      } else {
        setState(() {
          _errorMessage = "User already in system";
        });
        log("User already in system");
      }
    }

    try {
      fireStore.UserCredential userCredential = await fireStore
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      log("tried firebase");
    } on fireStore.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
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
                  onChanged: ((value) {
                    setState(() {
                      _errorMessage = "";
                    });
                  }),
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: "Email")),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 20, right: 20),
              child: TextFormField(
                onChanged: ((value) {
                  setState(() {
                    _errorMessage = "";
                  });
                }),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Password"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 20, right: 20),
              child: TextFormField(
                onChanged: ((value) {
                  setState(() {
                    _errorMessage = "";
                  });
                }),
                controller: _confirmpasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Confirm Password"),
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
                    register();
                    log("clicked");
                  },
                  child: const Text("Sign Up")),
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
                    const TextSpan(text: "Already Registered? "),
                    TextSpan(
                        text: "Login here!",
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, "/");
                          })
                  ])),
            )
          ],
        ),
      ),
    );
  }
}
