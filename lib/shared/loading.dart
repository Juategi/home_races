import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[100],
      child: Center(
        child: SpinKitDualRing(
          color: Colors.lightBlueAccent,
          size: 50.0,
        ),
      ),
    );
  }
}

class CircularLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
          ],
        ),
      ],
    );
  }
}
