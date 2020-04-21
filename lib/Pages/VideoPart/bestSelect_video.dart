import 'package:flutter/material.dart';
import '../http/dio_part.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Video_Player/videoDetail.dart';
import 'Video_Player/FIJKPlayer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BestSelectVideo extends StatefulWidget {
  @override
  _BestSelectVideoState createState() => _BestSelectVideoState();
}

class _BestSelectVideoState extends State<BestSelectVideo>
    with AutomaticKeepAliveClientMixin {
  List mainDataCan = [];
  List swiperDataList = [];
  final String requestURL =
      "https://api-new.app.acfun.cn/rest/app/selection?market=appstore&app_version=6.0.0.272&origin=ios&sys_name=ios&sys_version=12.2&resolution=750x1334";
  final String searchKey =
      "https://api-new.app.acfun.cn/rest/app/search/recommend?sys_name=ios&app_version=6.0.0.272&market=appstore&sys_version=12.2&resolution=750x1334&origin=ios";
  bool isReady = false;
  bool isError = false;
  ScrollController _controller = new ScrollController();

  Future<Null> _refresh() async {
    if(isReady){
      loadData();
    }
  }
  Future<Null> loadData() async {
    DioUtils.request(requestURL, onSuccess: (data) {
      // print(data["vdata"]);
      setState(() {
        mainDataCan = data["vdata"];
        swiperDataList = mainDataCan[0]["bodyContents"];
        isReady = true;
      });
    }, onError: (error) {
      setState(() {
        isError = true;
      });
    });
    return null;
  }
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    // double rpxH = MediaQuery.of(context).size.height / 750;
    // double rxpW = MediaQuery.of(context).size.width / 750;
    if (isError) {
      return Container(
        alignment: Alignment.center,
        child: FlatButton(
          onPressed: (){
            loadData();
          },
          child: Text('loadData'),
        ),
      );
    }
    if (isReady) {
      return Scaffold(
          body: Container(
          child: RefreshIndicator(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    ADBannerView(
                      adData: swiperDataList,
                    ),
                    ACHotView(
                      hotData: mainDataCan[1],
                    ),
                  ],
                ),
              ),
            ), 
            onRefresh: _refresh,
          
          )
        ));
    } else {
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class ACHotView extends StatelessWidget {
  final dynamic hotData;
  const ACHotView({Key key, this.hotData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double rpxH = MediaQuery.of(context).size.height / 750;
    double rxpW = MediaQuery.of(context).size.width / 750;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    child: Text(
                      hotData["title"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    child: Text(
                      hotData["headerText"]["title"],
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: hotData["bodyContents"].length / 2 * (MediaQuery.of(context).size.width-10)/2/1.3,
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    childAspectRatio: 1.3),
                itemCount: hotData["bodyContents"].length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        index%2==0?
                        new MaterialPageRoute(
                            builder: (context) => new VideoDetailPage(
                                  contentId: hotData["bodyContents"][index]
                                      ["href"],
                                  videoId: hotData["bodyContents"][index]
                                      ["detail"]["videoId"],
                                  playDuration: hotData["bodyContents"][index]
                                      ["detail"]["playDuration"],
                                )
                            )
                        :
                        new MaterialPageRoute(
                            builder: (context) => new VideoScreen(
                                  contentId: hotData["bodyContents"][index]
                                      ["href"],
                                  videoId: hotData["bodyContents"][index]
                                      ["detail"]["videoId"],
                                )
                            ),
                      );
                      // print(hotData["bodyContents"][index]["href"]);
                    },
                    child: Container(
                      // width: 360 * rxpW,
                      // height: 200 * rxpW,
                      // color: Colors.black,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  width: 360 * rxpW,
                                  height: 190 * rxpW,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl: hotData["bodyContents"][index]
                                          ["img"][0],
                                      fit: BoxFit.fill,
                                      // placeholder: (context, url) => new CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: Container(
                                      width: 360 * rxpW,
                                      alignment: Alignment.centerLeft,
                                      color: Color.fromARGB(60, 0, 0, 0),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.video_call,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          Text(
                                            hotData["bodyContents"][index]
                                                ["detail"]["viewCountShow"],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.comment,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          Text(
                                            hotData["bodyContents"][index]
                                                    ["detail"]["danmakuCount"]
                                                .toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      )),
                                  bottom: 0.0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              hotData["bodyContents"][index]["title"],
                              maxLines: 2,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}

class ADBannerView extends StatelessWidget {
  final List adData;
  const ADBannerView({Key key, this.adData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double rpxH = MediaQuery.of(context).size.height / 750;
    double rxpW = MediaQuery.of(context).size.width / 750;
    return Container(
      height: 150 * rpxH,
      padding: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Swiper(
          outer: false,
          itemBuilder: (c, i) {
            if (adData != null) {
              return CachedNetworkImage(
                imageUrl: adData[i]["img"][0],
                fit: BoxFit.fill,
                // placeholder: (context, url) => new CircularProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              );
            }
          },
          pagination: new SwiperPagination(
              builder: DotSwiperPaginationBuilder(
            color: Colors.black54,
            activeColor: Colors.white,
          )),
          itemCount: adData == null ? 0 : adData.length,
          autoplay: true,
          onTap: (index) {
            print(adData[index]["href"]);
          },
        ),
      ),
    );
  }
}
