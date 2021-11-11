import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Models/UserLocation.dart';
import 'Services/Location_Service.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

class EmergencyEventTrigger extends StatefulWidget {
  @override
  _EmergencyEventTriggerState createState() => _EmergencyEventTriggerState();
}

class _EmergencyEventTriggerState extends State<EmergencyEventTrigger> {
  StreamSubscription<UserLocation> locationSubscription;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    //this will be used for testing later to make sure that we are pulling data correctly, or we might use a streambuilder
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = firestore.collection("users").doc(auth.currentUser.uid);
    locationSubscription =
        LocationService().locationStream.listen((locationData) {
      print(locationData.toString()); //testing stuff
      //firebase uploading
      print("attempted insert");
      user.update({
        "GPS Data": FieldValue.arrayUnion([
          {
            "longitude": locationData.longitude,
            "latitude": locationData.latitude
          }
        ])
      }); //something like this, but we only want to upload on actual changes, so probably do a query first and check retrieved data then upload only if its apropriate
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Emergency!!"),
        ),
        body: SizedBox.shrink());
  }

  @override
  void dispose() {
    //also gets called when us OS back button
    super.dispose();
    locationSubscription.cancel();
  }
}
