import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geofence/utilities/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  final Position location;
  Map({this.location});
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Position _locationData;
  Set<Circle> _circles = HashSet<Circle>();
  double radius = 50.0;
  int _circleIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _locationData = widget.location;
    print('_locationData : $_locationData');
  }

  void _setCircles(LatLng point) {
    double distanceInMeters = Geolocator.distanceBetween(_locationData.latitude, _locationData.longitude, point.latitude, point.longitude);
    print('distanceInMeters : $distanceInMeters');

    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    print('Circle | Latitude: ${point.latitude}  Longitude: ${point.longitude}  Radius: $radius');
    _circles.add(Circle(
        circleId: CircleId(circleIdVal),
        center: point,
        radius: radius,
        fillColor: kPrimaryColor.withOpacity(0.2),
        strokeWidth: 3,
        strokeColor: kSecondaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geo-fence'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showRadiusSetting();
        },
        icon: Icon(Icons.radio_button_unchecked_sharp),
        label: Text('Set Radius'),
        backgroundColor: kPrimaryColor,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_locationData.latitude, _locationData.longitude),
              zoom: 16,
            ),
            mapType: MapType.normal,
            circles: _circles,
            myLocationEnabled: true,
            onTap: (point) {
              setState(() {
                _circles.clear();
                _setCircles(point);
              });
            },
          ),
        ],
      ),
    );
  }

  void showRadiusSetting() {
    showDialog(
        context: context,
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Enter radius (m)',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Padding(
              padding: EdgeInsets.all(8),
              child: Material(
                color: Colors.black,
                child: TextField(
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.radio_button_unchecked),
                    hintText: 'Ex: 150',
                    suffixText: 'meters',
                  ),
                  keyboardType: TextInputType.numberWithOptions(),
                  onChanged: (input) {
                    setState(() {
                      radius = double.parse(input);
                    });
                  },
                ),
              )),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  setState(() {
                    _circles.clear();
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Ok',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
        ));
  }
}
