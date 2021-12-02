import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String _add(String strToAddTo, String additive) {
  //this is how I add digits to the end of the string while popping the front of the string so that str.length == 6
  for (int i = 0; i < additive.length; i++) {
    strToAddTo = strToAddTo.substring(1, strToAddTo.length);
  }
  strToAddTo += additive;
  return strToAddTo;
}

Widget _digitButtonBuilder(String digit, var updateTimeDurationStr,
    var setState, BuildContext context) {
  //made this so I didn't have to repeat code below 12 times inside a gridview
  return RawMaterialButton(
    onPressed: () {
      updateTimeDurationStr(digit, setState);
    },
    shape: CircleBorder(),
    elevation: 2.0,
    fillColor: Theme.of(context).scaffoldBackgroundColor,
    padding: EdgeInsets.all(15),
    child: Text(
      digit,
      style: TextStyle(fontSize: 40),
    ),
  );
}

Future<Duration> pickDuration(BuildContext context) {
  String timeDurationStr = "000000";
  String errorText = "";

  void updateTimeDurationStr(String digit, var setState) {
    //used to reference timeDurationStr and setState, called in digitButtonBuilder
    setState(() {
      timeDurationStr = _add(timeDurationStr, digit);
    });
  }

  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          //stateful so I can update timer duration text as user enters digits
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            title: Text("Enter Timer Duration"),
            content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: EdgeInsets.only(bottom: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          timeDurationStr.substring(0, 2),
                          style: TextStyle(fontSize: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "h",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          timeDurationStr.substring(2, 4),
                          style: TextStyle(fontSize: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "m",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          timeDurationStr.substring(4, 6),
                          style: TextStyle(fontSize: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "s",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    _digitButtonBuilder(
                        "1", updateTimeDurationStr, setState, context),
                    _digitButtonBuilder(
                        "2", updateTimeDurationStr, setState, context),
                    _digitButtonBuilder(
                        "3", updateTimeDurationStr, setState, context),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    _digitButtonBuilder(
                        "4", updateTimeDurationStr, setState, context),
                    _digitButtonBuilder(
                        "5", updateTimeDurationStr, setState, context),
                    _digitButtonBuilder(
                        "6", updateTimeDurationStr, setState, context),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    _digitButtonBuilder(
                        "7", updateTimeDurationStr, setState, context),
                    _digitButtonBuilder(
                        "8", updateTimeDurationStr, setState, context),
                    _digitButtonBuilder(
                        "9", updateTimeDurationStr, setState, context),
                  ],
                ),
              ),
              Row(
                children: [
                  _digitButtonBuilder(
                      "00", updateTimeDurationStr, setState, context),
                  _digitButtonBuilder(
                      "0", updateTimeDurationStr, setState, context),
                  RawMaterialButton(
                    onPressed: () {
                      String newTimerStr = "0";
                      timeDurationStr = timeDurationStr.substring(
                          0, timeDurationStr.length - 1);
                      newTimerStr += timeDurationStr;
                      setState(() {
                        timeDurationStr = newTimerStr;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        timeDurationStr = "000000";
                      });
                    },
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.purple,
                    padding: EdgeInsets.all(27),
                    child: Icon(Icons.backspace),
                  ),
                ],
              ),
              errorText != "" ?
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                    child: Text(
                  errorText,
                  style: TextStyle(color: Colors.red),
                )),
              ) : SizedBox.shrink(),
            ])),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 17, color: Colors.purple[400]),
                  textAlign: TextAlign.end,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 17, color: Colors.purple[400]),
                  textAlign: TextAlign.end,
                ),
                onPressed: () {
                  int durationInHours =
                      int.parse(timeDurationStr.substring(0, 2));
                  int durationInMinutes =
                      int.parse(timeDurationStr.substring(2, 4));
                  int durationInSeconds =
                      int.parse(timeDurationStr.substring(4, 6));
                  Duration timerDuration = Duration(
                      hours: durationInHours,
                      minutes: durationInMinutes,
                      seconds: durationInSeconds);
                  if (timerDuration.inSeconds == 0 || timerDuration == null) {
                    setState(() {
                      errorText = "Timer can't be 0 seconds";
                    });
                  } else {
                    Navigator.of(context).pop(timerDuration);
                  }
                },
              ),
            ],
          ),
        );
      });
}
