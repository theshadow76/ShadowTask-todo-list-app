import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkPremiumStatusOnline() async {
  FirebaseDatabase db = FirebaseDatabase.instance;
  User loggedUser = FirebaseAuth.instance.currentUser!;
  DataSnapshot snapshot = await db.ref('users').child(loggedUser.uid).get();
  dynamic data = snapshot.value;
  log(loggedUser.uid);
  return data?["isPurchased"] ?? false;
}

Future<bool> checkPremiumOffline() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var premiumStatus = sharedPreferences.getBool("isPremium") ?? false;
  log("checking offline");
  return premiumStatus;
}
