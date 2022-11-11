import 'dart:developer';
import 'package:Shadowtask/constants.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../data_models/task_model.dart';
import '../db_helpers/task_db_helper.dart';
import '../home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class NewTask extends StatefulWidget {
  const NewTask(
      {Key? key,
      required this.update,
      this.updateTask,
      required this.isPremium})
      : super(key: key);
  final bool update;
  final Task? updateTask;
  final bool isPremium;
  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _CategoriesController = TextEditingController();
  final TextEditingController _desriptionController = TextEditingController();
  InterstitialAd? _interstitialAd;
  int maxFailedLoadAttempts = 3;
  int _numInterstitialLoadAttempts = 0;
  String? email = "";

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));

  TextStyle commonStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  String dropdownvalue = 'High';

  // List of items in our dropdown menu
  var items = [
    'High',
    'Normal',
    'Low',
  ];

  void getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString("email");
    setState(() {
      email = storedEmail;
    });
  }

  Future addTask(email, uniqueId, taskState, title, startDate, endDate,
      catagory, description, updatedTime) async {
    log("$startDate  $endDate");
    final task = Task(
        email: email,
        unique_id: uniqueId,
        taskState: taskState,
        title: title,
        startDate: startDate,
        endDate: endDate,
        catagory: catagory,
        description: description,
        status: "Active",
        updatedOn: updatedTime);

    var results = await TasksDatabase.instance.create(task);
    log(results.id.toString());
  }

  Future addFirebaseData(email, uniqueId, taskState, title, startDate, endDate,
      catagory, description, updatedTime) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String email = sharedPreferences.getString("email")!;
    DocumentReference users = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection(uniqueId)
        .doc(uniqueId);
    users
        .set({
          "email": email,
          "unique_id": uniqueId,
          "taskState": taskState,
          "title": title,
          "startDate": startDate,
          "endDate": endDate,
          "catagory": catagory,
          "description": description,
          "status": "Active",
          "updatedOn": updatedTime
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future updateTask(task, email, uniqueId, taskState, title, startDate, endDate,
      catagory, description, updatedTime) async {
    final task = Task(
        id: widget.updateTask!.id,
        email: email,
        unique_id: uniqueId,
        taskState: taskState,
        title: title,
        startDate: startDate,
        endDate: endDate,
        catagory: catagory,
        description: description,
        status: widget.updateTask!.status,
        updatedOn: updatedTime);

    var results = await TasksDatabase.instance.update(task);
    log(results.toString());

    DocumentReference users = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection(uniqueId)
        .doc(uniqueId);
    users
        .set({
          "email": email,
          "unique_id": uniqueId,
          "taskState": taskState,
          "title": title,
          "startDate": startDate,
          "endDate": endDate,
          "catagory": catagory,
          "description": description,
          "status": widget.updateTask!.status,
          "updatedOn": updatedTime
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  //ads section

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? Constants().interstitial_id_android
            : Constants().interstitial_id_ios,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    _createInterstitialAd();
    getEmail();
    if (widget.update) {
      setState(() {
        _startDate = widget.updateTask!.startDate;
        _endDate = widget.updateTask!.endDate;
        _titleController.text = widget.updateTask!.title;
        _desriptionController.text = widget.updateTask!.description;
        _CategoriesController.text = widget.updateTask!.catagory;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.update ? "Update Task" : "New Task"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                          "Title",
                          style: commonStyle,
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: TextFormField(
                        controller: _titleController,
                        decoration:
                            const InputDecoration(hintText: "Your Task Title"),
                      ),
                    ),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                          "Task Priority Level",
                          style: commonStyle,
                        ),
                      )
                    ]),
                    DropdownButton(
                      value: dropdownvalue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                        });
                      },
                    ),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                          "Start Date",
                          style: commonStyle,
                        ),
                      )
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(DateFormat("yyyy-MM-dd - hh:mm")
                            .format(_startDate)),
                        InkWell(
                          onTap: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2021, 3, 5),
                                maxTime:
                                    DateTime.now().add(Duration(days: 1000)),
                                onChanged: (val) {
                              log("Selected due Date value : ${val}");
                              setState(() {
                                _startDate = val;
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 120,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Change",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                    /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        initialValue: /*widget.update
                            ? widget.updateTask!.startDate.toString()
                            : */
                            DateTime.now().toString(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: const Icon(Icons.event),
                        dateLabelText: 'Date',
                        timeLabelText: "Hour",
                        selectableDayPredicate: (date) {
                          // Disable weekend days to select from the calendar
                          if (date.weekday == 6 || date.weekday == 7) {
                            return false;
                          }

                          return true;
                        },
                        onChanged: (val) => () {
                          setState(() {
                            _startDate = DateTime.parse(val.toString());
                          });
                        },
                        validator: (val) {
                          return null;
                        },
                        onSaved: (val) => print(val),
                      ),
                    ),*/
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                          "Due Date",
                          style: commonStyle,
                        ),
                      )
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(DateFormat("yyyy-MM-dd - hh:mm").format(_endDate)),
                        InkWell(
                          onTap: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2021, 3, 5),
                                maxTime:
                                    DateTime.now().add(Duration(days: 1000)),
                                onChanged: (val) {
                              log("Selected due Date value : ${val}");
                              setState(() {
                                _endDate = val;
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 120,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Change",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                    /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        initialValue: /* widget.update
                            ? widget.updateTask!.endDate.toString()
                            :*/
                            DateTime.now()
                                .add(const Duration(days: 1))
                                .toString(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: const Icon(Icons.event),
                        dateLabelText: 'Date',
                        timeLabelText: "Hour",
                        onEditingComplete: () {
                          log("fxd");
                        },
                        onFieldSubmitted: (val) {
                          log("Selected due Date value : ${val}");
                        },
                        onChanged: (val) => () {
                          log("Selected due Date value : ${val}");
                          setState(() {
                            _endDate = DateTime.parse(val.toString());
                          });
                        },
                      ),
                    ),*/
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                          "Categories",
                          style: commonStyle,
                        ),
                      )
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      child: TextFormField(
                        controller: _CategoriesController,
                        decoration: const InputDecoration(
                            hintText: "Add Tag Categories "),
                      ),
                    ),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                          "Description / Notes",
                          style: commonStyle,
                        ),
                      )
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: TextFormField(
                        maxLines: null,
                        controller: _desriptionController,
                        decoration: const InputDecoration(
                            hintText: "Task Additional Infromation here!"),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        String uuid = const Uuid().v4();
                        log(uuid);
                        if (widget.update) {
                          log(_titleController.text);
                          updateTask(
                              widget.updateTask,
                              email,
                              widget.updateTask!.unique_id,
                              dropdownvalue,
                              _titleController.text,
                              _startDate,
                              _endDate,
                              _CategoriesController.text,
                              _desriptionController.text,
                              now);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home(
                                      isPremium: widget.isPremium,
                                    )),
                          );
                        } else {
                          log(_startDate.toString());
                          log(_endDate.toString());
                          if (_titleController.text != "") {
                            addTask(
                                email,
                                uuid,
                                dropdownvalue,
                                _titleController.text,
                                _startDate,
                                _endDate,
                                _CategoriesController.text,
                                _desriptionController.text,
                                now);
                            addFirebaseData(
                                email,
                                uuid,
                                dropdownvalue,
                                _titleController.text,
                                _startDate,
                                _endDate,
                                _CategoriesController.text,
                                _desriptionController.text,
                                now);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                        isPremium: widget.isPremium,
                                      )),
                            );
                            if (!widget.isPremium) {
                              _showInterstitialAd();
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Title can't be Empty",
                                textColor: Colors.white,
                                backgroundColor: Colors.red,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM);
                          }
                        }
                      },
                      child: Text(widget.update ? "Update" : "Finish")),
                ),
              ],
            ),
          ),
        ));
  }
}
