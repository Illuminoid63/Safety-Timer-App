import 'package:capstone/Models/UserLocation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:url_launcher/url_launcher.dart';

class GPSPointList extends StatefulWidget {
  final String dependeeID;
  final String dependeeNickName;
  GPSPointList(this.dependeeID, this.dependeeNickName);

  @override
  _GPSPointListState createState() => _GPSPointListState();
}

class _GPSPointListState extends State<GPSPointList> {
  Future<void> _openPointInMaps(UserLocation point) async {
    String url =
        "https://www.google.com/maps/search/?api=1&query=${point.latitude}%2C${point.longitude}";
    if (await canLaunch(url)) {
      await launch(url);
    }
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
                              latitude: location["latitude"],
                              longitude: location["longitude"]);
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
                SizedBox.shrink()
                //map
              ],
            )));
  }
}
