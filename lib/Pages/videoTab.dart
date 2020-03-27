import 'package:flutter/material.dart';
import 'VideoPart/bestSelect_video.dart';
import 'VideoPart/recommend_video.dart';

class VideoTab extends StatefulWidget {
  @override
  _VideoTabState createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> with TickerProviderStateMixin{
  TabController _timeTabController;
  List<Tab> timeTabs = <Tab>[
    Tab(text:"精选"),
    Tab(text:"推荐"),
    Tab(text:"分区"),
  ];
  @override
  void initState() {
    super.initState();
    _timeTabController =
        TabController(vsync: this, initialIndex: 0, length: timeTabs.length);
    _timeTabController.animation.addListener(() {
      setState(() {});
    });

  }
  @override
  Widget build(BuildContext context) {
    double rpx = MediaQuery.of(context).size.width/750;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Container(
              alignment: Alignment.topLeft,
              child: TabBar(
                tabs: timeTabs,
                controller: _timeTabController,
                indicatorWeight: 3,
                indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                isScrollable: true,
                indicatorColor: Color(0xffFF7E98),
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Color(0xffFF7E98),
                ),
                unselectedLabelColor: Colors.black,
                unselectedLabelStyle: TextStyle(
                    fontSize: 25, color: Colors.black),
                indicatorSize: TabBarIndicatorSize.tab,
  
              )),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10,right: 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.search),
                  Text('内容')
                ],
              ),
              decoration:BoxDecoration(
                color:Color.fromARGB(200, 200, 200, 200),
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: TabBarView(
                controller: _timeTabController, 
                children: <Widget>[
                  BestSelectVideo(),
                  RecommendVideo(),
                  RecommendVideo(),
                ])),
          ],
        )
      )
    );
  }
}


