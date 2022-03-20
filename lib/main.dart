import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart";
import "LoginSignUpForm.dart";
import "Dashboard.dart";
import 'Services/Notifcation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkTheme = true;

  @override
  void initState() {
    super.initState();

    loadSharedPreferences();
  }

  void loadSharedPreferences() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkTheme = prefs.getBool("darkTheme");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Timer App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: darkTheme == null || darkTheme ?  Brightness.dark : Brightness.light,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white, backgroundColor: Colors.purple),
        accentColor: Colors.purple,
      ),
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
