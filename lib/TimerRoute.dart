import 'package:flutter/material.dart';
import 'dart:async';

class TimerRoute extends StatelessWidget {
  final Duration timerDuration;

  TimerRoute(this.timerDuration);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Timer"),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text("Duration Chosen: ${timerDuration.inMinutes} minutes"),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: ElevatedButton(
                  onPressed: () {
                    //cancel timer, or check in
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Check In",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
