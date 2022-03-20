import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'Models/emergencyDependee.dart';
import "Dashboard.dart";
import "Services/Location_Service.dart";
import "SensitiveGlobals.dart";
import 'package:twilio_flutter/twilio_flutter.dart';

class LoginSignUpForm extends StatefulWidget {
  @override
  _LoginSignUpFormState createState() => _LoginSignUpFormState();
}

class _LoginSignUpFormState extends State<LoginSignUpForm> {
  String _errorMessage = "";
  String _loginEmail = "";
  String _loginPassword = "";
  String _newUserEmail = "";
  String _newUserPassword = "";
  String _newUserPhoneNumber = "";
  bool _showPhoneNumberForm = true;

  Widget createLoginWidgets() {
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Log into your account",
                      style: Theme.of(context).textTheme.headline5),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    onChanged: (newText) {
                      setState(() {
                        _loginEmail = newText;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Email",
                    ),
                  ),
                ),
                TextFormField(
                  obscureText: true,
                  onChanged: (newText) {
                    setState(() {
                      _loginPassword = newText;
                    });
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Password",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                                email: _loginEmail, password: _loginPassword);
                        askLocationPermission();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == "user-not-found") {
                          _errorMessage = "No user found for that email.";
                        } else if (e.code == "wrong-password") {
                          _errorMessage =
                              "Wrong password provided for that user.";
                        } else if (e.code == "invalid-email") {
                          _errorMessage = "Invalid email";
                        } else {
                          _errorMessage = e.message;
                        }
                        setState(() {});
                      }
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: Text("Log in")),
                  ),
                ),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  Widget createSignupWidgets() {
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Create your Safety Timer account today",
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    onChanged: (newText) {
                      setState(() {
                        _newUserEmail = newText;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "New Account Email",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    obscureText: true,
                    onChanged: (newText) {
                      setState(() {
                        _newUserPassword = newText;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "New Account Password",
                    ),
                  ),
                ),
                _showPhoneNumberForm
                    ? TextFormField(
                        maxLength: 15,
                        keyboardType: TextInputType.phone,
                        onChanged: (newText) {
                          setState(() {
                            _newUserPhoneNumber = newText;
                          });
                        },
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "New Account Phone Number with Country Code"),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 5),
                  child: IconButton(
                      tooltip: "Recieve Text Message Notifications?",
                      color: _showPhoneNumberForm ? Colors.purple : Colors.grey,
                      onPressed: () {
                        setState(() {
                          _showPhoneNumberForm = !_showPhoneNumberForm;
                        });
                      },
                      icon: Icon(Icons.sms)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_showPhoneNumberForm &&
                          _newUserPhoneNumber.length <= 10) {
                        setState(() {
                          _errorMessage =
                              "Either deselect the send text message notification button, or ensure that the phone number entered is correct (requires country code)";
                        });
                        return;
                      }

                      String phoneNumber = _showPhoneNumberForm
                          ? "+" + _newUserPhoneNumber
                          : "none";

                      //catches twilio sms sending exceptions
                      TwilioFlutter twilioFlutter;
                      twilioFlutter = TwilioFlutter(
                          accountSid: TwilioSID,
                          authToken: TwilioAuthToken,
                          twilioNumber: TwilioPhoneNumber);
                      try {
                        await twilioFlutter.sendSMS(
                            toNumber: phoneNumber,
                            messageBody:
                                "Thank you for setting up your Safety Timer Account!");
                      } on Exception catch (e) {
                        print("Twilio " + e.toString());
                      }
                      //alert dialog informing user about test sms
                      bool hitCancel = false;
                      await showDialog(
                          context: context,
                          builder: (value) => AlertDialog(
                                title: Text("Sending Test SMS Message"),
                                content: Text(
                                    "You should recieve a text message to your phone number, if you do not recieve said message, press cancel and  make sure that the phone number you entered is correct."),
                               actions: [
                                 TextButton(onPressed: (){
                                   hitCancel = true;
                                   Navigator.of(context).pop();}, child: Text("CANCEL")),
                                 TextButton(onPressed: (){
                                   hitCancel = false;
                                   Navigator.of(context).pop();}, child: Text("OK"))
                               ],),);
                      if(hitCancel){
                        return;
                      }
                      //catches firebase sign up exceptions
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                                email: _newUserEmail,
                                password: _newUserPassword);

                        FirebaseFirestore firestore =
                            FirebaseFirestore.instance;
                        var user = firestore.collection("users");
                        List<EmergencyDependee> dependees = [];
                        List<String> emergencyContacts = [];
                        List<double> gpsData = [];

                        await user.doc(userCredential.user.uid).set({
                          "email": _newUserEmail,
                          "emergency dependees":
                              dependees.map((item) => item.toJson()).toList(),
                          "GPS Data": gpsData,
                          "emergency contacts": emergencyContacts,
                          "phoneNumber": phoneNumber
                        });
                        askLocationPermission();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == "weak-password") {
                          _errorMessage = "The password provided is too weak.";
                        } else if (e.code == "email-already-in-use") {
                          _errorMessage =
                              "An account already exists for that email.";
                        } else {
                          _errorMessage = e.message;
                        }
                        setState(() {});
                      }
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: Text("Sign up")),
                  ),
                ),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Log in"),
              Tab(text: "Sign up"),
            ],
          ),
          title: Text("Safety Timer App"),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [createLoginWidgets(), createSignupWidgets()],
        ),
      ),
    );
  }
}
