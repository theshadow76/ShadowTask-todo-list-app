import 'dart:developer';
import 'package:Shadowtask/authentication/login.dart';
import 'package:Shadowtask/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import '../data_models/task_model.dart';
import '../db_helpers/task_db_helper.dart';
import '../premium_detector.dart';
import '../task/new_task.dart';
import '../widgets/status_changer.dart';
import '../widgets/taskCard.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.isPremium}) : super(key: key);

  final bool isPremium;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final DatePickerController _controller = DatePickerController();
  DateTime _selectedValue = DateTime.now();

  late List<Task> tasks;
  bool _isLoading = false;
  late Animation<double> _animation;
  late AnimationController _animationController;

  bool _sortBy_importance = false;

  String welcomeString = "Welcome";

  Future fetchAllTasks() async {
    setState(() {
      _isLoading = true;
      _sortBy_importance = false;
    });
    tasks = await TasksDatabase.instance.readAllTasks();

    setState(() {
      _isLoading = false;
    });
  }

  sortArrray() async {
    List<Task> highList = [];
    List<Task> normalList = [];
    List<Task> LowList = [];

    for (var i = 0; i < tasks.length; i++) {
      log(tasks[i].taskState);
      if (tasks[i].taskState == "High") {
        highList.add(tasks[i]);
      } else if (tasks[i].taskState == "Normal") {
        normalList.add(tasks[i]);
      } else {
        LowList.add(tasks[i]);
      }
    }
    setState(() {
      tasks = highList + normalList + LowList;
    });
  }

  void checkRegistration() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool status = sharedPreferences.getBool("registered") ?? false;
    String email = sharedPreferences.getString("email")!;
    String password = sharedPreferences.getString("password")!;

    if (!status) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        sharedPreferences.setBool("registered", true);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Fluttertoast.showToast(
              msg: "Registration Error! Password not strong enough!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (e.code == 'email-already-in-use') {
          sharedPreferences.setBool("registered", true);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void logOut(BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool("logged", false);
    _prefs.setString("email", "");
    _prefs.setString("password", "");
    _prefs.setBool("isPremium", false);

    Navigator.pushReplacementNamed(context, "/");
  }

  bool _customDateSelected = false;
  DateTime _customDate = DateTime.now();

  ValueNotifier<String> _myString = ValueNotifier<String>('');

  @override
  void initState() {
    log("home premium ${widget.isPremium}");
    fetchAllTasks();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
    _createBannerAd();
    _createBannerAd2();
    checkRegistration();
  }

  BannerAd? _bannerAd;
  BannerAdListener bannerAdListener = BannerAdListener(
      onAdLoaded: (ad) => log("BannerAd Loaded"),
      onAdFailedToLoad: ((ad, error) =>
          {ad.dispose(), log("failed to load Ad $error")}),
      onAdOpened: (ad) => log("BannerAd opend"),
      onAdClosed: (ad) => log("BannerAd closed"));
  void _createBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: Constants().bannerAd1,
        listener: bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  BannerAd? _bannerAd2;
  BannerAdListener bannerAdListener2 = BannerAdListener(
      onAdLoaded: (ad) => log("BannerAd Loaded"),
      onAdFailedToLoad: ((ad, error) =>
          {ad.dispose(), log("failed to load Ad $error")}),
      onAdOpened: (ad) => log("BannerAd opend"),
      onAdClosed: (ad) => log("BannerAd closed"));
  void _createBannerAd2() {
    _bannerAd2 = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: Constants().bannerAd2,
        listener: bannerAdListener2,
        request: const AdRequest())
      ..load();
  }

  @override
  void dispose() {
    // TasksDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white30,
          body: SafeArea(
            child: Column(
              children: [
                ExpansionTile(
                    onExpansionChanged: (value) => {
                          if (value)
                            {
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                _controller.animateToDate(DateTime.now());
                              })
                            }
                          else
                            {
                              setState(() {
                                _customDateSelected = false;
                              })
                            }
                        },
                    trailing: _customDateSelected
                        ? const Text(
                            "Reset",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.isPremium
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                                  context, '/onboarding')
                                              .then((value) =>
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              Login()))));
                                          /* checkPremiumStatusOnline()
                                        .then((value) => log(value.toString()));*/
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 100,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            "Remove ADS",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                              const Icon(Icons.keyboard_arrow_down_outlined),
                            ],
                          ),
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    title: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 10, bottom: 15),
                      child: Text(
                        welcomeString,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26),
                      ),
                    ),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DatePicker(
                            DateTime(2022, 1, 1),
                            //DateTime.now(), //
                            controller: _controller,

                            initialSelectedDate: DateTime.now(),
                            monthTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 11),
                            dateTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 22),
                            dayTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            selectionColor: Colors.black,
                            selectedTextColor: Colors.white,
                            onDateChange: (date) {
                              setState(() {
                                log(date.toString());
                                _customDate = date;
                                _customDateSelected = true;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Sort By :",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (_sortBy_importance) {
                                    fetchAllTasks();
                                  } else {
                                    sortArrray();
                                    setState(() {
                                      _sortBy_importance = true;
                                    });
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.green[500],
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Text(
                                      _sortBy_importance
                                          ? "Due Date"
                                          : "Importance",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ]),
                /*  _bannerAd != null
                    ? (widget.isPremium != null && widget.isPremium ==true
                        ? Container()
                        : Container(
                            alignment: Alignment.center,
                            height: 52,
                            child: AdWidget(ad: _bannerAd!)))
                    : Container(),*/
                const TabBar(
                  tabs: [
                    Tab(child: Text("Pending")),
                    Tab(child: Text("Completed")),
                  ],
                ),
                allData(size),
                _bannerAd2 != null
                    ? (widget.isPremium
                        ? Container()
                        : Container(
                            alignment: Alignment.center,
                            height: 52,
                            child: AdWidget(ad: _bannerAd2!)))
                    : Container()
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          //Init Floating Action Bubble
          floatingActionButton: FloatingActionBubble(
            // Menu items
            items: <Bubble>[
              // Floating action menu item
              Bubble(
                title: "New Task",
                iconColor: Colors.white,
                bubbleColor: Colors.blue,
                icon: Icons.add,
                titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  // Navigator.pop(context);
                  _animationController.reverse();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewTask(
                              update: false,
                              isPremium: widget.isPremium,
                            )),
                  ).then((value) => {fetchAllTasks()});
                },
              ),
              // Floating action menu item
              Bubble(
                title: "Support",
                iconColor: Colors.white,
                bubbleColor: Colors.blue,
                icon: Icons.people,
                titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  Navigator.pushNamed(context, '/support');
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: "Logout",
                iconColor: Colors.white,
                bubbleColor: Colors.blue,
                icon: Icons.logout,
                titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  logOut(context);
                  _animationController.reverse();
                },
              )
            ],
            animation: _animation,
            onPress: () => _animationController.isCompleted
                ? _animationController.reverse()
                : _animationController.forward(),
            iconColor: Colors.blue,
            iconData: Icons.list,
            backGroundColor: Colors.white,
          )),
    );
  }

  Widget allData(Size size) {
    return Expanded(
      child: TabBarView(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              child: Column(
                children: [
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          //reverse: true,
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: tasks.length,
                          itemBuilder: ((BuildContext context, index) {
                            //log("${tasks[index].startDate}  ${tasks[index].endDate}");
                            return tasks[index].status == "Completed"
                                ? Container()
                                : (_customDateSelected
                                    ? (DateFormat('yyyy-MM-dd')
                                                .format(tasks[index].endDate) ==
                                            DateFormat('yyyy-MM-dd')
                                                .format(_customDate)
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: InkWell(
                                              onTap: () {
                                                log("${tasks[index].startDate}  ${tasks[index].endDate}");
                                                showModalBottomSheet(
                                                    context: context,
                                                    builder:
                                                        (context) => Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                _bannerAd !=
                                                                        null
                                                                    ? (widget
                                                                            .isPremium
                                                                        ? Container()
                                                                        : Container(
                                                                            alignment: Alignment
                                                                                .center,
                                                                            height:
                                                                                52,
                                                                            child:
                                                                                AdWidget(ad: _bannerAd!)))
                                                                    : Container(),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => NewTask(update: true, updateTask: tasks[index], isPremium: widget.isPremium)),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            10,
                                                                            30,
                                                                            10,
                                                                            20),
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              300,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.blue,
                                                                              borderRadius: BorderRadius.circular(30)),
                                                                          child:
                                                                              const Text(
                                                                            "Edit",
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child:
                                                                      Divider(),
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    Row(
                                                                      children: const [
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              20,
                                                                              8,
                                                                              10,
                                                                              20),
                                                                          child:
                                                                              Text(
                                                                            "Change Task Status : ",
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 18),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    statusChager(
                                                                        tasks[index]
                                                                            .status,
                                                                        tasks[index]
                                                                            .unique_id,
                                                                        tasks[
                                                                            index],
                                                                        context),
                                                                  ],
                                                                ),
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child:
                                                                      Divider(),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          30,
                                                                          10,
                                                                          20),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          log("delete clicked1");
                                                                          Navigator.pop(
                                                                              context);
                                                                          showGeneralDialog(
                                                                              context: context,
                                                                              transitionDuration: const Duration(milliseconds: 400),
                                                                              pageBuilder: (bc, ania, anis) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Warning"),
                                                                                  titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                                                                                  actionsOverflowButtonSpacing: 20,
                                                                                  actions: [
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(bc);
                                                                                        },
                                                                                        child: const Text("Cancel")),
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          TasksDatabase.instance.delete(tasks[index].unique_id);
                                                                                          fetchAllTasks();
                                                                                          DocumentReference users = FirebaseFirestore.instance.collection('users').doc(tasks[index].email).collection(tasks[index].unique_id).doc(tasks[index].unique_id);
                                                                                          users.delete();
                                                                                          Navigator.pop(bc);
                                                                                        },
                                                                                        child: const Text("Confirm"))
                                                                                  ],
                                                                                  content: const Text("Delete Selected Task?"),
                                                                                );
                                                                              });
                                                                          log("delete clicked");
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              300,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.red,
                                                                              borderRadius: BorderRadius.circular(30)),
                                                                          child:
                                                                              const Text(
                                                                            "Delete",
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ));
                                              },
                                              child: taskCard(
                                                  size,
                                                  tasks[index].status,
                                                  tasks[index].taskState,
                                                  tasks[index].title,
                                                  tasks[index].startDate,
                                                  tasks[index].endDate,
                                                  tasks[index].catagory,
                                                  tasks[index].description),
                                            ))
                                        : Container())
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: InkWell(
                                          onTap: () {
                                            log("${tasks[index].startDate}  ${tasks[index].endDate}");
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) => Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        _bannerAd != null
                                                            ? (widget.isPremium
                                                                ? Container()
                                                                : Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height: 52,
                                                                    child: AdWidget(
                                                                        ad: _bannerAd!)))
                                                            : Container(),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => NewTask(
                                                                          update:
                                                                              true,
                                                                          updateTask: tasks[
                                                                              index],
                                                                          isPremium:
                                                                              widget.isPremium)),
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        10,
                                                                        30,
                                                                        10,
                                                                        20),
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  height: 50,
                                                                  width: 300,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .blue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30)),
                                                                  child:
                                                                      const Text(
                                                                    "Edit",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Divider(),
                                                        ),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              children: const [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          20,
                                                                          8,
                                                                          10,
                                                                          20),
                                                                  child: Text(
                                                                    "Change Task Status : ",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            statusChager(
                                                                tasks[index]
                                                                    .status,
                                                                tasks[index]
                                                                    .unique_id,
                                                                tasks[index],
                                                                context),
                                                          ],
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Divider(),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      10,
                                                                      30,
                                                                      10,
                                                                      20),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  log("delete clicked1");
                                                                  Navigator.pop(
                                                                      context);
                                                                  showGeneralDialog(
                                                                      context:
                                                                          context,
                                                                      transitionDuration: const Duration(
                                                                          milliseconds:
                                                                              400),
                                                                      pageBuilder: (bc,
                                                                          ania,
                                                                          anis) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text("Warning"),
                                                                          titleTextStyle: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                          actionsOverflowButtonSpacing:
                                                                              20,
                                                                          actions: [
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(bc);
                                                                                },
                                                                                child: const Text("Cancel")),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  TasksDatabase.instance.delete(tasks[index].unique_id);
                                                                                  fetchAllTasks();
                                                                                  DocumentReference users = FirebaseFirestore.instance.collection('users').doc(tasks[index].email).collection(tasks[index].unique_id).doc(tasks[index].unique_id);
                                                                                  users.delete();
                                                                                  Navigator.pop(bc);
                                                                                },
                                                                                child: const Text("Confirm"))
                                                                          ],
                                                                          content:
                                                                              const Text("Delete Selected Task?"),
                                                                        );
                                                                      });
                                                                  log("delete clicked");
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  height: 50,
                                                                  width: 300,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30)),
                                                                  child:
                                                                      const Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ));
                                          },
                                          child: taskCard(
                                              size,
                                              tasks[index].status,
                                              tasks[index].taskState,
                                              tasks[index].title,
                                              tasks[index].startDate,
                                              tasks[index].endDate,
                                              tasks[index].catagory,
                                              tasks[index].description),
                                        )));
                          }))
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              child: Column(
                children: [
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          //reverse: true,
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: tasks.length,
                          itemBuilder: ((BuildContext context, index) {
                            return tasks[index].status != "Completed"
                                ? Container()
                                : (_customDateSelected
                                    ? (DateFormat('yyyy-MM-dd')
                                                .format(tasks[index].endDate) ==
                                            DateFormat('yyyy-MM-dd')
                                                .format(_customDate)
                                        ? InkWell(
                                            onTap: () {
                                              log("${tasks[index].startDate}  ${tasks[index].endDate}");
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) => Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Divider(),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        10,
                                                                        30,
                                                                        10,
                                                                        20),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    log("delete clicked1");
                                                                    Navigator.pop(
                                                                        context);
                                                                    showGeneralDialog(
                                                                        context:
                                                                            context,
                                                                        transitionDuration: const Duration(
                                                                            milliseconds:
                                                                                400),
                                                                        pageBuilder: (bc,
                                                                            ania,
                                                                            anis) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                const Text("Warning"),
                                                                            titleTextStyle: const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.black,
                                                                                fontSize: 20),
                                                                            actionsOverflowButtonSpacing:
                                                                                20,
                                                                            actions: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(bc);
                                                                                  },
                                                                                  child: const Text("Cancel")),
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    TasksDatabase.instance.delete(tasks[index].unique_id);
                                                                                    fetchAllTasks();
                                                                                    Navigator.pop(bc);
                                                                                  },
                                                                                  child: const Text("Confirm"))
                                                                            ],
                                                                            content:
                                                                                const Text("Delete Selected Task?"),
                                                                          );
                                                                        });
                                                                    log("delete clicked");
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height: 50,
                                                                    width: 300,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        borderRadius:
                                                                            BorderRadius.circular(30)),
                                                                    child:
                                                                        const Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: taskCard(
                                                  size,
                                                  tasks[index].status,
                                                  tasks[index].taskState,
                                                  tasks[index].title,
                                                  tasks[index].startDate,
                                                  tasks[index].endDate,
                                                  tasks[index].catagory,
                                                  tasks[index].description),
                                            ),
                                          )
                                        : Container())
                                    : InkWell(
                                        onTap: () {
                                          log("${tasks[index].startDate}  ${tasks[index].endDate}");
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Divider(),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    10,
                                                                    30,
                                                                    10,
                                                                    20),
                                                            child: InkWell(
                                                              onTap: () {
                                                                log("delete clicked1");
                                                                Navigator.pop(
                                                                    context);
                                                                showGeneralDialog(
                                                                    context:
                                                                        context,
                                                                    transitionDuration:
                                                                        const Duration(
                                                                            milliseconds:
                                                                                400),
                                                                    pageBuilder:
                                                                        (bc,
                                                                            ania,
                                                                            anis) {
                                                                      return AlertDialog(
                                                                        title: const Text(
                                                                            "Warning"),
                                                                        titleTextStyle: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black,
                                                                            fontSize: 20),
                                                                        actionsOverflowButtonSpacing:
                                                                            20,
                                                                        actions: [
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(bc);
                                                                              },
                                                                              child: const Text("Cancel")),
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                TasksDatabase.instance.delete(tasks[index].unique_id);
                                                                                fetchAllTasks();
                                                                                Navigator.pop(bc);
                                                                              },
                                                                              child: const Text("Confirm"))
                                                                        ],
                                                                        content:
                                                                            const Text("Delete Selected Task?"),
                                                                      );
                                                                    });
                                                                log("delete clicked");
                                                              },
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: 50,
                                                                width: 300,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30)),
                                                                child:
                                                                    const Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ));
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: taskCard(
                                              size,
                                              tasks[index].status,
                                              tasks[index].taskState,
                                              tasks[index].title,
                                              tasks[index].startDate,
                                              tasks[index].endDate,
                                              tasks[index].catagory,
                                              tasks[index].description),
                                        ),
                                      ));
                          }))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
