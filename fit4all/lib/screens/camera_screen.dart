import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final String testName;

  const CameraScreen({super.key, required this.testName});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInit = false;
  bool _isRecording = false;
  bool _isCountingDown = false;
  int _countdown = 3;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      setState(() => _errorMessage = "Camera and Microphone permissions are required.");
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = "No cameras available.");
        return;
      }

      // Select back camera by default
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) setState(() => _isInit = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Camera error: $e");
    }
  }

  Future<void> _startSequence() async {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown == 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _isCountingDown = false);
          await _startRecording();
        }
      } else {
        if (mounted) {
          setState(() => _countdown--);
        }
      }
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isRecordingVideo) {
       // Already recording, just update state
       if (mounted) setState(() => _isRecording = true);
       return;
    }

    try {
      await _controller!.startVideoRecording();
      if (mounted) setState(() => _isRecording = true);
    } on CameraException catch (e) {
      if (e.code == 'videoRecordingAlreadyStarted') {
        // Ignore this error
        if (mounted) setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.description ?? e.code}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;
    try {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PreviewScreen(videoPath: file.path, testName: widget.testName),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_errorMessage!))),
      );
    }

    if (!_isInit || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          Center(child: CameraPreview(_controller!)),

          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!_isRecording && !_isCountingDown)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      const Spacer(),
                      if (_isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('REC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Controls
                if (!_isCountingDown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Center(
                      child: GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startSequence,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isRecording ? 80 : 72,
                          height: _isRecording ? 80 : 72,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.transparent : Colors.white,
                            shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: _isRecording ? BorderRadius.circular(16) : null,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _isRecording ? 32 : 60,
                              height: _isRecording ? 32 : 60,
                              decoration: BoxDecoration(
                                color: _isRecording ? Colors.red : Colors.red,
                                shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                                borderRadius: _isRecording ? BorderRadius.circular(4) : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Countdown Overlay
          if (_isCountingDown)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
