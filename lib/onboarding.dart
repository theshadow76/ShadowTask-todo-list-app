import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isLoaded = false;

  void onPayResult(paymentResult) {
    // Send the resulting Google Pay token to your server / PSP
    print(paymentResult);

    FirebaseDatabase db = FirebaseDatabase.instance;
    db
        .ref('purchases')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .set(paymentResult);
    db.ref('users').child(FirebaseAuth.instance.currentUser!.uid).set(
      {'isPurchased': true},
    );

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  Future<void> init() async {
    FirebaseDatabase db = FirebaseDatabase.instance;
    User loggedUser = FirebaseAuth.instance.currentUser!;
    DataSnapshot snapshot = await db.ref('users').child(loggedUser.uid).get();
    dynamic data = snapshot.value;
    log(snapshot.key.toString());

    if (data != null && data['isPurchased'] != null) {
      if (data['isPurchased']) {
        print('purchased');

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        if (mounted) {
          setState(() {
            isLoaded = true;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoaded = true;
        });
      }
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: isLoaded
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You have to make one-time purchase to continue using this app',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '\$1.7',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    // GooglePayButton(
                    //   childOnError: const Text(
                    //     'Google Pay is not supported',
                    //     style: TextStyle(
                    //       color: Colors.white70,
                    //     ),
                    //   ),
                    //   paymentConfigurationAsset: 'google_pay_config.json',
                    //   paymentItems: paymentItems,
                    //   type: GooglePayButtonType.pay,
                    //   margin: const EdgeInsets.only(top: 15.0),
                    //   onPaymentResult: onGooglePayResult,
                    //   loadingIndicator: const Center(
                    //     child: CircularProgressIndicator(),
                    //   ),
                    // ),
                    TextButton(
                      onPressed: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => UsePaypal(
                              sandboxMode: false,
                              clientId:
                                  "Ac-QdnvDtn9PW8nDBBvV6je_ZwRv5PvOKfdZG6nK_BJGrURRBm4EFCHW7S1fHsWqQ0pk16EfYx-UDcvM",
                              secretKey:
                                  "ELLQ7_zXA8JsOL4dr-RJ6s50f89EqqEYnviwwjSt83Keiov4dEpt4-AULnJKLLiOGik6jdjQW4PtOkkf",
                              returnURL: "https://samplesite.com/return",
                              cancelURL: "https://samplesite.com/cancel",
                              transactions: const [
                                {
                                  "amount": {
                                    "total": '1.7',
                                    "currency": "USD",
                                    "details": {
                                      "subtotal": '1.7',
                                      "shipping": '0',
                                      "shipping_discount": 0
                                    }
                                  },
                                  "description":
                                      "The payment transaction description.",
                                  // "payment_options": {
                                  //   "allowed_payment_method":
                                  //       "INSTANT_FUNDING_SOURCE"
                                  // },
                                  "item_list": {
                                    "items": [
                                      {
                                        "name": "Purchase App",
                                        "quantity": 1,
                                        "price": '1.7',
                                        "currency": "USD"
                                      }
                                    ],

                                    // shipping address is not required though
                                    // "shipping_address": {
                                    //   "recipient_name": "Jane Foster",
                                    //   "line1": "Travis County",
                                    //   "line2": "",
                                    //   "city": "Austin",
                                    //   "country_code": "US",
                                    //   "postal_code": "73301",
                                    //   "phone": "+00000000",
                                    //   "state": "Texas"
                                    // },
                                  }
                                }
                              ],
                              note:
                                  "Contact us for any questions on your order.",
                              onSuccess: (Map params) async {
                                log("success");
                                onPayResult(params);
                                print("onSuccess: $params");
                              },
                              onError: (error) {
                                print("onError: $error");
                              },
                              onCancel: (params) {
                                print('cancelled: $params');
                              },
                            ),
                          ),
                        ),
                      },
                      child: const Text("Make Payment"),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
