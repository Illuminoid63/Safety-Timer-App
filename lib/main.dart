import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart";
import "LoginSignUpForm.dart";
import "Dashboard.dart";
import 'Services/Notifcation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp(); 
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Timer App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white, backgroundColor: Colors.purple),
        accentColor: Colors.purple,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,//change to false when during final demo
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
