import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:common_utils/common_utils.dart';
import 'videoContrl.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../Http/dio_part.dart';
import '../../../mytools/tabs_tool.dart';

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
  List streams = [];
  Animation topAnimation;
  double itemH = 0.0;

  Animation<double> curve;
  bool select = false;
  //定时任务
  Timer timer;
  bool showTitle = false;
  ScrollController scrollController = new ScrollController();

  //视屏列表数据
  List listArr = [];
  List<String> _Tabs = ["视屏", "评论"];
  int currentTagIndex = 0;
  //评论列
  List hotComments;
  Map subCommentsMap;
  List rootComments;
  String pcursor = "0";

  Future _initPlayUrl() async {
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

  Future _getVideoData() async {
    String listUrl =
        "https://api-new.app.acfun.cn/rest/app/feed/related/video?market=appstore&app_version=6.0.0.272&origin=ios&count=20&sys_name=ios&resourceId=" +
            widget.videoId +
            "&sys_version=13.4&resolution=750x1334&access_token=5c4146a3945fab2b7376cd51e3e6a46e";
    await DioUtils.request(listUrl, onSuccess: (data) {
      listArr = data["feeds"];
    }, onError: (error) {});
    setState(() {
      currentTagIndex = 0;
    });
    if (hotComments.length!=0) {
      deletateCommentData();
    }
  }

  void deletateCommentData() {
    hotComments = [];
    // subCommentsMap = data["subCommentsMap"];
    rootComments = [];
    pcursor = "0";
  }

  Future _getCommentData() async {
    String commentUrl =
        "https://api-new.app.acfun.cn/rest/app/comment/list?access_token=5c4146a3945fab2b7376cd51e3e6a46e&app_version=6.0.0&count=20&market=appstore&origin=ios&pcursor=" +
            pcursor +
            "&resolution=750x1334&showHotComments=1&sourceId="
            // +widget.videoId+
            +
            "14835226" +
            "&sourceType=3&sys_name=ios&sys_version=13.4";
    await DioUtils.request(commentUrl, onSuccess: (data) {
      if (pcursor.length!=1) {
        hotComments.addAll(data["hotComments"]);
        rootComments.addAll(data["rootComments"]);
        pcursor = data["pcursor"];
        // print(rootComments.length);
      }else{
        hotComments = data["hotComments"];
        subCommentsMap = data["subCommentsMap"];
        rootComments = data["rootComments"];
        pcursor = data["pcursor"];
      }
    }, onError: (error) {});
    setState(() {
      currentTagIndex = 1;
    });
  }

  int getCommentLength() {
    if (hotComments.length != 0) {
      return hotComments.length;
    }
    return 0;
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
    rootComments = [];
    hotComments = [];
    _initPlayUrl();
    _getVideoData();
    _createAnimation();
    scrollController.addListener(() {
      double height = MediaQuery.of(context).size.width / 750 * 300;
      if (scrollController.offset > height) {
        setState(() {
          showTitle = true;
        });
      } else {
        setState(() {
          showTitle = false;
        });
      }
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('max');
        
          // if(currentTagIndex==1){
          //   if (rootComments.length!=0) {
          //    _getCommentData();
          //   }
          // }
      
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double rpxW = MediaQuery.of(context).size.width / 750;
    double rpxH = MediaQuery.of(context).size.width / 750;

    return Theme(
      data: ThemeData(
        // brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        // platform: Theme.of(context).platform,
      ),
      child: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 400 * rpxH,
              flexibleSpace: FlexibleSpaceBar(
                title: showTitle ? Text("AC" + widget.contentId) : Text(""),
                background: Stack(
                  children: <Widget>[
                    Container(
                      height: 400 * rpxH,
                      margin: EdgeInsets.only(
                          top: MediaQueryData.fromWindow(
                                  WidgetsBinding.instance.window)
                              .padding
                              .top),
                      color: Colors.yellow,
                      alignment: Alignment.center,
                      child: isReady
                          ? Hero(
                              tag: "player",
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
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
                                    controller: _controller,
                                    moveEnd: () {
                                      print('/操作结束');
                                      //操作结束
                                      startTimer();
                                    },
                                    moveStart: () {
                                      stopTimer();
                                    },
                                    isFull: false,
                                    streams: streams,
                                  )
                                : Container())),
                  ],
                ),
              ),
            ),
            //将普通组件转换成sliver
            SliverToBoxAdapter(
              child: Container(
                child: TabsTool(
                  tabNames: _Tabs,
                  startIndex: 0,
                  currentIndex: (int value) {
                    print(value);
                    if (value == 0) {
                      _getVideoData();
                    } else if (value == 1) {
                      _getCommentData();
                    }
                  },
                  mainH: 30,
                  mainW: 300,
                  lineH: 2,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                //创建列表项
                return currentTagIndex == 0
                    ? _listItem(index)
                    : Container(
                      padding: EdgeInsets.all(5.0),
                      child: _commentItem(index),
                    );
              },
                  childCount: currentTagIndex == 0
                      ? listArr.length
                      : getCommentLength()
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listItem(int index) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: listArr[index]["coverUrls"][0],
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                    Positioned(
                        bottom: 0.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("播放:" + listArr[index]["viewCountShow"],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "评论:" +
                                    listArr[index]
                                        ["commentCountTenThousandShow"],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))
                          ],
                        ))
                  ],
                ),
              ),
            )),
        Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    listArr[index]["title"],
                    maxLines: 2,
                    textAlign: TextAlign.left,
                  ),
                  Text("UP:" + listArr[index]["user"]["name"],
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ))
      ],
    );
  }

  Widget _commentItem(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: hotComments[index]["headUrl"][0]["url"],
              fit: BoxFit.fill,
              errorWidget: (context, url, error) => new Icon(Icons.error),
            ),
          ),
        ),
        Expanded(
            flex: 10,
            child: Container(
              padding: EdgeInsets.only(left: 10.0,right: 5.0),
              child: Column(
                children: <Widget>[
                  userNamePart(hotComments[index]["userName"],
                      "#" + hotComments[index]["floor"].toString()),
                  commentPart(hotComments[index]["content"]),
                  footPart(hotComments[index]["timestamp"],
                      hotComments[index]["postDate"]),
                  if(haveComment(hotComments[index]["commentId"].toString()))Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.grey[300],
                    child: nextComment(hotComments[index]["commentId"].toString()),
                  )
                ],
              ),
            )
          ),

      ],
    );
  }
  Widget nextComment(String str){

    List subComments= subCommentsMap[str]["subComments"];

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
          subComments.asMap().keys.map((index){
            return Container(
                child: RichText(
                  text:TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: subComments[index]["userName"]+": ",
                        style: TextStyle(color: Colors.blue[200])
                      ),
                      if (subComments[index]["replyToUserName"].length!=0) TextSpan(
                        text: "回复:@"+subComments[index]["replyToUserName"],
                        style: TextStyle(color: Colors.blue[200])
                      ),
                      TextSpan(
                        text: subComments[index]["content"],
                        style: TextStyle(color: Colors.black)
                      )
                    ]
                  ) 
                ),
            );
          }).toList()
        ,
      ),
    );
  }
  Widget userNamePart(String name, String floor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            child: Text(
              name,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey),
            )),
        Expanded(
            child: Text(
              floor,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey),
            )),
      ],
    );
  }

  Widget commentPart(String mess) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(mess),
    );
  }

  Widget footPart(int time, String postDate) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Text(
          _getTime(time, postDate),
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.grey),
          )
        ),
        Expanded(
            child: Text(
            "data",
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey),
          )
        ),
        Expanded(
            child: Text(
            "data",
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey),
          )
        ),
      ],
    );
  }
  bool haveComment(String str){
    if(subCommentsMap.containsKey(str)){
      return true;
    }
    return false;
  }
  String _getTime(int time, String postDate) {
    String format5 = TimelineUtil.format(time);

    if (format5.contains("天")) {
      return postDate;
    }
    return format5;
  }

  @override
  void dispose() {
    _controller.dispose();
    stopTimer();
    animationController.dispose();
    super.dispose();
  }
}
