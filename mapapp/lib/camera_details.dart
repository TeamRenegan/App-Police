import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapapp/live_stream.dart';
import 'package:mapapp/alerts.dart';

class CameraDetails extends StatefulWidget {
  const CameraDetails({super.key});

  @override
  State<CameraDetails> createState() => _CameraDetailsState();
}

class _CameraDetailsState extends State<CameraDetails> {
  // Store camera details with default values
  String ownerName = "Not Available";
  String contactNumber = "";
  String email = "";
  String address = "";
  String modelName = "";
  bool isLoading = false; // Flag for loading state
  String errorMessage = ""; // Store any error message

  // Define default data
  final String defaultOwnerName = "Gopi Bahu";
  final String defaultContactNumber = "9876543210";
  final String defaultEmail = "Gopibahu@sasubai.com";
  final String defaultAddress = "Wherever you are is the place I belong";
  final String defaultModelName = "pict cctvs";

  Future<void> fetchCameraDetails() async {
    // Replace with your actual API endpoint
    final response = await http.get(Uri.parse(
        "https://rh20bk9g-3001.inc1.devtunnels.ms/cameras/details/660e780ca68c5be3668a005b"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        ownerName = data['ownerName'] ?? defaultOwnerName;
        contactNumber = data['contactNumber'] ?? defaultContactNumber;
        email = data['email'] ?? defaultEmail;
        address = data['address'] ?? defaultAddress;
        modelName = data['cameraModel'] ?? defaultModelName;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = response.reasonPhrase ?? "Error fetching details";
        isLoading = false; // Set loading to false even on error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCameraDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Camera Details", // Removed const keyword for styling
          style: TextStyle(
            fontSize: 20.0, // Increased font size
            fontWeight: FontWeight.bold, // Made text bold
            color: Colors.white, // White text for better contrast
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show error message if any
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 6.0),
              )
            else
              // Display details section
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Owner Name:",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(ownerName, style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      Text(
                        "Contact Number:",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(contactNumber,
                          style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      Text(
                        "Email:",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(email, style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      Text(
                        "Address:",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(address, style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      Text(
                        "Model Name:",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(modelName, style: const TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40.0), // Added spacing for visual appeal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveStreamPage(
                        urlToFetchStreamUrl:
                            'https://ankit-s3-1.s3.ap-south-1.amazonaws.com/crime_scenes/crime_scene_20240117_165530.mp4',
                      ),
                    ),
                  ),
                  child: const Text("Live Stream"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  // onPressed: () =>
                  //     Navigator.pushNamed(context, "HistoryRecordings"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryRecordings(),
                    ),
                  ),
                  child: const Text("Alerts"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
