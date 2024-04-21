import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class HistoryRecordings extends StatefulWidget {
  const HistoryRecordings({Key? key}) : super(key: key);

  @override
  _HistoryRecordingsState createState() => _HistoryRecordingsState();
}

class _HistoryRecordingsState extends State<HistoryRecordings> {
  late List<String> _videoUrls;
  late List<VideoPlayerController> _controllers;
  late List<Future<void>> _initializeVideoPlayerFutures;

  Future<void> _fetchVideos(String cameraId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://renegan-inc-backend.onrender.com/videos/grouped')); // Replace with your GET request URL
      if (response.statusCode == 200) {
        final List<dynamic> videoData = jsonDecode(response.body);
        final List<dynamic> filteredVideos = videoData
            .where((element) => element['_id'] == cameraId)
            .map((element) => element['videos'])
            .toList();
        print(filteredVideos);
        setState(() {
          _videoUrls =
              filteredVideos.isNotEmpty ? filteredVideos[0].cast<String>() : [];
          print('Video urls: ${_videoUrls}');
        });
      } else {
        print('Failed to fetch videos: ${response.statusCode}');
        // Handle failed GET request (e.g., show error message)
      }
    } catch (error) {
      print('Error fetching videos: $error');
      // Handle exceptions (e.g., network issues)
    }
  }

  @override
  void initState() {
    super.initState();
    _videoUrls = [];
    _controllers = [];
    _initializeVideoPlayerFutures = [];
    _fetchVideos('660fa9e984241998bf01ae37');
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: _videoUrls.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: List.generate(
                  _videoUrls.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: VideoPlayerWidget(videoUrl: _videoUrls[index]),
                    );
                  },
                ),
              ),
            )
          : const Center(
              child: Text('No videos available'),
            ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return VideoPlayer(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          VideoPlayerControls(controller: _controller),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class VideoPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 200),
            child: controller.value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        color: Colors.white,
                        onPressed: () {
                          if (!controller.value.isInitialized) {
                            return;
                          }
                          if (controller.value.isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
