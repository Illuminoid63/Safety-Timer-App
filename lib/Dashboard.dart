import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "emergencyDependee.dart";
import "LoginSignUpForm.dart";
import "TimerRoute.dart";
import 'package:duration_picker/duration_picker.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<EmergencyDependee> emergencyDependees = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    //might not need this if I am using stream builder
    emergencyDependees.clear();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var snapshot =
        await firestore.collection("users").doc(auth.currentUser.uid).get();
    for (var dependee in snapshot.data()["emergency dependees"]) {
      var currentDependee =
          EmergencyDependee(dependee["nickname"], dependee["email"]);
      emergencyDependees.add(currentDependee);
    }
    setState(() {});
  }

  Widget createNickNameSetterWidget(String email, String oldNickName) {
    String _newNickname = "";
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: TextFormField(
                autofocus: false,
                onChanged: (newText) {
                  _newNickname = newText;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Set Nickname",
                ),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                FirebaseAuth auth = FirebaseAuth.instance;

                //this runs the following updates in a transaction, meaning in a single atomic step, so that we don't need a loading screen
                await firestore.runTransaction((transaction) async {
                  var user =
                      firestore.collection("users").doc(auth.currentUser.uid);

                  transaction.update(user, {
                    "emergency dependees": FieldValue.arrayRemove([
                      {"nickname": oldNickName, "email": email}
                    ])
                  });
                  transaction.update(user, {
                    "emergency dependees": FieldValue.arrayUnion([
                      {"nickname": _newNickname, "email": email}
                    ])
                  });
                }, timeout: Duration(seconds: 10));
              },
              child: Text("Set"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = firestore.collection("users").doc(auth.currentUser.uid);

    return Scaffold(
        appBar: AppBar(
          title: Text("Safety Timer Dashboard"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginSignUpForm()));
            },
            icon: Icon(Icons.logout),
            tooltip: "Logout",
          ),
          actions: [
            IconButton(
              onPressed: () {
                //im thinking gps granularity and light/dark theme, or no settings at all its kinda an all or nothing thing here
                //also clear cached gps data button with snackbar
                //also delete account with alert dialog/box making sure they want to delete
                //if they can delete their account then need to add error checking when an emergency contact tries to look at their data but their account (i.e. their document has been deleted)
              },
              icon: Icon(Icons.settings),
              tooltip: "Settings",
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                child: ElevatedButton(
                  onPressed: () {
                    //panic button trigger
                    print("panic");
                  },
                  child: Padding(
                    child: Text(
                      "PANIC",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 25),
              ),
              Expanded(
                  child: StreamBuilder(
                      stream: user.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return Padding(
                              padding: EdgeInsets.only(bottom: 100),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Loading...",
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 30),
                                      child: LinearProgressIndicator(
                                        color: Colors.purple,
                                        minHeight: 5,
                                      ))
                                ],
                              ));
                        } else if (snapshot
                                .data["emergency dependees"].length ==
                            0) {
                          return Center(
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 120, right: 20, left: 20),
                                  child: Text(
                                      "No other users have you as an emergency contact.",
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                      textAlign: TextAlign.center)));
                        } else {
                          return ListView.builder(
                              itemCount:
                                  snapshot.data["emergency dependees"].length,
                              itemBuilder: (context, index) {
                                List<EmergencyDependee> emergencyDependee = [];
                                for (var dependee
                                    in snapshot.data["emergency dependees"]) {
                                  var currentDependee = EmergencyDependee(
                                      dependee["nickname"], dependee["email"]);
                                  emergencyDependee.add(currentDependee);
                                }
                                return Dismissible(
                                    key: UniqueKey(),
                                    background: Container(
                                      color: Colors.red[900],
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onDismissed: (direction) async {
                                      await user.update({
                                        "emergency dependees":
                                            FieldValue.arrayRemove([
                                          {
                                            "nickname": emergencyDependee[index]
                                                .nickName,
                                            "email":
                                                emergencyDependee[index].email
                                          }
                                        ])
                                      });
                                    },
                                    child: ExpansionTile(
                                      iconColor: Colors.white,
                                      textColor: Colors.white,
                                      leading: Icon(Icons.person),
                                      title: Text(
                                          emergencyDependee[index].nickName),
                                      subtitle: Text(
                                          "${emergencyDependee[index].email}"),
                                      expandedAlignment: Alignment.center,
                                      children: [
                                        createNickNameSetterWidget(
                                            emergencyDependee[index].email,
                                            emergencyDependee[index].nickName),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            //see gps data button and then
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: ElevatedButton(
                                                    onPressed: () {},
                                                    child: Text("GPS Data"))),
                                          ],
                                        )
                                      ],
                                    ));
                              });
                        }
                      }))
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      var duration = await showDurationPicker(
                          context: context,
                          initialTime: Duration(minutes: 0),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20)));

                      if (duration != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimerRoute(duration)));
                      } else {
                        //they didnt pick a timer
                      }
                    },
                    tooltip: 'Add an Emergency Timer',
                    child: Icon(Icons.alarm_add),
                    heroTag: null,
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    tooltip: 'Add an Emergency Contact',
                    child: Icon(Icons.person_add),
                    heroTag: null,
                  )
                ])));
  }
}
