import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:multimedia_files/enums/enums.dart';
import 'package:multimedia_files/multimedia_files.dart';
import 'package:video_player/video_player.dart';
import '../controller/story_controller.dart';
import '../utils.dart';

class VideoLoader {
  String url;

  File? videoFile;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if (videoFile != null) {
      state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager()
        .getFileStream(url, headers: requestHeaders as Map<String, String>?);

    fileStream.listen((fileResponse) {
      if (fileResponse is FileInfo) {
        if (videoFile == null) {
          state = LoadState.success;
          videoFile = fileResponse.file;
          onComplete.call();
        }
      }
    });
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;

  StoryVideo(this.videoLoader, {this.storyController, Key? key})
      : super(key: key ?? UniqueKey());

  static StoryVideo url(String url,
      {StoryController? controller,
      Map<String, dynamic>? requestHeaders,
      Key? key}) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders),
      storyController: controller,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  StreamSubscription? _streamSubscription;
  VideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();

    widget.storyController!.pause();

    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        playerController =
            VideoPlayerController.file(widget.videoLoader.videoFile!);

        playerController!.initialize().then((v) {
          setState(() {});
          widget.storyController!.play();
        });

        if (widget.storyController != null) {
          _streamSubscription =
              widget.storyController!.playbackNotifier.listen((playbackState) {
            if (playbackState == PlaybackState.pause) {
              playerController!.pause();
            } else {
              playerController!.play();
            }
          });
        }
      } else {
        setState(() {});
      }
    });
  }

  Widget getContentView() {
    if (widget.videoLoader.state == LoadState.success &&
        playerController!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: playerController!.value.aspectRatio,
          child: VideoPlayer(playerController!),
        ),
      );
    }

    return widget.videoLoader.state == LoadState.loading
        ? const Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          )
        : const Center(
            child: Text(
              "Media failed to load.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}

class StoryVideo1 extends StatefulWidget {
  const StoryVideo1({
    Key? key,
    required this.url,
    required this.storyController,
  }) : super(key: key);

  final String url;
  final StoryController storyController;

  @override
  State<StoryVideo1> createState() => _StoryVideo1State();
}

class _StoryVideo1State extends State<StoryVideo1> {
  late final VideoPlayerController? _playerController;
  // ignore: unused_field
  late final StreamSubscription? _streamSubscription;

  @override
  void initState() {
    widget.storyController.pause();

    _playerController = VideoPlayerController.network(widget.url);

    if (kDebugMode) {
      print(_playerController?.value.duration ?? 'duration null');
    }

    /* widget.storyController.setDuration(
        duration:
            _playerController?.value.duration ?? const Duration(seconds: 10)); */

    _playerController!.initialize().then((v) {
      setState(() {});
      widget.storyController.play();
    });

    _streamSubscription =
        widget.storyController.playbackNotifier.listen((playbackState) {
      if (playbackState == PlaybackState.pause) {
        _playerController!.pause();
      } else {
        _playerController!.play();
      }
    });
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void setState(event) {
    if (mounted) {
      super.setState(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FutureBuilder<Color>(
        future: ExtendedMethodsMultimedia.dominantColorFromUrl(
          path: widget.url,
          urlType: UrlType.video,
        ),
        builder: (context, snapshot) {
          final color = snapshot.data ?? Colors.white;

          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                color: color,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.2),
                  ],
                ),
              ),
              child: _getContentView(),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: color,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getContentView() {
    if (_playerController!.value.isInitialized) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: _playerController!.value.aspectRatio,
              child: VideoPlayer(_playerController!),
            ),
          ),
        ),
      );
    }

    return _playerController!.value.isBuffering
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          )
        : _playerController!.value.hasError
            ? const Center(
                child: Text(
                  "Media failed to load.",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : const SizedBox();
  }

  /*  Widget _progressIndicator(){

  } */

}
