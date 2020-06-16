import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_compat/torch_compat.dart';
import 'package:shake/shake.dart';
import 'package:firebase_admob/firebase_admob.dart';

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
  BannerAd _bannerAd;

  //AdMob Configuration
//  static const String testDevice = null;
  static const String testDevice = 'MObile_id';
//  static const String testDevice = '40AE2B4B64E7CF94D78A4962C114B9F4';

  //Target info settings
  static const MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
      childDirected: false,
      keywords: keywords,
      testDevices: testDevice != null ? <String>[testDevice] : null,
      contentUrl: 'https://github.com/rafaxzx',
      nonPersonalizedAds: true);

  BannerAd _createBannerAd() {
    return BannerAd(
        //Just for test and didatics :) for me of course
//        adUnitId: BannerAd.testAdUnitId,
        adUnitId: 'ca-app-pub-1146346327158906/9506945152',
        size: AdSize.banner,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print('BannerAd: $event');
        });
  }

  @override
  void initState() {
    //For testing and learning
//    FirebaseAdMob.instance
//        .initialize(appId: BannerAd.testAdUnitId); //code for testing
    //Firebase AdMob start
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-1146346327158906~4676116847');
    //Create, load and show the banner
    _bannerAd = _createBannerAd()
      ..load()
      ..show(anchorType: AnchorType.top, anchorOffset: 120.0);
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
    super.initState();
  }

  @override
  void dispose() {
    detector.stopListening();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("Lanterna Flutter ${_isLightOn ? 'ligada' : 'desligada'}"),
      ),
      backgroundColor: _getColorState(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 120),
                child: IconButton(
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
                        if (_timer != null) {
                          _timer.cancel();
                          _secondsTimer = 0;
                          _isTimerOn = false;
                        }
                      });
                    }),
              ),
              Container(
                child: IconButton(
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
                        _shakeOn
                            ? detector.startListening()
                            : detector.stopListening();
                      });
                    }),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
//                    "Modo agitar: ${_shakeOn ? 'ON' : 'OFF'}",
                    "Modo agitar",
                    style: TextStyle(
                        color: _shakeOn ? Colors.yellow : Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                child: IconButton(
                    padding: EdgeInsets.only(bottom: 0, top: 20),
                    iconSize: 80.0,
                    icon: Icon(
                      Icons.watch_later,
                      size: 80.0,
                      color: _isTimerOn ? Colors.yellow : Colors.black,
                    ),
                    onPressed: () {
                      _secondsTimer = _secondsPreset;
                      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                        if (_secondsTimer > 0) {
                          setState(() {
                            if (_shakeOn) {
                              _shakeOn = false;
                              detector.stopListening();
                            }
                            _isTimerOn = true;
                            if (_secondsPreset == _secondsTimer)
                              _turnOnOffTorch(_isTimerOn);
                            _secondsTimer -= 1;
                          });
                        } else {
                          setState(() {
                            timer.cancel();
                            _timer.cancel();
                            _isTimerOn = false;
                            if (_secondsTimer == 0) _turnOnOffTorch(_isTimerOn);
                            _timer = null;
                          });
                        }
                      });
                    }),
              ),
              Container(
                child: Text(
                  _isTimerOn
                      ? '$_secondsTimer segundos restantes'
                      : 'Temporizador',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                child: DropdownButton(
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
                      child: Text('15 segundos'),
                      value: 15,
                    ),
                    DropdownMenuItem(
                      child: Text('30 segundos'),
                      value: 30,
                    ),
                    DropdownMenuItem(
                      child: Text('1 minuto'),
                      value: 60,
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  static const keywords = [
    'Insurance',
    'Loans',
    'Mortgage',
    'Attorney',
    'Credit',
    'Lawyer',
    'Donate',
    'Degree',
    'Hosting',
    'Claim',
    'Conference Call',
    'Trading',
    'Software',
    'Recovery',
    'Transfer',
    'Gas/Electicity',
    'Classes'
  ];
//  static const keywords2 = [
//    'lanterna',
//    'iluminação',
//    'luz emergencia',
//    'luz emergência',
//    'Insurance',
//    'Loans'
//  ];
}
