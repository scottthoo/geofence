import 'dart:async';
import 'dart:collection';
import 'package:connectivity/connectivity.dart';
import 'package:cross_connectivity/cross_connectivity.dart' hide Connectivity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofence/utilities/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Map extends StatefulWidget {
  final Position location;
  Map({this.location});
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final Connectivity _connectivity = Connectivity();
  Position _locationData;
  Set<Circle> _circles = HashSet<Circle>();
  double radius = 100.0;
  int _circleIdCounter = 1;
  String _connectionStatus = 'Unknown';
  String specificWifiName = 'Specific Wifi Name';
  String connectedWifiName = 'Disconnected';
  bool isInTheZone = false;
  bool isConnectedToSpecificWifi = false;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _locationData = widget.location;
    initConnectivity();
    _getLocalDataWifiName();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) => _getWifiName());
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Geofence',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        actions: [
          GestureDetector(
            onTap: () {
              showChangeSpecificWifi();
            },
            child: Icon(Icons.settings),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      floatingActionButton: buildSetRadiusFloatingActionButton(),
      body: buildMainBody(),
    );
  }

  Stack buildMainBody() {
    return Stack(
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
        SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Center(
              child: ConnectivityBuilder(builder: (context, isConnected, status) {
                return FutureBuilder<String>(
                    future: _connectivity.getWifiName(),
                    builder: (context, snapshot) {
                      List<Widget> children;
                      (snapshot.data == specificWifiName) ? isConnectedToSpecificWifi = true : isConnectedToSpecificWifi = false;
                      if (status != ConnectivityStatus.wifi) isConnectedToSpecificWifi = false;
                      connectedWifiName = snapshot.data ?? '';
                      children = <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 15),
                            Icon(Icons.wifi_lock),
                            SizedBox(width: 8),
                            Text('$specificWifiName'),
                            SizedBox(width: 8),
                            Icon(Icons.link),
                            SizedBox(width: 8),
                            Text(status == ConnectivityStatus.wifi ? connectedWifiName : 'Disconnected'),
                          ],
                        ),
                        SizedBox(width: 15),
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width,
                          color: isInTheZone ? Colors.lightGreenAccent : Colors.yellowAccent,
                          child: Center(
                            child: Text(
                              isInTheZone ? 'IN THE ZONE' : 'NOT IN THE ZONE',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width,
                          color: isConnectedToSpecificWifi ? Colors.lightGreenAccent : Colors.redAccent,
                          child: Center(
                            child: Text(
                              isConnectedToSpecificWifi ? 'INSIDE' : 'OUTSIDE',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        ),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      );
                    });
              }),
            ),
          ),
        ),
      ],
    );
  }

  FloatingActionButton buildSetRadiusFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        showRadiusSetting();
      },
      icon: Icon(Icons.radio_button_unchecked_sharp),
      label: Text('Set Radius'),
      backgroundColor: kPrimaryColor,
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

  void showChangeSpecificWifi() {
    showDialog(
        context: context,
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Change Specific Wifi Name',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Padding(
              padding: EdgeInsets.all(8),
              child: Material(
                color: Colors.black,
                child: TextField(
                  controller: TextEditingController()..text = specificWifiName,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (input) {
                    setState(() {
                      specificWifiName = input;
                    });
                  },
                ),
              )),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('SPECIFIC_WIFI_NAME', specificWifiName);
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

  _getWifiName() async {
    var wifiName = await _connectivity.getWifiName();
    setState(() {
      connectedWifiName = wifiName;
    });
  }

  _getLocalDataWifiName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String prevSpecificWifiName = prefs.getString('SPECIFIC_WIFI_NAME');
    if (prevSpecificWifiName.isEmpty) prevSpecificWifiName = specificWifiName;
    setState(() {
      specificWifiName = prevSpecificWifiName;
    });
  }

  void _setCircles(LatLng point) {
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

    double distanceInMeters = Geolocator.distanceBetween(_locationData.latitude, _locationData.longitude, point.latitude, point.longitude);
    if (distanceInMeters < radius)
      setState(() => isInTheZone = true);
    else
      setState(() => isInTheZone = false);
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        var wifiName = await _connectivity.getWifiName();
        print('android wifi');
        print(wifiName);
        setState(() {
          _connectionStatus = result.toString();
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        print('Disconnected Wifi');
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}
