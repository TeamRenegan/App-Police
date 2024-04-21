import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapapp/live_stream.dart';
import 'package:mapapp/alerts.dart';

class CameraDetails extends StatefulWidget {
  final String camId;

  const CameraDetails({Key? key, required this.camId}) : super(key: key);

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
  bool isLoading = false;
  String errorMessage = "";

  // Define default data
  final String defaultOwnerName = "Rahul Deshmukh";
  final String defaultContactNumber = "9988776655";
  final String defaultEmail = "rahul.deshmukh@example.com";
  final String defaultAddress = "123, ABC Colony, Pune";
  final String defaultModelName = "Pune Security Solutions";

  Future<void> fetchCameraDetails() async {
    // API endpoint
    final response = await http.get(Uri.parse(
        "https://renegan-inc-backend.onrender.com/cameras/details/${widget.camId}"));
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
        title: const Text(
          "Camera Details",
          style: TextStyle(
            fontSize: 20.0, 
            fontWeight: FontWeight.bold,
            color: Colors.white, 
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
                      const Text(
                        "Owner Name:",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(ownerName, style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      const Text(
                        "Contact Number:",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(contactNumber,
                          style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      const Text(
                        "Email:",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(email, style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      const Text(
                        "Address:",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(address, style: const TextStyle(fontSize: 16.0)),
                      const Divider(),
                      const Text(
                        "Model Name:",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Text(modelName, style: const TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveStreamPage(
                        urlToFetchStreamUrl:
                            'https://ankit-s3-1.s3.ap-south-1.amazonaws.com/crime_scenes/live_stream.mp4',
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryRecordings(),
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
