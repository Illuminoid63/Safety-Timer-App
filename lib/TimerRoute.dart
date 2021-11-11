import 'package:flutter/material.dart';
import 'dart:async';
import 'Services/Notifcation_service.dart';

class TimerRoute extends StatefulWidget {
  final Duration timerDuration;

  TimerRoute([this.timerDuration]);

  @override
  _TimerRoutestate createState() => _TimerRoutestate();
}

class _TimerRoutestate extends State<TimerRoute> {
  Duration currentTimeLeft;
  Timer timer;
  int timerNotificationID = 0;

  @override
  void initState() {
    super.initState();
    currentTimeLeft = widget.timerDuration;
    startTimer();
  }

  void startTimer() {
    timerNotificationID =
        5; //arbitrary, all related timer notifications will be 5
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTimeLeft -= Duration(seconds: 1);
      });
      if (currentTimeLeft.inSeconds == 0) {
        //trigger emergency event
        timer.cancel();
      }
      if (currentTimeLeft.inSeconds == (5 * 60) &&
          widget.timerDuration.inMinutes >= 6) {
        //maybe ad functionality to set when reminder goes off in setting route
        //notify that timer will go off in 5 minutes

        NotificationService().showNotifications(timerNotificationID);
      }
    });
  }

  String _printDuration(Duration duration) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTimer(),
            Padding(
              padding: EdgeInsets.all(50),
              child: ElevatedButton(
                  onPressed: () {
                    //cancel timer, or check in
                    NotificationService().cancelAllNotifications(
                        timerNotificationID); //might need to change is we implement more notifications, not sure how this will work with puish notifications later
                    timer.cancel();
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
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(fit: StackFit.expand, children: [
        CircularProgressIndicator(
          value: currentTimeLeft.inSeconds / widget.timerDuration.inSeconds,
          strokeWidth: 10,
          backgroundColor: Colors.grey,
        ),
        Center(
          child: Text(
            "${_printDuration(currentTimeLeft)}",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }
}
