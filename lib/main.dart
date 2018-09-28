import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toiletkorea/HomeScreen.dart';

void main() {
  runApp(new MaterialApp( debugShowCheckedModeBanner: false,

    /*
    theme: ThemeData(
      backgroundColor: Colors.blue,
      indicatorColor:  Colors.blue,
      splashColor: Colors.amber, scaffoldBackgroundColor: Colors.blue,
      brightness: Brightness.dark,
      primaryColor: Colors.lightBlue[800],
      accentColor: Colors.cyan[600],
    ),
    */

    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/HomeScreen': (BuildContext context) => new MyApp()
    },
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  /*
  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }*/

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  /*
  @override
  void initState() {
    super.initState();
    startTime();
  }
  */

  void initState (){
    super.initState();
    // TODO initial state stuff
    new Future.delayed(const Duration(seconds: 1)).whenComplete((){ navigationPage();});
  }

  int getColorHexFromStr(String colorStr)
  {
    colorStr = "FF" + colorStr;
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("An error occurred when converting a color");
      }
    }
    return val;
  }

@override
Widget build(BuildContext context) {
    /*
  return new Scaffold(
    body: new Center(
      child : new Column(  mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text('서울시 화장실 찾을 땐', style: TextStyle(fontSize: 16.0),),
          new Padding(padding: EdgeInsets.all(10.0)),
          new Text('TOILET SEOUL' , style: TextStyle(fontWeight:FontWeight.w700, fontSize: 24.0), ),
        ],
      ),
    ),
  );
  */

    return new Scaffold(
      body: new Column(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: Container(
              color: Color(getColorHexFromStr('EC1C3C')),
              child: new Center(
                child: new Column(mainAxisAlignment:  MainAxisAlignment.center,
                children: <Widget>[
                  new Image(image: AssetImage('assets/mainIcon.png'), width: 96.0, height: 96.0,),
                  new Padding(padding: EdgeInsets.all(20.0)),
                  new Text('서울시 화장실 찾을 땐', style: TextStyle(fontSize: 16.0 , color: Colors.white.withOpacity(0.8)),),
                  new Padding(padding: EdgeInsets.all(5.0)),
                  new Text('TOILET SEOUL' , style: TextStyle(fontWeight:FontWeight.w700, fontSize: 24.0,color: Colors.white), ),
                ],),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Color(getColorHexFromStr('1F4385')),
              child: new Center(
              child: new Column(mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                  new Text('앱 관련 문의 : honeyhead@naver.com', style: TextStyle(fontSize: 12.0 , color: Colors.white.withOpacity(0.8)),),
              ],
              )
              )
            ),
          ),
        ],
      ),
    );
}
}