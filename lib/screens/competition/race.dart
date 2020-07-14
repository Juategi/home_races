import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:pedometer/pedometer.dart';

class Race extends StatefulWidget {
  @override
  _RaceState createState() => _RaceState();
}

class _RaceState extends State<Race> {
  User user;
  Competition competition;
  bool init;

  //Distance & velocity
  double meters;
  double velocity;
  bool timer;

  //Stopwatch
  StopWatchTimer _stopWatchTimer;
  String seconds, minutes, hours;
  int hoursInt;

  void _timerVelocity(){
    if(timer)
      Future.delayed(Duration(seconds: 10)).then((_) async {
        setState(() {
          print("Calculating velocity...");
          velocity = (meters/1000)/(int.parse(seconds) + int.parse(minutes)*60 + hoursInt*3600);
        });
        _timerVelocity();
      });
  }

  //Pedometer
  Pedometer _pedometer;
  StreamSubscription<int> _subscription;
  int _stepCountValue = 0;
  int stepsInitCount = 0;
  bool stepsInit;

  Future<void> initPlatformState() async {
    startListening();
  }
  void startListening() {
    _pedometer = new Pedometer();
    _subscription = _pedometer.pedometerStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: false);
  }
  void stopListening() {
    _subscription.cancel();
  }
  void _onData(int newValue) async {
    print('New step count value: $newValue');
    if(!stepsInit){
      stepsInitCount = newValue;
      stepsInit = true;
    }
    setState(() {
      _stepCountValue = newValue - stepsInitCount;
      meters = 0.762 * _stepCountValue;
    });
  }
  void _onDone() => print("Finished pedometer tracking");
  void _onError(error) => print("Flutter Pedometer Error: $error");

  //cazar el back si se ha iniciado para cancelar carrera y resetar contadores
  @override
  void dispose() async{
    super.dispose();
    await _stopWatchTimer.dispose();
  }
  @override
  void initState() {
    super.initState();
    init = false;
    timer = false;
    stepsInit = false;
    seconds = "00";
    minutes = "00";
    hours = "00";
    hoursInt = 0;
    meters = 0.0;
    velocity = 0.0;
    _stopWatchTimer = StopWatchTimer(
        onChange: (value) {
          setState(() {
            seconds = StopWatchTimer.getDisplayTimeSecond(value);
            minutes = StopWatchTimer.getDisplayTimeMinute(value);
            if(minutes == 60.toString()){
              hoursInt++;
              if(hoursInt.toString().length == 1)
                hours = "0" + hoursInt.toString();
              else
                hours = hoursInt.toString();
            }
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.last;
    user = args.first;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: init? Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
          child: RawMaterialButton(
            child: Text("Finalizar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
            fillColor: Color(0xff61b3d8),
            shape: RoundedRectangleBorder(),
            elevation: 0,
            padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
            onPressed: (){
              _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
              stopListening();
              setState(() {
                init = false;
                timer = false;
                stepsInit = false;
                velocity = 0.0;
                meters = 0.0;
                _stepCountValue = 0;
              });
            },
          ),
        ):
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
          child: RawMaterialButton(
            child: Text("Empezar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
            fillColor: Color(0xff61b3d8),
            shape: RoundedRectangleBorder(),
            elevation: 0,
            padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
            onPressed: (){
              initPlatformState();
              _stopWatchTimer.onExecute.add(StopWatchExecute.start);
              timer = true;
              _timerVelocity();
              setState(() {
                init = true;
              });
            },
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(height: 400.h, color: Colors.yellow,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Row( //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 40.h,
                      width: 40.w,
                      child: SvgPicture.asset(
                        "assets/competition/Tiempo.svg",
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5.h,),
                    Text("Tiempo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: ScreenUtil().setSp(16),),),
                  ],
                ),
                SizedBox(width: 10.w,),
                Container(width: 100.w, child: Text("$hours:$minutes:$seconds", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                SizedBox(width: 10.w,),
                Column(
                  children: <Widget>[
                    Container(
                      height: 40.h,
                      width: 40.w,
                      child: SvgPicture.asset(
                        "assets/competition/Velocidad.svg",
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5.h,),
                    Text("Velocidad", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: ScreenUtil().setSp(16),),),
                  ],
                ),
                SizedBox(width: 10.w,),
                Container(width: 90.w, child: Text("${velocity.toStringAsPrecision(2)} km/h", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
              ],
            ),
          ),
          Divider(thickness: 2,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Row( //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 40.h,
                      width: 40.w,
                      child: SvgPicture.asset(
                        "assets/competition/Distancia.svg",
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5.h,),
                    Text("Distancia", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: ScreenUtil().setSp(16),),),
                  ],
                ),
                SizedBox(width: 10.w,),
                Container(width: 80.w, child: Text("$meters m", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                SizedBox(width: 20.w,),
                Column(
                  children: <Widget>[
                    Container(
                      height: 40.h,
                      width: 40.w,
                      child: SvgPicture.asset(
                        "assets/competition/Pasos.svg",
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5.h,),
                    Text("Pasos", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: ScreenUtil().setSp(16),),),
                  ],
                ),
                SizedBox(width: 20.w,),
                Text(_stepCountValue.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),),
              ],
            ),
          ),
          Divider(thickness: 2,),
        ],
      ),
    );
  }
}
