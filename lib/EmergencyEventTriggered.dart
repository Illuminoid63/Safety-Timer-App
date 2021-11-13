import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Models/UserLocation.dart';
import 'Services/Location_Service.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class EmergencyEventTrigger extends StatefulWidget {
  @override
  _EmergencyEventTriggerState createState() => _EmergencyEventTriggerState();
}

class _EmergencyEventTriggerState extends State<EmergencyEventTrigger> {
  StreamSubscription<UserLocation> locationSubscription; //make this a private global variable if possible

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() { //NOTE: TRY THIS ON PHONE LATER WITH DRIVE AROUND
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = firestore.collection("users").doc(auth.currentUser.uid);
    locationSubscription =
        LocationService().locationStream.listen((locationData) async {
      var snapshot = await user.get();
      var locationList = snapshot.data()["GPS Data"];
      var distance = Distance();
      double distanceBetween = locationList.length > 0 // in meters
          ? distance(
              LatLng(locationData.latitude, locationData.longitude),
              LatLng(locationList[locationList.length - 1]["latitude"],
                  locationList[locationList.length - 1]["longitude"]))
          : 1000; //if there is nothing uploaded yet, default to large number(in this case 1km) so this new point will be uploaded
      if (distanceBetween >= 30) {
        //throttle uploading, only concerned with new coordinates that are at least 30 meters away from previously uploaded coordinate
        if (locationList.length < 20) {
          //keeping the array a maximum of 50 entries long to save space in case of user error forgetting to turn off emergency event
          user.update({
            "GPS Data": FieldValue.arrayUnion([
              {
                "latitude": locationData.latitude ,
                "longitude": locationData.longitude,
                
              }
            ])
          });
        } else {
          //delete last index, append new data, delete whole list and then upload whole new list in transaction
          await firestore.runTransaction((transaction) async {
            transaction.update(user, {
              "GPS Data": FieldValue.arrayRemove([
                {
                  "latitude": locationList[locationList.length - 1]["latitude"],
                  "longitude": locationList[locationList.length - 1]
                      ["longitude"],
                }
              ])
            });
            transaction.update(user, {
              "GPS Data": FieldValue.arrayUnion([
                {
                  "latitude": locationData.latitude,
                  "longitude": locationData.longitude,
                }
              ])
            });
          });
        }
      }
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
    Location.instance.enableBackgroundMode(enable: false);//cancel backround location after done using it (i.e. on dispose)
  }
}
