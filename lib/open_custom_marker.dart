import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

const googleApiKey = 'YOUR GOOGLE API KEY'; // ENTER YOUR GOOGLE API KEY

class OpenedContainer extends StatefulWidget {
  final String title;
  final String miniTitle;
  final String subTitle;
  final LatLng location;

  const OpenedContainer(
      {super.key,
      required this.title,
      required this.miniTitle,
      required this.subTitle,
      required this.location});

  @override
  State<OpenedContainer> createState() => _OpenedContainerState();
}

class _OpenedContainerState extends State<OpenedContainer> {
  bool _isLoadingPlaceImage = true;
  String _placeImage = "";

  void loadPlaceImage() async {
    final response = await get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${widget.location.latitude}%2C${widget.location.longitude}&radius=100&key=$googleApiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final photo_reference =
          data['results'][0]['photos'][0]['photo_reference'];

      setState(() {
        _isLoadingPlaceImage = false;
        _placeImage =
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photo_reference&key=$googleApiKey";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadPlaceImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(
            width: 300,
            height: 100,
            child: _isLoadingPlaceImage
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_placeImage),
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      color: Colors.white,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.miniTitle,
                  style: const TextStyle(color: Colors.black),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Text(
              widget.subTitle,
              maxLines: 2,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
