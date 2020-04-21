import 'dart:async';
import 'package:flutter/material.dart';

class TabsTool extends StatefulWidget {
  final List<String> tabNames;
  final double mainW;
  final double mainH;
  final double lineH;
  final int startIndex;
  final ValueChanged<int> currentIndex;
  const TabsTool({Key key, @required this.tabNames, this.startIndex, this.mainW=200, this.mainH=30, this.lineH=5,@required this.currentIndex})
      : super(key: key);
  @override
  _TabsToolState createState() => _TabsToolState();
}

class _TabsToolState extends State<TabsTool> with TickerProviderStateMixin {
  int _selectIndex = 0;
  int _lastIndex = 0;
  //动画控制器
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;


  double startX = -0.5;
  double endX = -0.5;
  Animation<EdgeInsets> movement;
  @override
  initState() {
    super.initState();
    _selectIndex = widget.startIndex;
    _initController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initController() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addStatusListener((status){
      if (status == AnimationStatus.completed) {
          //当动画在开始处停止再次从头开始执行动画
          // print("end");

        }
    });
    _offsetAnimation = Tween<Offset>(
      begin: Offset(startX, 0.0),
      end: Offset(endX, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }




  Widget items() {
    return Column(
      children: <Widget>[
        SizedBox(
            height: widget.mainH,
            width: widget.mainW,
            child: Container(
                // alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TabItem(
                      lineW: widget.mainW/widget.tabNames.length,
                      tabNames: widget.tabNames,
                      selectIndex: (index) async {
                        _lastIndex = _selectIndex;
                        _selectIndex = index;
                        int forword = _lastIndex - _selectIndex;
                        setState(() {
                            startX = endX;
                            endX = endX - forword;
                            _initController();
                            _controller.forward();
                            widget.currentIndex(index);
                          });
                        // if (forword>0) {
                        //   //向左
                          
                        // } else if(forword<0){
                        //   //向右

                        // }

                      },
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: SlideTransition(
                        position: _offsetAnimation,
                        child: Container(
                          width: widget.mainW/widget.tabNames.length,
                          height: widget.lineH,
                          color: Colors.red,
                          child: SizedBox(),
                        ),
                      ),
                    ),
                    
                  ],
                ))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        items(),
      ],
    );
  }
}

class TabItem extends StatefulWidget {
  final List<String> tabNames;
  final ValueChanged<int> selectIndex; 
  final double lineW;
  const TabItem({Key key, @required this.tabNames,@required this.selectIndex,@required this.lineW}) : super(key: key);
  @override
  _TabItemState createState() => _TabItemState();
}

class _TabItemState extends State<TabItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.tabNames.asMap().keys.map((index) {
        return GestureDetector(
          onTap: () {
            widget.selectIndex(index);
          },
          child: Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Container(
                    width: widget.lineW,
                    child: Text(widget.tabNames[index],textAlign: TextAlign.center,),
                  ),

                ],
              )),
        );
      }).toList(),
    );
  }
}

