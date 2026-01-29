import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'camera_screen.dart';

class PreviewScreen extends StatefulWidget {
  final String videoPath;
  final String testName;

  const PreviewScreen({super.key, required this.videoPath, required this.testName});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Auto-play
        _isPlaying = true;
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _onAccept() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: const Text(
          'Video loaded successfully.\nReady for fit4all analysis.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Go to Home
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  void _onReRecord() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CameraScreen(testName: widget.testName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          if (_controller.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Play Overlay
          GestureDetector(
            onTap: _togglePlay,
            behavior: HitTestBehavior.translucent,
            child: !_isPlaying && _controller.value.isInitialized
                ? Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 80),
                    ),
                  )
                : null,
          ),

          // Controls
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Re-record Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onReRecord,
                          icon: const Icon(Icons.replay),
                          label: const Text('Re-record'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Accept Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _onAccept,
                          icon: const Icon(Icons.check),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
