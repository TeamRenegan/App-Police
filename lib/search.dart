import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

const googleApiKey = 'YOUR API KEY';

class SearchScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const SearchScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  // Save all the places in a list
  final List<Map<String, dynamic>> places = [];

  void loadData() async {
    final response = await post(
      Uri.parse('https://places.googleapis.com/v1/places:searchText'),
      headers: {
        'X-Goog-Api-Key': googleApiKey,
        'X-Goog-FieldMask':
            'places.displayName,places.location,places.formattedAddress',
        if (widget.initialLocation != null)
          'locationBias': json.encode(
            {
              'circle': {
                'center': {
                  'latitude': widget.initialLocation!.latitude,
                  'longitude': widget.initialLocation!.longitude,
                },
                'radius': 50000,
              },
            },
          ),
      },
      body: {
        'textQuery': _controller.text,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final placesData = data['places'];

      final List<Map<String, dynamic>> _places = [];

      for (var place in placesData) {
        _places.add({
          'formattedAddress': place['formattedAddress'],
          'location': place['location'],
          'displayName': place['displayName']['text']
        });
      }

      setState(() {
        places.clear();
        places.addAll(_places);
      });
    }
  }

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length > 2) {
        loadData();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          decoration: const InputDecoration(
            hintText: 'Search for a place...',
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(place['displayName']),
              subtitle: Text(place['formattedAddress']),
              onTap: () {
                Navigator.of(context).pop(LatLng(
                  place['location']['latitude'],
                  place['location']['longitude'],
                ));
              },
            ),
          );
        },
      ),
    );
  }
}