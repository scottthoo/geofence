import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofence/screens/map.dart';
import 'package:geofence/utilities/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:connectivity/connectivity.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Position _position;
  bool isInitPosition = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Check Location Permissions, and get my location
  void _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print('_position : ${_position}');
    setState(() {
      isInitPosition = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00AEFF),
              Color(0xFF0076FF),
            ],
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: (isInitPosition == true)
                      ? RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: kPrimaryColor),
                          ),
                          color: kSecondaryColor,
                          onPressed: () {
                            print('_position 2: ${_position}');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Map(
                                          location: _position,
                                        )));
                          },
                          child: Text(
                            "Let's go!",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
