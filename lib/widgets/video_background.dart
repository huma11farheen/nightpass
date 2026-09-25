import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Single shared controller — created once, never disposed for the lifetime
// of the app. Both login and signup reuse the same playing instance so
// navigating between them never causes a pause or re-initialise flash.
VideoPlayerController? _sharedCtrl;
bool _sharedReady = false;

Future<VideoPlayerController> _getOrCreateController() async {
  if (_sharedCtrl != null && _sharedReady) return _sharedCtrl!;
  _sharedCtrl ??= VideoPlayerController.asset('assets/videos/login_bg.mp4');
  if (!_sharedReady) {
    await _sharedCtrl!.initialize();
    _sharedCtrl!.setLooping(true);
    _sharedCtrl!.setVolume(0);
    _sharedCtrl!.play();
    _sharedReady = true;
  }
  return _sharedCtrl!;
}

/// Looping muted full-screen video background.
/// Reuses a single shared [VideoPlayerController] across login/signup so
/// navigating between pages never pauses or restarts the video.
class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key, this.opacity = 0.55});

  final double opacity;

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> with WidgetsBindingObserver {
  VideoPlayerController? _ctrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final ctrl = await _getOrCreateController();
    if (!mounted) return;
    // Resume play in case it was paused by app lifecycle
    if (!ctrl.value.isPlaying) ctrl.play();
    setState(() => _ctrl = ctrl);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _ctrl?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _ctrl?.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Do NOT dispose the shared controller — other screens may still use it.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (ctrl != null && _sharedReady)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: ctrl.value.size.width,
                height: ctrl.value.size.height,
                child: VideoPlayer(ctrl),
              ),
            )
          else
            const ColoredBox(color: Colors.black),

          ColoredBox(
            color: Colors.black.withValues(alpha: 1.0 - widget.opacity),
          ),
        ],
      ),
    );
  }
}
