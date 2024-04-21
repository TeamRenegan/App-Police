import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class LiveStreamPage extends StatefulWidget {
  final String urlToFetchStreamUrl; 

  const LiveStreamPage({super.key, required this.urlToFetchStreamUrl});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
