import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'navigator/tab_navgator.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());

}
// iOS主题
final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.red,
  accentColor: Colors.green,
  primaryColorBrightness: Brightness.dark,
);

// 默认主题
final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.red,
  accentColor: Colors.orangeAccent[400],
);
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? kIOSTheme : kDefaultTheme,
        home: TabNavigator(),
        // home: App(),
      ),
    );
  }
}


