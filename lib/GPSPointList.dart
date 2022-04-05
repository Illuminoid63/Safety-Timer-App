import 'package:capstone/Models/UserLocation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class GPSPointList extends StatefulWidget {
  final String dependeeID;
  final String dependeeNickName;
  GPSPointList(this.dependeeID, this.dependeeNickName);

  @override
  _GPSPointListState createState() => _GPSPointListState();
}

class _GPSPointListState extends State<GPSPointList> {
  //this stream needs to cancel on disposal of this route, so that the app isn't
  //attempting to aninmate the camera while in the wrong route
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription _dependeeStream;
  bool _dependeeStreamHasData; //deafults to null and that will be loading
  final _markers = Set<Marker>();
  MarkerId _markerId = MarkerId("Most Recent GPS Point"); //use the same marker id for all markers so that there is only one and it moves
  var _carthageCollegePosition = LatLng(42.622987646871, -87.82220003783425);

  static final CameraPosition _carthageCollege = CameraPosition(
    target: LatLng(42.622987646871, -87.82220003783425),
    zoom: 15,
  );

  Future<void> _openPointInMaps(UserLocation point) async {
    String url =
        "https://www.google.com/maps/search/?api=1&query=${point.latitude}%2C${point.longitude}";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _moveToGPSPoint(UserLocation mostRecentLocation) async {
    final GoogleMapController controller = await _controller.future;
    //moves camera to gps point
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(mostRecentLocation.latitude, mostRecentLocation.longitude),
      zoom: 15,
    )));
    //moves marker to gps point
    setState(() {
      _markers.add(Marker(markerId: _markerId, position: LatLng(mostRecentLocation.latitude, mostRecentLocation.longitude)));
    });
  }

  @override
  void initState() {
    super.initState();

    _loadEmbeddedMapStream();
  }

  void _loadEmbeddedMapStream() {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;

    _markers.add(Marker(markerId: _markerId, position: _carthageCollegePosition));

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var dependee = firestore.collection("users").doc(widget.dependeeID);

    _dependeeStream = dependee.snapshots().listen((event) {
      if (event.data()["GPS Data"].length > 0) {
        //condition statement is like this because null is a possible value for _dependeeStreamHasData
        if (_dependeeStreamHasData != true) {
          setState(() {
            _dependeeStreamHasData = true;
          });
        }
        var location =
            event.data()["GPS Data"][event.data()["GPS Data"].length - 1];
        UserLocation mostRecentLocation = UserLocation(
            latitude: location["latitude"].toDouble(),
            longitude: location["longitude"].toDouble());
        _moveToGPSPoint(mostRecentLocation);
      } else {
        setState(() {
          _dependeeStreamHasData = false;
        });
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();

    await _dependeeStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var dependee = firestore.collection("users").doc(widget.dependeeID);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                  "${widget.dependeeNickName + (widget.dependeeNickName.endsWith('s') ? "\'" : "\'s")} GPS Points"),
              centerTitle: true,
              bottom: TabBar(
                tabs: [Tab(text: "GPS Point List"), Tab(text: "Map")],
              ),
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                StreamBuilder(
                    stream: dependee.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return Padding(
                            padding: EdgeInsets.only(bottom: 100),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Loading...",
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 30),
                                    child: LinearProgressIndicator(
                                      color: Colors.purple,
                                      minHeight: 5,
                                    ))
                              ],
                            ));
                      } else if (snapshot.data["GPS Data"].length == 0) {
                        return Center(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: 120, right: 20, left: 20),
                                child: Text(
                                    "${widget.dependeeNickName} currently has no GPS Data.",
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.center)));
                      } else {
                        List<UserLocation> locationList = [];
                        for (var location in snapshot.data["GPS Data"]) {
                          var currentLocation = UserLocation(
                              latitude: location["latitude"].toDouble(),
                              longitude: location["longitude"].toDouble());
                          locationList.add(currentLocation);
                        }
                        return ListView.builder(
                          itemCount: snapshot.data["GPS Data"].length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                  color: Colors.purple,
                                ),
                                title: Text(
                                  "Latitude: ${locationList[index].latitude.toString()}\nLongitude: ${locationList[index].longitude.toString()}",
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward,
                                ),
                                onTap: () =>
                                    _openPointInMaps(locationList[index]));
                          },
                        );
                      }
                    }),
                _dependeeStreamHasData == null
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Loading...",
                              style: Theme.of(context).textTheme.headline3,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 30),
                                child: LinearProgressIndicator(
                                  color: Colors.purple,
                                  minHeight: 5,
                                ))
                          ],
                        ))
                    : _dependeeStreamHasData
                        ? GoogleMap(
                            initialCameraPosition: _carthageCollege,
                            mapType: MapType.normal,
                            onMapCreated: (GoogleMapController controller) {
                              if (!_controller.isCompleted) {
                                _controller.complete(controller);
                              }
                            },
                            markers: _markers,
                          )
                        : Center(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: 120, right: 20, left: 20),
                                child: Text(
                                    "${widget.dependeeNickName} currently has no GPS Data.",
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.center))),
              ],
            )));
  }
}
