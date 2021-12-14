import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'Services/Notifcation_service.dart';
import 'EmergencyEventTriggered.dart';

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

  void startTimer() {
    _timerNotificationID =
        5; //arbitrary, all related timer notifications will be 5
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
      if (_currentTimeLeft.inSeconds == (5 * 60) &&
          widget.timerDuration.inMinutes >= 5) { //TODO: change this back to 6, but keep it 5 for demoing purposes
        //maybe add functionality to set when reminder goes off in settings route
        NotificationService().showNotifications(_timerNotificationID);
      }
    });
  }

  String _timerDurationFormat(Duration duration) {
    //deals the formatting of the time remaining
    String retval = "";
    if (duration.inHours != 0) {
      retval += "${duration.inHours.toString()}:";
    }
    if (duration.inMinutes != 0 || duration.inHours != 0) {
      int remainder = duration.inMinutes.remainder(60);
      if (remainder == 0) {
        retval += "00:";
      } else if (remainder < 10 && duration.inHours != 0) {
        retval += "0${duration.inMinutes.remainder(60)}:";
      } else {
        retval += "${duration.inMinutes.remainder(60)}:";
      }
    }
    int remainder = duration.inSeconds.remainder(60);
    if (remainder == 0 && (duration.inMinutes != 0 || duration.inHours != 0)) {
      retval += "00";
    } else if (remainder < 10 &&
        (duration.inMinutes != 0 || duration.inHours != 0)) {
      retval += "0${duration.inSeconds.remainder(60)}";
    } else {
      retval += "${duration.inSeconds.remainder(60)}";
    }

    return retval;
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
                      style: Theme.of(context).textTheme.headline5,
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
            "${_timerDurationFormat(_currentTimeLeft)}",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ]
    );
  }
}
