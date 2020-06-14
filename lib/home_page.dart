import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_compat/torch_compat.dart';
import 'package:shake/shake.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Variables
  bool _isLightOn;
  bool _shakeOn;
  bool _isTimerOn;
  int _secondsPreset;
  int _secondsTimer;
  final double _gravity = 2.5;

  ShakeDetector detector;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _isLightOn = false;
    _shakeOn = true;
    _isTimerOn = false;
    _secondsPreset = 15;
    _secondsTimer = _secondsPreset;
    //Function that control the light
    TorchCompat.turnOff();
    detector = ShakeDetector.autoStart(
        shakeThresholdGravity: _gravity,
        onPhoneShake: () {
          _changeTorch();
        });
  }

  @override
  void dispose() {
    super.dispose();
    detector.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("Lanterna ${_isLightOn ? 'ligada' : 'desligada'}"),
      ),
      backgroundColor: _getColorState(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                padding: EdgeInsets.all(20.0),
                iconSize: 80.0,
                icon: Icon(
                  Icons.highlight,
                  size: 80.0,
                  color: _isLightOn ? Colors.yellow : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _changeTorch();
                  });
                }),
            IconButton(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                iconSize: 80.0,
                icon: Icon(
                  Icons.vibration,
                  size: 80.0,
                  color: _shakeOn ? Colors.yellow : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _shakeOn = !_shakeOn;
                    _shakeOn ? detector.startListening() : detector.stopListening();
                  });
                }),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Shake mode: ${_shakeOn ? 'ON' : 'OFF'}",
                style: TextStyle(
                    color: _shakeOn ? Colors.yellow : Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
                padding: EdgeInsets.only(bottom: 0, top: 20),
                iconSize: 80.0,
                icon: Icon(
                  Icons.watch_later,
                  size: 80.0,
                  color: _isTimerOn ? Colors.yellow : Colors.black,
                ),
                onPressed: () {
                  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                    if (_secondsTimer > 0) {
                      setState(() {
                        _isTimerOn = true;
                        if (_secondsPreset == _secondsTimer) _turnOnOffTorch(_isTimerOn);
                        _secondsTimer -= 1;
                      });
                    } else {
                      _timer.cancel();
                      setState(() {
                        _isTimerOn = false;
                        if (_secondsTimer == 0) _turnOnOffTorch(_isTimerOn);
                      });
                    }
                  });
                }),
            Text(
              _isTimerOn ? '$_secondsTimer seconds remaining' : 'Timer',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton(
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              value: _secondsPreset,
              onChanged: (value) {
                setState(() {
                  _secondsPreset = value;
                });
              },
              items: <DropdownMenuItem>[
                DropdownMenuItem(
                  child: Text('15 seconds'),
                  value: 15,
                ),
                DropdownMenuItem(
                  child: Text('30 seconds'),
                  value: 30,
                ),
                DropdownMenuItem(
                  child: Text('1 minute'),
                  value: 60,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _changeTorch() {
    setState(() {
      _isLightOn ? TorchCompat.turnOff() : TorchCompat.turnOn();
      _isLightOn = !_isLightOn;
    });
  }

  void _turnOnOffTorch(bool command) {
    if (command) {
      TorchCompat.turnOn();
      _isLightOn = true;
    } else {
      TorchCompat.turnOff();
      _isLightOn = false;
    }
  }

  Color _getColorState() {
    if (_isLightOn) {
      return Colors.blueGrey;
    } else {
      return Colors.grey;
    }
  }
}
