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
import 'package:location/location.dart';
import 'package:foreground_service/foreground_service.dart';

class MapTravel extends StatefulWidget {
  @override
  _MapTravelState createState() => _MapTravelState();
}

class _MapTravelState extends State<MapTravel> {
  RaceData data;
  Completer<GoogleMapController> _controller = Completer();
  String _mapStyle;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    controller.setMapStyle(_mapStyle);
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('map/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(height: 400.h, child:
        GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          initialCameraPosition: _cameraPosition,
          //markers: _markers,
          polylines: _polylines,
        ),
      ),
    );
  }
}
