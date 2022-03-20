import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'DurationPicker.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //SMS notification data
  bool useSMSNotification = false;
  String currentUserPhoneNumber = "";
  String phoneNumberBuffer = "";
  String newUserPhoneNumber = "";

  //dark theme data
  bool darkTheme = true;
  bool darkThemeOriginalValue;

  //notification data
  bool timerNotification = true;
  Duration durationBeforeTimerEndNotification = Duration();

  @override
  void initState() {
    super.initState();

    loadInPhoneNumberAndSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "Dark Theme",
                  style: TextStyle(fontSize: 17),
                ),
                subtitle: Text(darkTheme ? "On" : "Off"),
                trailing: Switch(
                    value: darkTheme,
                    activeColor: Colors.purple,
                    onChanged: (newBool) {
                      setState(() {
                        darkTheme = newBool;
                      });
                    }),
              ),
              ListTile(
                title: Text(
                  "Enable SMS Notifications",
                  style: TextStyle(fontSize: 17),
                ),
                subtitle: Text(useSMSNotification
                    ? currentUserPhoneNumber == "none"
                        ? currentUserPhoneNumber
                        : currentUserPhoneNumber.substring(
                                1) 
                    : "Off"),
                trailing: Switch(
                    value: useSMSNotification,
                    activeColor: Colors.purple,
                    onChanged: (newBool) {
                      setState(() {
                        useSMSNotification = newBool;
                      });
                      if (useSMSNotification) {
                        showPhoneNumberPicker();
                      }
                    }),
                onTap: () {
                  if (useSMSNotification) {
                    showPhoneNumberPicker();
                  }
                },
              ),
              ListTile(
                title: Text(
                  "Enable Timer Reminder",
                  style: TextStyle(fontSize: 17),
                ),
                subtitle: Text(timerNotification ? timerDurationFormat(durationBeforeTimerEndNotification) : "Off"),
                trailing: Switch(
                    value: timerNotification,
                    activeColor: Colors.purple,
                    onChanged: (newBool) async {
                      setState(() {
                        timerNotification = newBool;
                      });
                      if (timerNotification) {
                        Duration userInputNullChecker = await pickDuration(context, "Set Reminder Duration");
                        if(userInputNullChecker != null){
                          setState(() {
                            durationBeforeTimerEndNotification = userInputNullChecker;
                          });
                        }
                      }
                    }),
                onTap: () async {
                  if (timerNotification) {
                    Duration userInputNullChecker = await pickDuration(context, "Set Reminder Duration");
                    if(userInputNullChecker != null){
                      setState(() {
                        durationBeforeTimerEndNotification = userInputNullChecker;
                      });
                    }
                  }
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    FirebaseAuth auth = FirebaseAuth.instance;

                    var user =
                        firestore.collection("users").doc(auth.currentUser.uid);

                    //recieve SMS Notifications
                    if (useSMSNotification) {
                      String phoneNumber = newUserPhoneNumber == ""
                          ? currentUserPhoneNumber
                          : "+" + newUserPhoneNumber;

                      await user.update({"phoneNumber": phoneNumber});
                    } else {
                      await user.update({"phoneNumber": "none"});
                    }
                    //recieve SMS Notifications

                    //timer reminder notification
                    final prefs = await SharedPreferences.getInstance();
                    if(timerNotification){
                      await prefs.setInt("timerReminderInSeconds", durationBeforeTimerEndNotification.inSeconds);
                    }
                    else{
                      await prefs.setInt("timerReminderInSeconds", 0); //zero means they dont want the reminder
                    }
                    //timer reminder notification

                    //dark theme (keep at the end of here, apply all other settings first)
                    if (darkTheme != darkThemeOriginalValue) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("darkTheme", darkTheme);
                      //show alert dialog saying app needs relaunch for changes to take effect
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Restart Needed"),
                              content: Text(
                                  "Restart Application for settings changes to take effect."),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("OK"))
                              ],
                            );
                          });
                    }
                    //dark theme

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text("Apply Settings")),
            ],
          ),
        ));
  }

  void showPhoneNumberPicker() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Phone Number with Country Code"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            content: TextFormField(
              maxLength: 15,
              keyboardType: TextInputType.phone,
              onChanged: (newText) {
                phoneNumberBuffer = newText;
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Enter New Phone Number"),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 17, color: Colors.purple[400]),
                  textAlign: TextAlign.end,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 17, color: Colors.purple[400]),
                  textAlign: TextAlign.end,
                ),
                onPressed: () {
                  newUserPhoneNumber = phoneNumberBuffer;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void loadInPhoneNumberAndSharedPreferences() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    var user = firestore.collection("users").doc(auth.currentUser.uid);
    var currentUserSnapshot = await user.get();
    currentUserPhoneNumber = currentUserSnapshot.data()["phoneNumber"];

    if (currentUserPhoneNumber == "none" || currentUserPhoneNumber == "") {
      setState(() {
        useSMSNotification = false;
      });
    } else {
      setState(() {
        useSMSNotification = true;
      });
    }

    //shared preferences
    final prefs = await SharedPreferences.getInstance();

    bool darkThemeNullChecker = prefs.getBool("darkTheme");
    //null means the key "darkTheme" hasn't been stored yet, thus we are defaulting to dark theme
    if (darkThemeNullChecker == null || darkThemeNullChecker) {
      setState(() {
        darkTheme = true;
      });
    } else {
      setState(() {
        darkTheme = false;
      });
    }
    darkThemeOriginalValue = darkTheme;

    int timerReminderNullChecker = prefs.getInt("timerReminderInSeconds");
    //default to 5 mins if it hasn't been set yet
    if (timerReminderNullChecker == null) {
      setState(() {
        durationBeforeTimerEndNotification = Duration(minutes: 5);
        timerNotification = true;
      });
    } else if (timerReminderNullChecker != 0) {
      setState(() {
        durationBeforeTimerEndNotification = Duration(seconds: timerReminderNullChecker);
        timerNotification = true;
      });
    } else { //zero is the value if the reminder is turned off
      setState(() {
        durationBeforeTimerEndNotification = Duration();
        timerNotification = false;
      });
    }
  }
}
