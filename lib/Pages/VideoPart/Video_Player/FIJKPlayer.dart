import 'dart:math';

import 'package:ac_fun/Pages/Http/dio_part.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';

class VideoScreen extends StatefulWidget {
  final String contentId;
  final String videoId;
  VideoScreen({@required this.contentId,@required this.videoId});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FijkPlayer player = FijkPlayer();
  String playURL = "";
  void _initPlayUrl() {
    String requestURL =
        "https://api-new.app.acfun.cn/rest/app/play/playInfo/m3u8?contentId=" +
            widget.contentId +
            "&app_version=6.0.0.272&market=appstore&origin=ios&videoId=" +
            widget.videoId +
            "&sys_name=ios&sys_version=12.2&resolution=750x1334";
    
    DioUtils.request(requestURL, onSuccess: (data) {
      playURL = data["playInfo"]["streams"][0]["cdnUrls"][0]["url"];
      player.setDataSource(playURL, autoPlay: true);
    }, onError: (error) {
      print(error);
    });
  }

  @override
  void initState() {
    super.initState();
    _initPlayUrl();
  }

  @override
  Widget build(BuildContext context) {
    double rpxW = MediaQuery.of(context).size.width / 750;
    double rpxH = MediaQuery.of(context).size.width / 750;
    return Scaffold(
        appBar: AppBar(title: Text("Fijkplayer Example")),
        body: Column(
            children: <Widget>[
               Container(
                 width: 750*rpxW,
                 height: 500*rpxH,
                 child: FijkView(
                  player: player,
                  // fit: FijkFit.fill,
                  panelBuilder: (FijkPlayer fijkPlayer, FijkData fijkData, BuildContext context, Size size, Rect rect){
                    return CustomFijkPanel(
                      player: fijkPlayer,
                      buildContext: context,
                      viewSize: size,
                      texturePos: rect,
                    );
                  },
                )
               ),
 
            ],
          )
      );
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }
}

class CustomFijkPanel extends StatefulWidget {
  final FijkPlayer player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;

  const CustomFijkPanel({
    @required this.player,
    this.buildContext,
    this.viewSize,
    this.texturePos,
  });

  @override
  _CustomFijkPanelState createState() => _CustomFijkPanelState();
}

class _CustomFijkPanelState extends State<CustomFijkPanel> {

  FijkPlayer get player => widget.player;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_playerValueChanged);
  }

  void _playerValueChanged() {
    FijkValue value = player.value;

    bool playing = (value.state == FijkState.started);
    if (playing != _playing) {
      setState(() {
        _playing = playing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Rect rect = Rect.fromLTRB(
        max(0.0, widget.texturePos.left),
        max(0.0, widget.texturePos.top),
        min(widget.viewSize.width, widget.texturePos.right),
        min(widget.viewSize.height, widget.texturePos.bottom));

    return Positioned.fromRect(
      rect: rect,
      child: Container(
        alignment: Alignment.bottomLeft,
        child: IconButton(
          icon: Icon(
            _playing ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            _playing ? widget.player.pause() : widget.player.start();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.removeListener(_playerValueChanged);
  }
}