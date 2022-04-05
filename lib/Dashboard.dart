import 'package:capstone/GPSPointList.dart';
import 'package:location/location.dart';
import 'AddNewEmergencyContact.dart';
import 'EmergencyEventTriggered.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'Models/emergencyDependee.dart';
import "LoginSignUpForm.dart";
import 'DurationPicker.dart';
import 'TimerRoute.dart';
import "Services/Location_Service.dart";
import "Settings.dart" as mySettings;

//consider refactoring all database logic into singleton class (similar to Notification_service)

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget createNickNameSetterWidget(
      String email, String oldNickName, String uid) {
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

                //this runs the following updates in a transaction, meaning in a single atomic step,
                //so that we don't need a loading screen
                await firestore.runTransaction((transaction) async {
                  var user =
                      firestore.collection("users").doc(auth.currentUser.uid);

                  transaction.update(user, {
                    "emergency dependees": FieldValue.arrayRemove([
                      {"nickname": oldNickName, "email": email, "uid": uid}
                    ])
                  });
                  transaction.update(user, {
                    "emergency dependees": FieldValue.arrayUnion([
                      {"nickname": _newNickname, "email": email, "uid": uid}
                    ])
                  });
                });
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => mySettings.Settings()));

                //im thinking gps granularity maybe displayed to the user as data usage so its easier for them to understand
                  //this would be a slider between low medium and high with high gps usage having high granularity
                //maybe a way to manage emergency contacts
                //setting to toggle between clear gps cache on cancel vs on new event
                  //store previous gps points between emergency events
                //also delete account with alert dialog/box making sure they want to delete
                  //if they can delete their account then need to add error checking when an emergency contact tries to look at their data but their account is deleted (i.e. their document has been deleted)
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
                  onPressed: () async {
                    int permissionReturn = await askLocationPermission();
                    if (permissionReturn == 1) {
                      //true if user denied any location permissions
                      await _deniedLocationServiceDialog();
                    } else {
                      if (permissionReturn == 2) {
                        //true if user denied background location permissions specifically, app gps uploading still works, but not as well
                        await _deniedBackgroundLocationServiceDialog();
                      }
                      //push emergency route
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EmergencyEventTrigger(true)));
                    }
                  },
                  child: Padding(
                    child: Text(
                      "PANIC",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.0),
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
                          List<EmergencyDependee> emergencyDependee = [];
                          for (var dependee
                              in snapshot.data["emergency dependees"]) {
                            var currentDependee = EmergencyDependee(
                                dependee["nickname"],
                                dependee["email"],
                                dependee["uid"]);
                            emergencyDependee.add(currentDependee);
                          }
                          return ListView.builder(
                              itemCount:
                                  snapshot.data["emergency dependees"].length,
                              itemBuilder: (context, index) {
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
                                      var deletedUser = firestore
                                          .collection("users")
                                          .doc(emergencyDependee[index].uid);
                                      await firestore
                                          .runTransaction((transaction) async {
                                        transaction.update(user, {
                                          "emergency dependees":
                                              FieldValue.arrayRemove([
                                            {
                                              "nickname":
                                                  emergencyDependee[index]
                                                      .nickName,
                                              "email": emergencyDependee[index]
                                                  .email,
                                              "uid":
                                                  emergencyDependee[index].uid
                                            }
                                          ])
                                        });
                                        transaction.update(deletedUser, {
                                          "emergency contacts":
                                              FieldValue.arrayRemove(
                                                  [auth.currentUser.uid])
                                        });
                                      });
                                    },
                                    child: ExpansionTile(
                                      leading: Icon(Icons.person),
                                      title: Text(
                                          emergencyDependee[index].nickName),
                                      subtitle: Text(
                                          "${emergencyDependee[index].email}"),
                                      expandedAlignment: Alignment.center,
                                      children: [
                                        createNickNameSetterWidget(
                                            emergencyDependee[index].email,
                                            emergencyDependee[index].nickName,
                                            emergencyDependee[index].uid),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 15, bottom: 15),
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => GPSPointList(
                                                                  emergencyDependee[
                                                                          index]
                                                                      .uid,
                                                                  emergencyDependee[
                                                                          index]
                                                                      .nickName)));
                                                    },
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
                      int permissionReturn = await askLocationPermission();
                      if (permissionReturn == 1) {
                        //true if user denied all location permissions, thus gps uploading impossible
                        await _deniedLocationServiceDialog();
                      } else {
                        if (permissionReturn == 2) {
                          //true if user denied specifically background location permissions, still possible but does work as well
                          await _deniedBackgroundLocationServiceDialog();
                        }
                        Duration timerDuration = await pickDuration(
                            context, "Enter Timer Duration"); //in DurationPicker.dart, I felt it was too big and cluttering this file too much
                        if (timerDuration == null) {
                          //disable background service if we dont start timer
                          Location.instance.enableBackgroundMode(enable: false);
                        } else {
                          //this is required if user hits cancel, because then nothing is returned
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TimerRoute(timerDuration)));
                        }
                      }
                    },
                    tooltip: 'Add an Emergency Timer',
                    child: Icon(Icons.alarm_add),
                    heroTag: null,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      var newContact = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddNewEmergencyContact()));
                      if (newContact != null) {
                        var insertingEmergencyDependee = EmergencyDependee(
                            newContact.currentUserDisplayName,
                            auth.currentUser.email,
                            auth.currentUser.uid);
                        await firestore
                            .collection("users")
                            .where("email", isEqualTo: newContact.email)
                            .get()
                            .then((value) async {
                          var emergencyContactID = value.docs.first
                              .id; //should only be one user because emails are unique
                          var emergencyContact = firestore
                              .collection("users")
                              .doc(emergencyContactID);

                          await firestore.runTransaction((transaction) async {
                            //adding current user to emergency contact's dependee list
                            transaction.update(emergencyContact, {
                              "emergency dependees": FieldValue.arrayUnion(
                                  [insertingEmergencyDependee.toJson()])
                            });

                            //adding emergency contact's uid to current user's contacts list
                            var currentUser = firestore
                                .collection("users")
                                .doc(auth.currentUser.uid);
                            transaction.update(currentUser, {
                              "emergency contacts":
                                  FieldValue.arrayUnion([value.docs.first.id])
                            });
                          });
                        });
                      }
                    },
                    tooltip: 'Add an Emergency Contact',
                    child: Icon(Icons.person_add),
                    heroTag: null,
                  )
                ])));
  }

  Future<void> _deniedLocationServiceDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Enable Location Service"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              content: Text(
                  "Location permission is required for the panic button and emergency timer to work."),
              actions: [
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 17, color: Colors.purple[400]),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }

  Future<void> _deniedBackgroundLocationServiceDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Enable Backgorund Location Service"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              content: Text(
                  "It is highly reccomended to allow location permission all the time for this app to work as intended."),
              actions: [
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 17, color: Colors.purple[400]),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }
}
