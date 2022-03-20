import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'Services/Notifcation_service.dart';
import 'EmergencyEventTriggered.dart';
import 'DurationPicker.dart';

class TimerRoute extends StatefulWidget {
  final Duration timerDuration;

  TimerRoute([this.timerDuration]);

  @override
  _TimerRoutestate createState() => _TimerRoutestate();
}

class _TimerRoutestate extends State<TimerRoute> {
  Duration _currentTimeLeft;
  Timer _timer;
  int _timerNotificationID = 0;

  @override
  void initState() {
    super.initState();
    _currentTimeLeft = widget.timerDuration;
    startTimer();
  }

  void startTimer() async{
    _timerNotificationID =
        5; //arbitrary, all related timer notifications will be 5

    final prefs = await SharedPreferences.getInstance();
    int timerReminderNotification = prefs.getInt("timerReminderInSeconds");
    if(timerReminderNotification == null){
      timerReminderNotification = 300; //default to 5 minutes if settings havent been changed
    }

    _timer = Timer.periodic(Duration(seconds: 1), (_timer) {
      setState(() {
        _currentTimeLeft -= Duration(seconds: 1);
      });
      if (_currentTimeLeft.inSeconds == 0) {
        loadLocationSubscription();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EmergencyEventTrigger(false)));
        _timer.cancel();
      }
      if (_currentTimeLeft.inSeconds == timerReminderNotification && timerReminderNotification != 0) {
        NotificationService().showNotifications(_timerNotificationID, Duration(seconds: timerReminderNotification));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Timer"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            buildTimer(),
            Padding(
              padding: EdgeInsets.only(top: 125),
              child: ElevatedButton(
                  onPressed: () {
                    //cancel _timer, or check in
                    NotificationService().cancelAllNotifications(
                        _timerNotificationID); 
                    _timer.cancel();
                    Location.instance.enableBackgroundMode(enable: false);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Check In",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, letterSpacing: 0.0),
                    ),
                  )),
            )
          ],
        ),
      )),
    );
  }

  Widget buildTimer() {
    return Stack(children: [
      Center(child:
      Transform.scale(scale: 6, child:
        CircularProgressIndicator(
          value: _currentTimeLeft.inSeconds / widget.timerDuration.inSeconds,
          strokeWidth: 2,
          backgroundColor: Colors.grey,
        ),),),
        Center(
          child: Text(
            "${timerDurationFormat(_currentTimeLeft)}",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ]
    );
  }
}
