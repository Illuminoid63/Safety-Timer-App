import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "emergencyDependee.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //testing database connection printouts
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.collection("users").orderBy("email", descending: false).get().then((QuerySnapshot snapshot){
    snapshot.docs.forEach((doc){
      print(doc["email"]);
      for(var dependee in doc["emergency dependees"]){
        print("dependee's email: ${dependee["email"]} - dependee's nickname: ${dependee["nickname"]}");
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Safety Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<EmergencyDependee> emergencyDependees = [];

  @override
  void initState(){
    super.initState();
    //load(), loads all the emergency dependee list data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: ElevatedButton(
              onPressed: (){//panic button trigger
                print("panic");
              }, 
              child:Padding(child:Text("PANIC"), padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),),
              style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
            Expanded(
              child: ListView.builder(itemCount: emergencyDependees.length, itemBuilder: (context, index){
                return ListTile(
                  leading: Icon(Icons.contact_mail),
                  title: Text(emergencyDependees[index].nickName),
                  onTap: (){//push new navigation, display gps data if present
                  },);
              })
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
