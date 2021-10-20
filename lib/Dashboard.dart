import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "emergencyDependee.dart";
import "LoginSignUpForm.dart";

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

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = firestore.collection("users").doc(auth.currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text("Safety Timer Dashboard"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginSignUpForm()));
              },
              icon: Icon(Icons.logout))
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
                  child: Text("PANIC"),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.purple),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
            Expanded(
                child: StreamBuilder(
                    stream: user.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading...");
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data["emergency dependees"].length,
                            itemBuilder: (context, index) {
                              List<EmergencyDependee> emergencyDependee = [];
                              for (var dependee in snapshot.data["emergency dependees"]) {
                                var currentDependee = EmergencyDependee(
                                    dependee["nickname"], dependee["email"]);
                                emergencyDependee.add(currentDependee);
                              }
                              return ListTile(
                                leading: Icon(Icons.perm_identity),
                                title: Text(emergencyDependee[index].nickName),
                                isThreeLine: true,
                                subtitle: Text("${emergencyDependee[index].email}"),
                                onTap: () {
                                  //push new navigation, display gps data if present
                                },
                              );
                            });
                      }
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
