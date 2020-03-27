import 'dart:async';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'videoContrl.dart';

class VideoFullPage extends StatefulWidget {
  final VideoPlayerController controller;
  final List streams;
  VideoFullPage(this.controller, this.streams);

  @override
  _VideoFullState createState() => _VideoFullState();
}

class _VideoFullState extends State<VideoFullPage>
    with TickerProviderStateMixin {
  bool isLand = false;

  Animation<double> animation;
  AnimationController animationController;

  Animation topAnimation;
  double itemH = 0.0;

  Animation<double> curve;
  bool select = false;
  //定时任务
  Timer timer;
  VideoPlayerController playerController;

  bool changeQuality = false;

  @override
  void initState() {
    super.initState();
    AutoOrientation.landscapeLeftMode();
  }
  void changeHeight(String url){
    widget.controller.pause();
    playerController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            changeQuality = true;
          });
        });
    changeQuality = false;
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

  void startTimer() {
    stopTimer();
    const period = const Duration(seconds: 3);
    timer = Timer.periodic(period, (timer) {
      _mainViewTap();
      stopTimer();
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  @override
  void dispose() {
    stopTimer();
    if (animationController!=null) {
      animationController.dispose();
    }
    if(playerController!=null){
      playerController.dispose();
    }
    AutoOrientation.portraitUpMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: (){
                    _mainViewTap();
                  },
                  child: Hero(
                    tag: "player",
                    child: AspectRatio(
                      aspectRatio:changeQuality?playerController.value.aspectRatio:widget.controller.value.aspectRatio,
                      child: VideoPlayer(changeQuality?playerController:widget.controller),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 25, right: 20),
                child: IconButton(
                  icon: const BackButtonIcon(),
                  color: Colors.white,
                  onPressed: () {
                    AutoOrientation.portraitUpMode();
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                  bottom: -itemH,
                  child: Container(
                    color: Colors.white60,
                    width: MediaQuery.of(context).size.width,
                    child: ControlView(
                      controller: changeQuality?playerController:widget.controller,
                      moveEnd: () {
                        startTimer();
                      },
                      moveStart: () {
                        stopTimer();
                      },
                      isFull: true, streams: widget.streams, changedPlayUrl: (String url){
                        // print(url);
                        changeHeight(url);
                      },
                    ),
                  )
                )
            ],
          ),
        ),
      ),
    );
  }
}
