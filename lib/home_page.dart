import 'package:flutter/material.dart';
import 'package:torch_compat/torch_compat.dart';
import 'package:shake/shake.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static bool _isLightOn;
  static bool _shakeOn;
  static double _gravity = 2.5;
  ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    _isLightOn = false;
    _shakeOn = true;
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
    print('>>>>>>>>>>>>>>>>> DETECTOR PAROU DE OUVIR <<<<<<<<<<<<<<<<<<<<');
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
                padding: EdgeInsets.all(20.0),
                iconSize: 80.0,
                icon: Icon(
                  Icons.vibration,
                  size: 80.0,
                  color: _shakeOn ? Colors.yellow : Colors.black,
                ),
                onPressed: () {
                  _shakeOn = !_shakeOn;
                  _shakeOn
                      ? detector.startListening()
                      : detector.stopListening();
                  setState(() {});
                }),
            Text(
              "Shake MODE: ${_shakeOn ? 'ligado' : 'desligado'}",
              style: TextStyle(
                  color: _shakeOn ? Colors.yellow : Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
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

  Color _getColorState() {
    if (_isLightOn) {
      return Colors.blueGrey;
    } else {
      return Colors.grey;
    }
  }
}
