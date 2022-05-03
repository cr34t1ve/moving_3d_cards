import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StackTest(),
    );
  }
}

class StackTest extends StatefulWidget {
  const StackTest({ Key? key }) : super(key: key);

  @override
  State<StackTest> createState() => _StackTestState();
}

class _StackTestState extends State<StackTest> {
  // event returned from accelerometer stream
  AccelerometerEvent? event;

  // hold a refernce to these, so that they can be disposed
  Timer? timer;
  StreamSubscription? accel;

  // positions and count
  double top = 125;
  double top2 = 125;
  double top3 = 125;
  int? left;
  int? secondLeft;
  int? thirdLeft;
  int count = 0;

  // variables for screen size
  double? width;
  double? height;

  int rangeMapping(
      int input, int inputStart, int inputEnd, int outputStart, int outputEnd) {
    int output = (outputStart +
            ((outputEnd - outputStart) / (inputEnd - inputStart)) *
                (input - inputStart))
        .toInt();
    return output;
  }

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    // When x = 0 it should be centered horizontally
    // The left positin should equal (width - 100) / 2
    // The greatest absolute value of x is 10, multipling it by 12 allows the left position to move a total of 120 in either direction.
    setState(() {
      left = ((event.x * 1) + ((width! - 200) / 2)).round();
      secondLeft = ((event.x * 2) + ((width! - 200) / 2)).round();
      thirdLeft = ((event.x * 3) + ((width! - 200) / 2)).round();
    });

    // When y = 0 it should have a top position matching the target, which we set at 125
    setState(() {
      top = event.y * 1 + 200;
      top2 = event.y * 2 + 200;
      top3 = event.y * 3 + 200;
    });
  }

  startTimer() {
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (accel == null) {
      accel = accelerometerEvents.listen((AccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      // it has already ben created so just resume it
      accel!.resume();
    }

    // Accelerometer events come faster than we need them so a timer is used to only proccess them every 200 milliseconds
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 0), (_) {
        // if count has increased greater than 3 call pause timer to handle success
        if (count > 3) {
          // pauseTimer();
        } else {
          // proccess the current event
          // setColor(event!);
          setPosition(event!);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    accel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
          right: thirdLeft!.toDouble(),
          top: top3,
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.pink.shade200.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Stocks & Crypto",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 22),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: secondLeft!.toDouble(),
          top: top2,
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Stocks & Crypto",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 22),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: left!.toDouble(),
          top: top,
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Stocks & Crypto",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 22),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(event!.x.toStringAsFixed(3))],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(left.toString())],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(top.toString())],
            )
          ],
        )
      ],
    )
    );
  }
}