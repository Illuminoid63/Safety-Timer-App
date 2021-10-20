import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "LoginSignUpForm.dart";
import "Dashboard.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //testing database connection printouts
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore
      .collection("users")
      .orderBy("email", descending: false)
      .get()
      .then((QuerySnapshot snapshot) {
    snapshot.docs.forEach((doc) {
      print(doc["email"]);
      for (var dependee in doc["emergency dependees"]) {
        print(
            "dependee's email: ${dependee["email"]} - dependee's nickname: ${dependee["nickname"]}");
      }
    });
  });

  //testing database connection printouts

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme:
          ThemeData(primarySwatch: Colors.purple, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      return LoginSignUpForm();
    } else {
      return Dashboard();
    }
  }
}
