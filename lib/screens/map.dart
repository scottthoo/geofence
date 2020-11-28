import 'dart:collection';
import 'package:connectivity/connectivity.dart';
import 'package:cross_connectivity/cross_connectivity.dart' hide Connectivity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Connectivity _connectivity = Connectivity();
  String _connectionStatus = 'Unknown';
  String specificWifiName = 'Specific Wifi Name';
  Future<String> _futureGetWifiName;
  bool isInTheZone = false;
  bool isConnectedToSpecificWifi;

  @override
  void initState() {
    super.initState();
    _locationData = widget.location;
    print('_locationData : $_locationData');
    initConnectivity();
    _futureGetWifiName = _connectivity.getWifiName();
  }

  void _setCircles(LatLng point) {
    double distanceInMeters = Geolocator.distanceBetween(_locationData.latitude, _locationData.longitude, point.latitude, point.longitude);
    print('distanceInMeters : $distanceInMeters');

    if (distanceInMeters < radius)
      setState(() => isInTheZone = true);
    else
      setState(() => isInTheZone = false);

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
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: ConnectivityBuilder(builder: (context, isConnected, status) {
                  return FutureBuilder<String>(
                      future: _futureGetWifiName,
                      builder: (context, AsyncSnapshot<String> wifiName) {
                        (wifiName.data == specificWifiName) ? isConnectedToSpecificWifi = true : isConnectedToSpecificWifi = false;
                        if (status != ConnectivityStatus.wifi) isConnectedToSpecificWifi = false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                Text(status == ConnectivityStatus.wifi ? '${wifiName.data}' : 'Disconnected'),
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
                          ],
                        );
                      });

                  // return Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: <Widget>[
                  //     Icon(
                  //       isConnected == true ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off,
                  //       color: isConnected == true ? Colors.green : Colors.red,
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       '$status',
                  //       style: TextStyle(
                  //         color: status != ConnectivityStatus.none ? Colors.green : Colors.red,
                  //       ),
                  //     ),
                  //   ],
                  // );
                }),
              ),
            ),
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
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.wifi),
                    hintText: 'myWifi',
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
