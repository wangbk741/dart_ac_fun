import 'dart:async';
import 'videoContrl.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../Http/dio_part.dart';

class VideoDetailPage extends StatefulWidget {
  final String contentId;
  final String videoId;
  final String playDuration;
  const VideoDetailPage(
      {Key key,
      @required this.contentId,
      @required this.videoId,
      @required this.playDuration})
      : super(key: key);
  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin {
  VideoPlayerController _controller;
  bool isReady = false;
  Animation<double> animation;
  AnimationController animationController;
  List streams;
  Animation topAnimation;
  double itemH = 0.0;

  Animation<double> curve;
  bool select = false;
  //定时任务
  Timer timer;
  
  void _initPlayUrl() {
    String requestURL =
        "https://api-new.app.acfun.cn/rest/app/play/playInfo/m3u8?contentId=" +
            widget.contentId +
            "&app_version=6.0.0.272&market=appstore&origin=ios&videoId=" +
            widget.videoId +
            "&sys_name=ios&sys_version=12.2&resolution=750x1334";
    String playURL = "";
    DioUtils.request(requestURL, onSuccess: (data) {
      streams = data["playInfo"]["streams"];
      playURL = streams[0]["cdnUrls"][0]["url"];

      // print(playURL);
      _controller = VideoPlayerController.network(playURL)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            isReady = true;
          });
        });
      // _controller.setLooping(true);
    }, onError: (error) {
      print(error);
    });
  }

  void _createAnimation() {
    animationController = new AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    animation = new Tween(begin: 50.0, end: 0.0).animate(animationController)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
          itemH = animation.value;
        });
      });

    animationController.forward();
  }

  void _mainViewTap() {
    if (select) {
      select = false;
      _startAnimation(50.0, 0.0);
      startTimer();
    } else {
      select = true;
      _startAnimation(0.0, 50.0); 
    }
  }
  void startTimer(){
    stopTimer();
      const period = const Duration(seconds: 3);
      timer = Timer.periodic(period, (timer) {
        _mainViewTap();
        stopTimer();
      });
  }
  void stopTimer(){
    if (timer!=null) {
      timer.cancel();
      timer = null;
    }
  }

  void _startAnimation(begin, end) {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    curve = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    topAnimation = Tween(begin: begin, end: end).animate(curve)
      ..addListener(() {
        // 一定要触发渲染不然最后就闪一闪到了终点
        setState(() {
          itemH = topAnimation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 结束时操作
        }
      });
    animationController.forward();
  }

  @override
  initState() {
    super.initState();

    _initPlayUrl();
    _createAnimation();
  }

  @override
  Widget build(BuildContext context) {
    double rpxW = MediaQuery.of(context).size.width / 750;
    double rpxH = MediaQuery.of(context).size.width / 750;

    return Scaffold(
        appBar: AppBar(
          title: Text('AC' + widget.contentId),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
              height: 200,
              margin: EdgeInsets.only(
                  top: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                      .padding
                      .top),
              color: Colors.yellow,
              alignment: Alignment.center,
              child: isReady
                  ? Hero(
                      tag: "player",
                      child: AspectRatio(
                        aspectRatio: 16/9,
                        child: GestureDetector(
                            onTap: () {
                              _mainViewTap();
                            },
                            child: VideoPlayer(_controller)),
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
            ),
            Positioned(
                bottom: -itemH,
                child: Container(
                    width: rpxW * 750,
                    color: Colors.white60,
                    child: isReady
                        ? ControlView(
                            controller: _controller, moveEnd: () {
                              print('/操作结束');
                              //操作结束
                              startTimer();
                            },
                            moveStart: (){
                              stopTimer();
                            }, isFull: false, streams: streams,
                          )
                        : Container())
              )
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    stopTimer();
    animationController.dispose();
    super.dispose();
  }
}

