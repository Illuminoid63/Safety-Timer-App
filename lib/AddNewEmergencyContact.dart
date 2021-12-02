import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import "Models/NewEmergencyContact.dart";

class AddNewEmergencyContact extends StatefulWidget {
  @override
  _AddNewEmergencyContactState createState() => _AddNewEmergencyContactState();
}

class _AddNewEmergencyContactState extends State<AddNewEmergencyContact> {
  String _newEmergencyContactEmail = "";
  String _currentUserDisplayName = "";
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
        appBar: AppBar(
          title: Text("Add a New Emergency Contact"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                autofocus: true,
                onChanged: (newText) {
                  setState(() {
                    _newEmergencyContactEmail = newText;
                  });
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Emergency Contact's Email",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                autofocus: true,
                onChanged: (newText) {
                  setState(() {
                    _currentUserDisplayName = newText;
                  });
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Your Display Name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if ((await auth.fetchSignInMethodsForEmail(
                                  _newEmergencyContactEmail))
                              .length ==
                          0) {
                        setState(() {
                          _errorMessage = "User Does not Exist";
                        });
                      } else {
                        if (_newEmergencyContactEmail ==
                            auth.currentUser.email) {
                          setState(() {
                            _errorMessage =
                                "Emergency Contacts cannot be yourself";
                          });
                        } else {
                          var newContact = NewEmergencyContact(
                              _currentUserDisplayName,
                              _newEmergencyContactEmail);
                          Navigator.pop(context, newContact);
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == "user-not-found") {
                        _errorMessage = "No user found for that email.";
                      } else if (e.code == "invalid-email") {
                        _errorMessage = "Invalid email";
                      } else {
                        if(e.message == "Given String is empty or null"){
                          _errorMessage = "Emergency contact email must be specified";
                        }else{
                        _errorMessage = e.message;
                        }
                      }
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text("Add Contact"),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
            ),
          ],
        )));
  }
}
