import 'package:clubship/router.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashVideoPage extends StatefulWidget {
  const SplashVideoPage({super.key});

  @override
  State<SplashVideoPage> createState() => _SplashVideoPageState();
}

class _SplashVideoPageState extends State<SplashVideoPage> {
  late VideoPlayerController _controller;
  bool _navigated = false;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _init();
  }

  Future<void> _init() async {
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4');
    try {
      await _controller.initialize();
    } catch (e) {
      debugPrint('Splash video init error: $e');
      _navigate();
      return;
    }
    if (!mounted) return;

    await _controller.setLooping(false);
    await _controller.setVolume(0);
    setState(() {});
    await _controller.play();

    // Add listener only after play() so position starts moving
    _listenerAdded = true;
    _controller.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    if (_navigated) return;
    final value = _controller.value;
    if (!value.isInitialized) return;

    // Wait until duration is known and nonzero
    final dur = value.duration;
    if (dur == Duration.zero) return;

    final pos = value.position;
    final finished = value.isCompleted || pos >= dur - const Duration(milliseconds: 300);
    if (finished) _navigate();
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final isLoggedIn = supabase.auth.currentSession != null;
    context.go(isLoggedIn ? Routes.mainLandingScreen : Routes.login);
  }

  @override
  void dispose() {
    if (_listenerAdded) _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _navigate,
        child: SizedBox.expand(
          child: _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
