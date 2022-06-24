import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'Home Screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<Marker> markers = {};
  double defLat = 30.0655099;
  double defLang = 31.456604;

  //to controll map
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target:LatLng(30.0655099, 31.456604),
    zoom: 14.4746,
  );

  static final CameraPosition locationRoute = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(30.0655099, 31.456604),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  @override
  void dispose() {
    locationListener?.cancel();
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
    var userMarker = Marker(
        markerId: MarkerId('User-Marker'),
        position: LatLng(locationData?.latitude ?? defLat,
            locationData?.longitude ?? defLang));
    markers.add(userMarker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
      ),
      body: GoogleMap(
        markers: markers,
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('Go to route'),
        icon: Icon(
          Icons.route_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(locationRoute));
  }

  Location location = Location();

  late PermissionStatus permissionStatus;

  bool serviceEnabled = false;

  LocationData? locationData = null;

  late StreamSubscription<LocationData>? locationListener = null;

  Future<bool> isPermissionGranted() async {
    //in case has perm
    permissionStatus = await location.hasPermission();
    //in case perm denied
    if (permissionStatus == PermissionStatus.denied) {
      //request perm again from user
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> isPermissionEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

//  fun to get location
  void getUserLocation() async {
    //ensure user get u permission AND enabled GPS
    bool permGranted = await isPermissionGranted();
    //inCase user denied Permission
    if (permGranted == false) return;
    bool gpsEnabled = await isPermissionEnabled();
    //inCase GPS not enabled
    if (gpsEnabled == false) return;
    //inCase get location
    locationData = await location.getLocation();
    print("${locationData?.longitude ?? 0}");
    print("${locationData?.latitude ?? 0}");
    location.onLocationChanged.listen((newestLocation) {
      locationData = newestLocation;
      updateUserLocation();
      print("${locationData?.longitude ?? 0}");
      print("${locationData?.latitude ?? 0}");
    });
  }
  //to connect user location by map
  void updateUserLocation() async{
    var userMarker = Marker(
        markerId: MarkerId('User-Marker'),
        position: LatLng(locationData?.latitude ?? defLat,
            locationData?.longitude ?? defLang),);
    markers.add(userMarker);
    //to update user location using setState
    setState(() {

    });
    var newCamerPos=CameraPosition(target: LatLng(locationData?.latitude ?? defLat,
        locationData?.longitude ?? defLang),zoom: 19);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newCamerPos));
  }
}
