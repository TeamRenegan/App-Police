import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class SearchMapScreen extends StatefulWidget {
  const SearchMapScreen({super.key});

  @override
  _SearchMapScreenState createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  late GoogleMapController _controller;

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: 'AIzaSyB5qedkzpzE5AY7BcUVbiLTsMkOKQO2Ohs',
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "us")],
    );

    if (p != null) {
      GoogleMapsPlaces places =
          GoogleMapsPlaces(apiKey: 'AIzaSyB5qedkzpzE5AY7BcUVbiLTsMkOKQO2Ohs');
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId!);
      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;
      _goToPlace(lat, lng);
    }
  }

  void _goToPlace(double lat, double lng) {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.4746,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 1,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handlePressButton,
        child: const Icon(Icons.search),
      ),
    );
  }
}
