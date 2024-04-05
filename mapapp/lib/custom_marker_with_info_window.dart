import 'dart:ui' as ui;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

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
  // final List<LatLng> _latLang = [
  //   const LatLng(33.6941, 72.9734),
  //   const LatLng(33.7008, 72.9682),
  //   const LatLng(33.6992, 72.9744),
  //   const LatLng(33.6939, 72.9771),
  //   const LatLng(37.6910, 72.9807),
  //   const LatLng(34.7036, 72.9785)
  // ];
  final double _zoom = 15.0;
  final Set<Marker> _markers = {};

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

  // loadData() async {
  //   for (int i = 0; i < _latLang.length; i++) {
  //     final Uint8List markerIcon =
  //         await getBytesFromAsset(images[0].toString(), 100);

  //     _markers.add(Marker(
  //         markerId: MarkerId(i.toString()),
  //         position: _latLang[i],
  //         icon: BitmapDescriptor.fromBytes(markerIcon),
  //         onTap: () {
  //           _customInfoWindowController.addInfoWindow!(
  //             GestureDetector(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => const NewPage()),
  //                 );
  //               },
  //               child: Container(
  //                 width: 300,
  //                 height: 200,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   border: Border.all(color: Colors.grey),
  //                   borderRadius: BorderRadius.circular(10.0),
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       width: 300,
  //                       height: 100,
  //                       decoration: const BoxDecoration(
  //                         image: DecorationImage(
  //                             image: NetworkImage(
  //                                 'https://images.pexels.com/photos/1566837/pexels-photo-1566837.jpeg?cs=srgb&dl=pexels-narda-yescas-1566837.jpg&fm=jpg'),
  //                             fit: BoxFit.fitWidth,
  //                             filterQuality: FilterQuality.high),
  //                         borderRadius: BorderRadius.all(
  //                           Radius.circular(10.0),
  //                         ),
  //                         color: Colors.red,
  //                       ),
  //                     ),
  //                     const Padding(
  //                       padding: EdgeInsets.only(top: 10, left: 10, right: 10),
  //                       child: Row(
  //                         children: [
  //                           SizedBox(
  //                             width: 100,
  //                             child: Text(
  //                               'Beef Tacos',
  //                               maxLines: 1,
  //                               overflow: TextOverflow.fade,
  //                               softWrap: false,
  //                               style: TextStyle(color: Colors.black),
  //                             ),
  //                           ),
  //                           Spacer(),
  //                           Text(
  //                             '.3 mi.',
  //                             style: TextStyle(color: Colors.black),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                     const Padding(
  //                       padding: EdgeInsets.only(top: 10, left: 10, right: 10),
  //                       child: Text(
  //                         'Help me finish these tacos! I got a platter from Costco and it’s too much.',
  //                         maxLines: 2,
  //                         style: TextStyle(color: Colors.black),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             _latLang[i],
  //           );
  //         }));

  //     setState(() {});
  //   }
  // }

  loadData() async {
    final response = await http
        .get(Uri.parse('https://rh20bk9g-3001.inc1.devtunnels.ms/cameras'));

    if (response.statusCode == 200) {
      List<dynamic> cameras = jsonDecode(response.body);
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print(cameras);
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');
      // print('------------------');

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
                      MaterialPageRoute(builder: (context) => const NewPage()),
                    );
                  },
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 300,
                          height: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    'https://images.pexels.com/photos/1566837/pexels-photo-1566837.jpeg?cs=srgb&dl=pexels-narda-yescas-1566837.jpg&fm=jpg'),
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.high),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            color: Colors.red,
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Beef Tacos',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              Spacer(),
                              Text(
                                '.3 mi.',
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: Text(
                            'Help me finish these tacos! I got a platter from Costco and it’s too much.',
                            maxLines: 2,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                position,
              );
            }));

        setState(() {});
      }
    } else {
      throw Exception('Failed to load cameras');
    }
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

class NewPage extends StatelessWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Page'),
      ),
      body: const Center(
        child: Text('This is a new page!'),
      ),
    );
  }
}
