import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class LiveStreamPage extends StatefulWidget {
  final String urlToFetchStreamUrl; // URL to get the actual stream URL

  const LiveStreamPage({super.key, required this.urlToFetchStreamUrl});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // _fetchLiveStreamUrl();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Future<void> _fetchLiveStreamUrl() async {
  //   try {
  //     final response = await http.get(Uri.parse(widget.urlToFetchStreamUrl));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // Extract the live stream URL from the response data (assuming it's a JSON response)
  //       liveStreamUrl =
  //           data['liveStreamUrl'] ?? ""; // Handle potential null value
  //       _initializeVideoPlayer();
  //     } else {
  //       print("Error fetching live stream URL: ${response.reasonPhrase}");
  //       // Handle error (e.g., display an error message to the user)
  //     }
  //   } on Exception catch (e) {
  //     print("Error fetching live stream URL: $e");
  //     // Handle exception (e.g., network issues)
  //   }
  // }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.urlToFetchStreamUrl));
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();
      setState(() {});
    } on PlatformException catch (e) {
      // Handle platform exceptions (e.g., network issues)
      print("Error while initializing video player: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
      ),
      body: Center(
        child: _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}