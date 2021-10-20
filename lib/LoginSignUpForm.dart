import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "Dashboard.dart";

class LoginSignUpForm extends StatefulWidget {
  @override
  _LoginSignUpFormState createState() => _LoginSignUpFormState();
}

class _LoginSignUpFormState extends State<LoginSignUpForm> {
  String _errorMessage = "";
  String _loginEmail;
  String _loginPassword;
  String _newUserEmail;
  String _newUserPassword;

  Widget createLoginWidgets() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Text("Log into your account",
                style: TextStyle(
                    fontSize: 25.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold)),
            TextFormField(
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
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _loginEmail, password: _loginPassword);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Dashboard()));
                } on FirebaseAuthException catch (e) {
                  if (e.code == "user-not-found") {
                    _errorMessage = "No user found for that email.";
                  } else if (e.code == "wrong-password") {
                    _errorMessage = "Wrong password provided for that user.";
                  }
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text("Log in")),
            ),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ));
  }

  Widget createSignupWidgets() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Text("Your Security is our Priority!",
                style: TextStyle(
                    fontSize: 25.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold)),
            TextFormField(
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
            TextFormField(
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
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _newUserEmail, password: _newUserPassword);
                  /*
                    ToDo:
                      - when a new user is created, add a new document to the actual firstore database with the document id 
                        being the auth's uid(userCredential.user.uid).
                      - also set the document's email field with the entered email, any problems should prolly be caught by the try catch block
                  */
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Dashboard()));
                } on FirebaseAuthException catch (e) {
                  if (e.code == "weak-password") {
                    _errorMessage = "The password provided is too weak.";
                  } else if (e.code == "email-already-in-use") {
                    _errorMessage =
                        "The account already exists for that email.";
                  }
                  setState(() {});
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text("Sign up")),
            ),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ));
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
        ),
        body: TabBarView(
          children: [createLoginWidgets(), createSignupWidgets()],
        ),
      ),
    );
  }
}
