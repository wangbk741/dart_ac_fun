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
    return Scaffold(
        appBar: AppBar(title: Text("Fijkplayer Example")),
        body: Container(
          child: FijkView(
            player: player,
          ),
        )
      );
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }
}