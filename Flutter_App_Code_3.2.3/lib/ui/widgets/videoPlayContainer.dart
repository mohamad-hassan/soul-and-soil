import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayContainer extends StatefulWidget {
  final String contentType, contentValue;
  final bool autoPlay;

  Duration lastPosition;

  VideoPlayContainer({super.key, required this.contentType, required this.contentValue, this.autoPlay = true, this.lastPosition = Duration.zero});
  @override
  VideoPlayContainerState createState() => VideoPlayContainerState();
}

class VideoPlayContainerState extends State<VideoPlayContainer> {
  bool playVideo = false;

  FlickManager? flickManager;
  YoutubePlayerController? _yc;

  VideoPlayerController? _controller;
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    initialisePlayer();
  }

  @override
  void dispose() async {
    if (_controller != null && _controller!.value.isPlaying) _controller!.pause();

    if (widget.contentType == "video_upload") {
      Future.delayed(const Duration(milliseconds: 10)).then((value) {
        flickManager!.flickControlManager!.exitFullscreen();
        flickManager!.dispose();
        _controller!.dispose();
        _controller = null;
        flickManager = null;
      });
    } else if (widget.contentValue == "video_youtube") {
      _yc!.dispose();
    }
    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      super.dispose();
    });

    // super.dispose();
  }

  initialisePlayer() {
    if (widget.contentValue != "") {
      if (widget.contentType == "video_upload") {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.contentValue));
        flickManager = FlickManager(
            videoPlayerController: _controller!,
            autoPlay: widget.autoPlay,
            onVideoEnd: () {
              widget.lastPosition = Duration.zero;
            });
      } else if (widget.contentType == "video_youtube" || widget.contentType == "url_youtube") {
        _yc = YoutubePlayerController(initialVideoId: YoutubePlayer.convertUrlToId(widget.contentValue) ?? "", flags: YoutubePlayerFlags(autoPlay: widget.autoPlay));
      } else if (widget.contentType == "video_other") {
        webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.contentValue));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.contentType == "video_upload")
        ? FlickVideoPlayer(flickManager: flickManager!, flickVideoWithControlsFullscreen: const FlickVideoWithControls(videoFit: BoxFit.fitWidth))
        : (widget.contentType == "video_youtube" || widget.contentType == "url_youtube")
            ? YoutubePlayer(controller: _yc!, showVideoProgressIndicator: true, progressIndicatorColor: Theme.of(context).primaryColor)
            : widget.contentType == "video_other"
                ? Center(child: WebViewWidget(controller: webViewController))
                : const SizedBox.shrink();
  }
}
