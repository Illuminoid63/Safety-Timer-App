import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'Models/UserLocation.dart';
import 'Services/Location_Service.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import "SensitiveGlobals.dart";

class EmergencyEventTrigger extends StatefulWidget {
  final bool _loadOnInit;

  EmergencyEventTrigger(this._loadOnInit);

  @override
  _EmergencyEventTriggerState createState() => _EmergencyEventTriggerState();
}

StreamSubscription<UserLocation> _locationSubscription;

class _EmergencyEventTriggerState extends State<EmergencyEventTrigger> {
  @override
  void initState() {
    super.initState();
    if (widget._loadOnInit) {
      loadLocationSubscription();
    }
  }

  Future<void> _makePhoneCall(String phoneNum) async {
    if (await canLaunch(phoneNum)) {
      await launch(phoneNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Event Triggered"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Uploading GPS data...",
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 70, top: 70),
                child: CircularProgressIndicator(),
              ),
              ElevatedButton(
                  onPressed: () async {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    FirebaseAuth auth = FirebaseAuth.instance;

                    await _locationSubscription.cancel();

                    await _clearGPSPoints(
                        firestore.collection("users").doc(auth.currentUser.uid),
                        firestore);

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Cancel",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.call),
        onPressed: () => _makePhoneCall('tel:911'),
        tooltip: "Call 911",
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    await _locationSubscription.cancel();
    await _clearGPSPoints(
        firestore.collection("users").doc(auth.currentUser.uid), firestore);
    await Location.instance.enableBackgroundMode(enable: false);
  }
}

Future<void> _clearGPSPoints(var user, var firestore) async {
  await firestore.runTransaction((transaction) async {
    //clear array on new triggers
    transaction.update(user, {"GPS Data": FieldValue.delete()});
    transaction.update(user, {"GPS Data": []});
  });
}

void loadLocationSubscription() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  var user = firestore.collection("users").doc(auth.currentUser.uid);
  await _clearGPSPoints(user, firestore);

  //notify emergency contacts of emergency event through sms
  List<String> phoneNumberList = [];
  var userSnapshot = await user.get();
  for (var currentContactID in userSnapshot.data()["emergency contacts"]) {
    var currentContactSnapshot =
        await firestore.collection("users").doc(currentContactID).get();
    phoneNumberList.add(currentContactSnapshot.data()["phoneNumber"]);
  }

  TwilioFlutter twilioFlutter;
  twilioFlutter = TwilioFlutter(
      accountSid: TwilioSID,
      authToken: TwilioAuthToken,
      twilioNumber: TwilioPhoneNumber);
  for (var phoneNumber in phoneNumberList) {
    if(phoneNumber != "none"){
    try {
      await twilioFlutter.sendSMS(
          toNumber: phoneNumber,
          messageBody: 'Safety Timer App: user ' +
              userSnapshot.data()["email"] +
              " has triggered an emergency event.");
    } on Exception catch (e) {
      print("Twilio " + e.toString());
    }
    }
  }

  //uploading gps points
  _locationSubscription =
      LocationService().locationStream.listen((locationData) async {
    var snapshot = await user.get();
    List<UserLocation> locationList = [];
    for (var location in snapshot.data()["GPS Data"]) {
      var currentUserLocation = UserLocation(
          latitude: location["latitude"].toDouble(),
          longitude: location["longitude"].toDouble());
      locationList.add(currentUserLocation);
    }
    var distance = Distance();
    double distanceBetween = locationList.length > 0 // in meters
        ? distance(
            LatLng(locationData.latitude, locationData.longitude),
            LatLng(locationList[locationList.length - 1].latitude,
                locationList[locationList.length - 1].longitude))
        : 1000; //if there is nothing uploaded yet, default to large number(in this case 1km) so this new point will be uploaded
    if (distanceBetween >= 30) {
      //throttle uploading, only concerned with new coordinates that are at least 30 meters away from previously uploaded coordinate
      if (locationList.length < 20) {
        //keeping the array a maximum of 20 entries long to save space in case of user error forgetting to turn off emergency event
        locationList.add(locationData);
        await firestore.runTransaction((transaction) async {
          var userRef = firestore.collection("users").doc(auth.currentUser.uid);
          transaction.update(userRef, {"GPS Data": FieldValue.delete()});
          transaction.update(userRef,
              {"GPS Data": locationList.map((e) => e.toJson()).toList()});
        });
      } else {
        //delete last index, append new data, delete whole list and then upload whole new list in transaction
        locationList.removeAt(locationList.length - 1);
        locationList.add(locationData);
        await firestore.runTransaction((transaction) async {
          var userRef = firestore.collection("users").doc(auth.currentUser.uid);
          transaction.update(userRef, {"GPS Data": FieldValue.delete()});
          transaction.update(userRef,
              {"GPS Data": locationList.map((e) => e.toJson()).toList()});
        });
      }
    }
  });
}
