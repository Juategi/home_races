import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race_data.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:pedometer/pedometer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' show cos, sqrt, asin;

class Race extends StatefulWidget {
  @override
  _RaceState createState() => _RaceState();
}

class _RaceState extends State<Race> {
  User user;
  Competition competition;
  Map<int,int> partials;
  bool init, ended, uploading;
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
  final player = AudioPlayer();
  var duration;
  StreamSubscription<LocationData> locationStream;
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
      points: [],
      width: 5,
  );
  Future _loadAudio() async{
    duration = await player.setAsset("assets/audio/test.mp3");
  }
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
  void maybeStartFGS() async {
    if (!(await ForegroundService.foregroundServiceIsStarted())) {
      await ForegroundService.setServiceIntervalSeconds(5);

      await ForegroundService.notification.startEditMode();

      await ForegroundService.notification
          .setTitle("Compitiendo en Home Races");
      await ForegroundService.notification
          .setText("${competition.name}".toUpperCase());

      await ForegroundService.notification.finishEditMode();

      await ForegroundService.startForegroundService(foregroundServiceFunction);
      await ForegroundService.getWakeLock();
    }

    await ForegroundService.setupIsolateCommunication((data) {
      debugPrint("main received: $data");
    });
  }
  void foregroundServiceFunction() {
    debugPrint("The current time is: ${DateTime.now()}");
    ForegroundService.notification.setText("Distancia: ${kmGPS.toStringAsPrecision(2)}");

    if (!ForegroundService.isIsolateCommunicationSetup) {
      ForegroundService.setupIsolateCommunication((data) {
        debugPrint("bg isolate received: $data");
      });
    }

    ForegroundService.sendToPort("message from bg isolate");
  }



  //Distance & velocity
  double stepMeters;
  double kmGPS;
  double velocity;
  double velocityGPS;
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
  int stepCountValue = 0;
  int stepsInitCount = 0;
  bool stepsInit;
  String pedoError = "";

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
    stepCountValue = newValue - stepsInitCount;
    print('New step count value: $stepCountValue');
  }
  void _onDone() => print("Finished pedometer tracking");
  void _onError(error) => pedoError = error;

  //Cancelar
  BuildContext thisContext;
  bool myInterceptor(bool stopDefaultButtonEvent) {
    if(init){
      _cancelRace();
    }
    return false;
  }
  void _cancelRace()async{
    String result =  await showDialog(
        context: thisContext,
        builder: (BuildContext context){
          return Dialog(
            backgroundColor: Colors.black87,
            child: Container(
              width: 400.w,
              height: 180.h,
              decoration: BoxDecoration(
                  color: Colors.black87,
                  border: Border.all(color: Colors.black87),
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                    topRight: const Radius.circular(20.0),
                    bottomLeft: const Radius.circular(20.0),
                    bottomRight: const Radius.circular(20.0),
                  )
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                      left: 55.w,
                      top: 30.h,
                      child: Container(width: 230.w,child: Text("¿Deseas cancelar la carrera? Se perderá todo el progreso.", maxLines: 3, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: ScreenUtil().setSp(18),)))
                  ),
                  Positioned(
                    left: 25.w,
                    bottom: 20.h,
                    child: RawMaterialButton(
                      child: Text("Aceptar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20,allowFontScalingSelf: true),),),
                      fillColor: Color(0xff61b3d8),
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.only(right: 20.0.w, bottom: 12.0.h,top: 12.0.h,left: 20.w),
                      onPressed: ()async{
                        Navigator.pop(context, "Out");
                      },
                    ),
                  ),
                  Positioned(
                    left: 160.w,
                    bottom: 20.h,
                    child: RawMaterialButton(
                      child: Text("Rechazar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20,allowFontScalingSelf: true),),),
                      fillColor: Color(0xff61b3d8),
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.only(right: 20.0.w, bottom: 12.0.h,top: 12.0.h,left: 20.w),
                      onPressed: (){
                        Navigator.pop(context,"Not");
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
    if(result == "Out"){
      _stopwatch.stop();
      stopListening();
      locationStream.cancel();
      await player.dispose();
      await ForegroundService.stopForegroundService();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() async{
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _getUserLocation();
    _timer();
    rootBundle.loadString('map/map_style.txt').then((string) {
      _mapStyle = string;
    });
    setSourceAndDestinationIcons();
    _loadAudio();
    init = false;
    timer = false;
    stepsInit = false;
    ended = false;
    uploading = false;
    seconds = 0;
    minutes = 0;
    hours = 0;
    stepMeters = 0.0;
    kmGPS = 0.0;
    velocity = 0.0;
    velocityGPS = 0.0;
    km = 1;
    l1 = DateTime.now();
    l2 = DateTime.now();
    partials = {};
    stopwatchTimer  = new Timer.periodic(new Duration(milliseconds: 1000), callback);
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 12000); //interval: 12000,distanceFilter: 30 //10secs
    locationStream = location.onLocationChanged.listen((LocationData currentLocation) async{
      double lastDistance;
      if(init){
        print("Calculating route and distance..");
        if(polyline.points.length == 0)
          polyline.points.add(LatLng(currentLocation.latitude, currentLocation.longitude));
        lastDistance = _calculateDistance(
            polyline.points.last.latitude, polyline.points.last.longitude,
            currentLocation.latitude, currentLocation.longitude);
        if(lastDistance < 0.150){
          kmGPS += lastDistance;
          stepMeters = 0.762 * stepCountValue;
          l1 = DateTime.now();
          velocity = lastDistance/(l1.difference(l2).inMilliseconds/(1000*3600));
          l2 = DateTime.now();
          polyline.points.add(LatLng(currentLocation.latitude, currentLocation.longitude));
          _polylines.clear();
          _polylines.add(polyline);
          velocityGPS = currentLocation.speed;
        }
        if(kmGPS.toInt() == km){
          player.play();
          await player.seek(Duration(seconds: 14));
          if(partials[km] == 0){
            if(km == 1){
              partials[km] = seconds + minutes*60 + hours*3600;
            }
            else{
              int sum = 0;
              for(int i = 1; i <= km-1; i++){
                sum += partials[i];
              }
              partials[km] = (seconds + minutes*60 + hours*3600) - sum;
            }
            km++;
          }
        }
        if(kmGPS.toInt() == competition.distance){
          _stopwatch.stop();
          stopListening();
          locationStream.cancel();
          await player.dispose();
          await _getUserLocation();
          setState(() {
            ended = true;
            _markers.add(Marker(
                markerId: MarkerId('destPin'),
                position: _cameraPosition.target,
                icon: destinationIcon
            ));
          });
          await ForegroundService.stopForegroundService();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    thisContext = context;
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.last;
    if(!init){
      for(int i = 1; i <= competition.distance; i++){
        partials[i] = 0;
      }
    }
    user = args.first;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: init? IconButton(
          icon: Icon(Icons.cancel, color: Colors.red, size: ScreenUtil().setSp(32),),
          onPressed: () {
            _cancelRace();
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
        child: init? uploading? CircularLoading() : Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
          child: RawMaterialButton(
            child: Text("Finalizar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
            fillColor: ended ? Color(0xff61b3d8) : Colors.grey,
            shape: RoundedRectangleBorder(),
            elevation: 0,
            padding: EdgeInsets.only(right: 18.0.w, bottom: 10.0.h,top: 10.0.h,left: 18.w),
            onPressed: ended?()async{
              setState(() {
                uploading = true;
              });
              List<List<double>> map = [];
              for(LatLng element in polyline.points){
                map.add([element.latitude, element.longitude]);
              }
              RaceData raceData = RaceData(
                userid: user.id,
                distance: competition.distance,
                time: (seconds + minutes*60 + hours*3600),
                steps: stepCountValue,
                partials: partials,
                competitionid: competition.id.toString(),
                map: map
              );
              await DBService.dbService.saveRaceData(raceData);
              if(competition.eventdate == null){
                user.tl = null;
              }
              else
                competition.hasRace = true;
              Navigator.pop(context, "Ok");
              //Navigator.popAndPushNamed(context, "/results", arguments: [competition, user]);
            } : null
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
              maybeStartFGS();
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
          Container(height: 320.h, child:
            _cameraPosition == null? CircularLoading() : GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition: _cameraPosition,
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          SizedBox(height: 20.h,),
          //Text(polyline.points.length.toString(), style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(30),),),
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
                    Container(width: 90.w, child: Text("${((velocityGPS)*3600/1000).toStringAsFixed(1)} km/h", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
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
                    //Container(width: 80.w, child: Text("${(stepMeters/1000).toStringAsPrecision(2)} kmST", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
                    Container(width: 80.w, child: Text("${kmGPS.toStringAsPrecision(2)} km", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),)),
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
                Text(stepCountValue.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(20),),),
              ],
            ),
          ),
          Divider(thickness: 2,),
          SizedBox(height: 10.h,),
          Text(competition.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent, fontSize: ScreenUtil().setSp(23),),),
          SizedBox(height: 10.h,),
          Text("OBJETIVO ${competition.distance} KM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(17),),),
        ],
      ),
    );
  }
}
