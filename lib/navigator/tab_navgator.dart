import 'package:ac_fun/Pages/articleTab.dart';
import 'package:flutter/material.dart';
import '../Pages/videoTab.dart';
import '../Pages/articleTab.dart';
import '../Pages/messageTab.dart';
import '../Pages/myTab.dart';
class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final PageController _controller = PageController(
    initialPage: 0,
  );
  final defaultColor = Colors.grey;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          VideoTab(),
          ArticleTab(),
          MessageTab(),
          MyTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _controller.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          _navigationBarItem(Icons.home, '视屏',0),
          _navigationBarItem(Icons.search, '动态',1),
          _navigationBarItem(Icons.camera, '文章',2),
          _navigationBarItem(Icons.account_box, '我的',3),
        ],
      ),
    );
  }

  _navigationBarItem(IconData iconData, String itemName,int index) {
    return BottomNavigationBarItem(
        icon: Icon(
          iconData,
          color: defaultColor,
        ),
        activeIcon: Icon(
          iconData,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          itemName,
          style:
              TextStyle(color: _currentIndex == index ? Theme.of(context).primaryColor : defaultColor),
        ));
  }
}