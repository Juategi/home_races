import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'dart:async';
import 'package:homeraces/model/race_data.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapTravel extends StatefulWidget {
  @override
  _MapTravelState createState() => _MapTravelState();
}

class _MapTravelState extends State<MapTravel> {
  RaceData data;
  Completer<GoogleMapController> _controller = Completer();
  String _mapStyle;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Polyline polyline = Polyline(
    polylineId: PolylineId("poly"),
    color: Color.fromARGB(255, 40, 122, 198),
    points: [],
    width: 5,
  );

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    controller.setMapStyle(_mapStyle);
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(1,1)),
        "assets/competition/point.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(1,1)),
        "assets/competition/point.png");
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('map/map_style.txt').then((string) {
      _mapStyle = string;
    });
    setSourceAndDestinationIcons();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    data = ModalRoute.of(context).settings.arguments;
    if(polyline.points.length == 0){
      for(List<double> pair in data.map){
        polyline.points.add(LatLng(pair.first,pair.last));
      }
      _polylines.add(polyline);
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(data.map.first.first,data.map.first.last),
          icon: destinationIcon
      ));

      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: LatLng(data.map.last.first,data.map.last.last),
          icon: destinationIcon
      ));
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(height: 700.h, child:
        GoogleMap(
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: LatLng(data.map.first.first,data.map.first.last), zoom: 15),
          markers: _markers,
          polylines: _polylines,
        ),
      ),
    );
  }
}
