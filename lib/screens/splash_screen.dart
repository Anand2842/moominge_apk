import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/splash_video.mp4');
    
    try {
      await _controller.initialize();
      setState(() => _isInitialized = true);
      
      _controller.addListener(_videoListener);
      _controller.play();
    } catch (e) {
      // If video fails to load, skip to main app
      debugPrint('Splash video error: $e');
      widget.onComplete();
    }
  }

  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration &&
        _controller.value.duration > Duration.zero) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      body: GestureDetector(
        onTap: widget.onComplete, // Tap to skip
        child: _isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5A2B),
                ),
              ),
      ),
    );
  }
}
