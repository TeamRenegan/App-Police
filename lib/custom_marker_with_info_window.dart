import 'dart:math';
import 'dart:ui' as ui;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mapapp/camera_details.dart';
import 'package:mapapp/community.dart';
import 'package:mapapp/open_custom_marker.dart';

import 'search.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

const googleApiKey = 'AIzaSyAPLck2dUtBZF4mTjpq1AzXC-hHy57lwDI';

class CustomMarkerInfoWindowScreen extends StatefulWidget {
  const CustomMarkerInfoWindowScreen({Key? key}) : super(key: key);

  @override
  State<CustomMarkerInfoWindowScreen> createState() =>
      _CustomMarkerInfoWindowScreenState();
}

class _CustomMarkerInfoWindowScreenState
    extends State<CustomMarkerInfoWindowScreen> {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  final places = GoogleMapsPlaces(apiKey: googleApiKey);

  final double _zoom = 15.0;
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = <Polygon>{};

  late LatLng _currentLocation;

  List<String> images = ['images/icon_1.png', 'images/icon_1.png'];

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  String _mapStyle = '';
  @override
  void initState() {
    _currentLocation = LatLng(18.458664, 73.851012);
    super.initState();
    rootBundle.loadString('images/map_style.json').then((string) {
      _mapStyle = string;
    });
    _requestLocationPermission();
    loadData();
  }

  void _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isDenied) {
      // The user denied the permission request. You can show a dialog to explain why you need the permission and ask them to grant it.
    }
  }

  loadData() async {
    final response = await http
        .get(Uri.parse('https://renegan-inc-backend.onrender.com/cameras'));

    if (response.statusCode == 200) {
      List<dynamic> cameras = jsonDecode(response.body);

      for (var camera in cameras) {
        final double lat =
            (camera['location']['coordinates'][1] as num).toDouble();
        final double lng =
            (camera['location']['coordinates'][0] as num).toDouble();
        final LatLng position = LatLng(lat, lng);

        final Uint8List markerIcon =
            await getBytesFromAsset(images[0].toString(), 150);

        _markers.add(Marker(
            markerId: MarkerId(camera['_id']),
            position: position,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraDetails(
                                camId: camera['_id'],
                              )),
                    );
                  },
                  child: OpenedContainer(
                      location: position,
                      title: camera['ownerName'],
                      miniTitle: camera['cameraModel'],
                      subTitle: camera['address']),
                ),
                position,
              );
            }));

        Map<String, double> camDirToAngle = {
          'North': 90,
          'East': 0,
          'South': 270,
          'West': 180,
          'North-East': 45,
          'South-East': 315,
          'South-West': 225,
          'North-West': 135
        };

        double angle = camDirToAngle[camera['cameraDirection']]!;
        _polygons.add(Polygon(
          polygonId: PolygonId(camera['_id']),
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 0,
          points: [
            position,
            calculateNewLatLng(position, angle - 45 / 2, 0.1),
            calculateNewLatLng(position, angle - 45 / 3, 0.1),
            calculateNewLatLng(position, angle - 45 / 4, 0.1),
            calculateNewLatLng(position, angle - 45 / 5, 0.1),
            calculateNewLatLng(position, angle - 45 / 6, 0.1),
            calculateNewLatLng(position, angle - 45 / 7, 0.1),
            calculateNewLatLng(position, angle - 45 / 8, 0.1),
            calculateNewLatLng(position, angle - 45 / 9, 0.1),
            calculateNewLatLng(position, angle, 0.1),
            calculateNewLatLng(position, angle + 45 / 9, 0.1),
            calculateNewLatLng(position, angle + 45 / 8, 0.1),
            calculateNewLatLng(position, angle + 45 / 7, 0.1),
            calculateNewLatLng(position, angle + 45 / 6, 0.1),
            calculateNewLatLng(position, angle + 45 / 5, 0.1),
            calculateNewLatLng(position, angle + 45 / 4, 0.1),
            calculateNewLatLng(position, angle + 45 / 3, 0.1),
            calculateNewLatLng(position, angle + 45 / 2, 0.1),
          ].map((e) => decrementToAdjust(e)).toList(),
        ));

        setState(() {});
      }
    } else {
      throw Exception('Failed to load cameras');
    }
  }

  LatLng decrementToAdjust(LatLng latLng) {
    return LatLng(latLng.latitude - 0.000015, latLng.longitude + 0.00001);
  }

  LatLng calculateNewLatLng(LatLng startPoint, double angle, double distance) {
    // Radius of the Earth in kilometers
    const double earthRadius = 6371.0;

    // Convert distance from kilometers to radians
    final double distanceRadians = (distance / 8) / earthRadius;

    // Convert angles from degrees to radians
    final double startLatRadians = startPoint.latitude * pi / 180.0;
    final double startLngRadians = startPoint.longitude * pi / 180.0;
    final double angleRadians = angle * pi / 180.0;

    // Calculate new latitude and longitude
    final double newLatRadians = asin(
        sin(startLatRadians) * cos(distanceRadians) +
            cos(startLatRadians) * sin(distanceRadians) * cos(angleRadians));
    final double newLngRadians = startLngRadians +
        atan2(sin(angleRadians) * sin(distanceRadians) * cos(startLatRadians),
            cos(distanceRadians) - sin(startLatRadians) * sin(newLatRadians));

    // Convert back to degrees
    final double newLatitude = newLatRadians * 180.0 / pi;
    final double newLongitude = newLngRadians * 180.0 / pi;

    return LatLng(newLatitude, newLongitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchScreen(
                        initialLocation: _currentLocation,
                      )),
            ).then((value) {
              if (value != null) {
                _currentLocation = value;

                _customInfoWindowController.hideInfoWindow!();
                _customInfoWindowController.googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: value, zoom: 15.0),
                  ),
                );

                _customInfoWindowController.googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: value, zoom: 15.0),
                  ),
                );
              }
            }),
          ),
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedPage()),
                  ),
              icon: const Icon(
                // Community icon
                Icons.people,
              )),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) async {
              _customInfoWindowController.googleMapController = controller;
              controller.setMapStyle(_mapStyle);
            },
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: _zoom,
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            polygons: _polygons,
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 200,
            width: 300,
            offset: 35,
          ),
        ],
      ),
    );
  }
}
