import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:pedometer/pedometer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

class Race extends StatefulWidget {
  @override
  _RaceState createState() => _RaceState();
}

class _RaceState extends State<Race> {
  User user;
  Competition competition;
  Map<int,int> partials;
  bool init;
  int km;

  void _timer() {
    if(_cameraPosition == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading map...");
        });
        _timer();
      });
    }
  }

  //Map
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  Timer bitRate;
  String _mapStyle;
  CameraPosition _cameraPosition;
  Set<Marker> _markers = {};
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  //PolylinePoints polylinePoints = PolylinePoints();
  //List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Polyline polyline = Polyline(
      polylineId: PolylineId("poly"),
      color: Color.fromARGB(255, 40, 122, 198),
      points: []
  );
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    controller.setMapStyle(_mapStyle);
  }
  void _getUserLocation() async{
    geo.Position position = await geo.Geolocator().getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);
    if(position == null)
      position = await geo.Geolocator().getLastKnownPosition(desiredAccuracy: geo.LocationAccuracy.high);
    _cameraPosition = CameraPosition(
      target: LatLng(position.latitude,position.longitude),
      zoom: 16,
    );
  }
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(1,1)),
        "assets/competition/point.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(1,1)),
        "assets/competition/point.png");
  }
  double _calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  //Distance & velocity
  double stepMeters;
  double kmGPS;
  double velocity;
  double velocityGPS;
  double velocitySteps;
  bool timer;
  DateTime l1,l2;

  //Stopwatch
  Stopwatch _stopwatch = Stopwatch();
  Timer stopwatchTimer;
  int seconds, minutes, hours;
  String textTime = "00:00:00";
  void callback(Timer timer) {
    if (_stopwatch.isRunning) {
      double totalSeconds = _stopwatch.elapsedMilliseconds/1000;
      hours = totalSeconds~/3600;
      minutes = (totalSeconds%3600)~/60;
      seconds = ((totalSeconds%3600)%60).toInt();
      setState(() {
        textTime = "${hours.toString().length == 1? "0"+hours.toString() : hours}:"
            "${minutes.toString().length == 1? "0"+minutes.toString() : minutes}:"
            "${seconds.toString().length == 1? "0"+seconds.toString() : seconds}";
      });
    }
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
    if(!stepsInit){
      stepsInitCount = newValue;
      stepsInit = true;
    }
    _stepCountValue = newValue - stepsInitCount;
    print('New step count value: $_stepCountValue');
  }
  void _onDone() => print("Finished pedometer tracking");
  void _onError(error) => print("Flutter Pedometer Error: $error");

  //cazar el back si se ha iniciado para cancelar carrera y resetar contadores y el timer

  @override
  void dispose() async{
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _timer();
    rootBundle.loadString('map/map_style.txt').then((string) {
      _mapStyle = string;
    });
    setSourceAndDestinationIcons();
    init = false;
    timer = false;
    stepsInit = false;
    seconds = 0;
    minutes = 0;
    hours = 0;
    stepMeters = 0.0;
    kmGPS = 0.0;
    velocity = 0.0;
    velocityGPS = 0.0;
    velocitySteps = 0.0;
    km = 1;
    l1 = DateTime.now();
    l2 = DateTime.now();
    partials = {};
    stopwatchTimer  = new Timer.periodic(new Duration(milliseconds: 1000), callback);
    location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 10); //interval: 1000,
    location.onLocationChanged.listen((LocationData currentLocation) {
      if(init){
        print("Calculating route and distance..");
        try {
          double lastDistance = _calculateDistance(
              polyline.points.last.latitude, polyline.points.last.longitude,
              currentLocation.latitude, currentLocation.longitude);
          kmGPS += lastDistance;
          stepMeters = 0.762 * _stepCountValue;
          l1 = DateTime.now();
          velocity = lastDistance/(l1.difference(l2).inMilliseconds/(1000*3600));
          velocitySteps = stepMeters/(l1.difference(l2).inMilliseconds/(1000*3600));
          l2 = DateTime.now();
        }catch(e){
          print("Primer calculo error");
        }
        polyline.points.add(LatLng(currentLocation.latitude, currentLocation.longitude));
        _polylines.clear();
        _polylines.add(polyline);
        velocityGPS = currentLocation.speed;
        if(kmGPS.toInt() == km){
          if(partials[km] == 0){
            if(km == 1){
              partials[km] = seconds + minutes*60 + hours*3600;
            }
            else{
              partials[km] = (seconds + minutes*60 + hours*3600) - partials[km-1];
            }
            km++;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.last;
    if(!init){
      for(int i = 1; i <= competition.distance; i++){
        partials[i] = 0;
      }
      print(partials);
    }
    user = args.first;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: init? IconButton(
          icon: Icon(Icons.cancel, color: Colors.red, size: ScreenUtil().setSp(32),),
          onPressed: () {

          },
        ) : IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          SizedBox(width: 10.w)
        ],
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: init? Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
          child: Row(
            children: <Widget>[
              RawMaterialButton(
                child: Text("Finalizar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
                fillColor: Color(0xff61b3d8),
                shape: RoundedRectangleBorder(),
                elevation: 0,
                padding: EdgeInsets.only(right: 18.0.w, bottom: 10.0.h,top: 10.0.h,left: 18.w),
                onPressed: ()async{
                  _stopwatch.stop();
                  stopListening();
                  _getUserLocation();
                  setState(() {
                    init = false;
                    timer = false;
                    stepsInit = false;
                    velocity = 0.0;
                    stepMeters = 0.0;
                    _stepCountValue = 0;
                    _markers.add(Marker(
                        markerId: MarkerId('destPin'),
                        position: _cameraPosition.target,
                        icon: destinationIcon
                    ));
                  });
                },
              ),
              RawMaterialButton(
                child: Text("P", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
                fillColor: Color(0xff61b3d8),
                shape: RoundedRectangleBorder(),
                elevation: 0,
                padding: EdgeInsets.only(right: 18.0.w, bottom: 10.0.h,top: 10.0.h,left: 18.w),
                onPressed: ()async{

                },
              ),
            ],
          ),
        ):
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
          child: RawMaterialButton(
            child: Text("Empezar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
            fillColor: Color(0xff61b3d8),
            shape: RoundedRectangleBorder(),
            elevation: 0,
            padding: EdgeInsets.only(right: 18.0.w, bottom: 10.0.h,top: 10.0.h,left: 18.w),
            onPressed: ()async{
              initPlatformState();
              _stopwatch.start();
              timer = true;
              _getUserLocation();
              setState(() {
                init = true;
                _markers.add(Marker(
                    markerId: MarkerId('sourcePin'),
                    position: _cameraPosition.target,
                    icon: sourceIcon
                ));
              });
            },
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(height: 300.h, child:
            _cameraPosition == null? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
              ],) : GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition: _cameraPosition,
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Container(
            child: Text(partials.toString(), style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(16),),),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 20.w),
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
                Container(width: 100.w, child: Text(textTime, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
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
                Column(
                  children: <Widget>[
                    Container(width: 90.w, child: Text("${velocity.toStringAsFixed(1)} km/hMAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                    Container(width: 90.w, child: Text("${((velocityGPS)*3600/1000).toStringAsFixed(1)} km/hGPS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                    Container(width: 90.w, child: Text("${((velocitySteps)/1000).toStringAsFixed(1)} km/hST", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 2,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 20.w),
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
                Column(
                  children: <Widget>[
                    Container(width: 80.w, child: Text("${(stepMeters/1000).toStringAsPrecision(2)} kmST", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                    Container(width: 80.w, child: Text("${kmGPS.toStringAsPrecision(2)} kmGPS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                  ],
                ),
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
