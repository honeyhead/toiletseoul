import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:toiletkorea/Models/TOILET_INFO.dart';
import 'package:toiletkorea/Models/ResourcePack.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'dart:math' as Math;
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin{
  List<TOILET_INFO> toiletSet;
  List<Marker> markSet = new List<Marker>();
  List<LatLng> rectBorder = new List<LatLng>();
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;
  StreamSubscription<Map<String, double>> _locationSubscription;
  bool _permission = false;
  String error;
  bool currentWidget = true;
  Position _Position;
  MapController _mapController;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  int searchDistance = 1000;
  //Location _location = new Location();

  void _animatedMapMove (LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = new Tween<double>(begin: _mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = new Tween<double>(begin: _mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = new Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a new animation controller that has a duration and a TickerProvider.
    AnimationController controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =  CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      // Note that the mapController.move doesn't seem to like the zoom animation. This may be a bug in flutter_map.
      _mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
      //print("Location (${_latTween.evaluate(animation)} , ${_lngTween.evaluate(animation)}) @ zoom ${_zoomTween.evaluate(animation)}");
    });

    animation.addStatusListener((status) {
      print("$status");
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  Widget buildRoundBorder(String data){
    return new Container( decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10.0)), padding: EdgeInsets.all(5.0),
      child: new Text(data, style: TextStyle(color: Colors.white,fontSize: 14.0),),
    );
  }

  void _showModalSheet(TOILET_INFO _infoItem) {
    showModalBottomSheet(
        context: _scaffoldKey.currentContext,
        builder: (build) {
          return Container(
            //color: Colors.white,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(color: Colors.black26, width: 0.5))
                  ),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.only(top: 5.0)),
                      new Row( crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_infoItem.COT_NAME, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0)),
                        ],
                      ),

                      new Container( padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                        child: new Row( mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            buildRoundBorder('개방 시간'),
                            new Padding(padding: EdgeInsets.only(left: 10.0)),
                            Expanded(child: new Text(_infoItem.COT_OPENTIME, style: TextStyle(fontSize: 14.0),softWrap: true, maxLines: 3, overflow: TextOverflow.clip,),)
                          ],
                        ),
                      ),
                      new Container( padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: new Row( mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            buildRoundBorder('개방 타입'),
                            new Padding(padding: EdgeInsets.only(left: 10.0)),
                            Text( _infoItem.COT_TYPE,style: TextStyle(fontSize: 14.0),),
                            Text(' / ' + _infoItem.COT_KIND.replaceAll('1', ''),style: TextStyle(fontSize: 14.0),),
                          ],
                        ),
                      ),
                      new Container( padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: new Row( mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            buildRoundBorder('위치 주소'),
                            new Padding(padding: EdgeInsets.only(left: 10.0)),
                            Text( _infoItem.COT_ADDR_FULL_NEW == null ?  _infoItem.COT_ADDR_FULL_OLD : _infoItem.COT_ADDR_FULL_NEW,style: TextStyle(fontSize: 14.0),),
                            //Text(new DateTime.fromMillisecondsSinceEpoch(int.parse(_infoItem.COT_REG_DATE)).toString(),style: TextStyle(fontSize: 10.0),),
                          ],
                        ),
                      ),

                      new Container(
                        child: new Row( mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new Container(
                                child: new GestureDetector(
                                  onTap: () {
                                    launch("tel:"+ _infoItem.COT_TEL_NO);
                                  },
                                  child: new Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(child : Icon(Icons.call, size: 24.0,), radius: 24.0, backgroundColor: Colors.red.withOpacity(0.8), foregroundColor: Colors.white, ),
                                  ),
                                )
                            ),

                            
                            /*
                            new Container(
                                child: new GestureDetector(
                                  onTap: () {
                                    print('탭이 눌린것 같소이다');
                                  },
                                  child: new Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(child : Icon(Icons.speaker_notes, size: 24.0,), radius: 24.0, backgroundColor: Colors.red.withOpacity(0.8), foregroundColor: Colors.white, ),
                                  ),
                                )
                            ),
                            */
                            new Container(
                                child: new GestureDetector(
                                  onTap: () {

                                    //String urlString = "daummaps://route?sp="+_mapController.center.latitude.toString()+","+_mapController.center.longitude.toString()+"&ep="+_infoItem.COT_COORD_Y+","+_infoItem.COT_COORD_X+"&by=FOOT";
                                    String urlString = "daummaps://look?p="+_infoItem.COT_COORD_Y+","+_infoItem.COT_COORD_X;
                                    //String data = "geo:"+ _infoItem.COT_COORD_Y +","+ _infoItem.COT_COORD_X;
                                    String data = "geo:0,0?q="+ _infoItem.COT_COORD_Y +","+ _infoItem.COT_COORD_X+"("+ _infoItem.COT_NAME + ")" + '?z=11';
                                    _callMap(urlString,data);
                                    //String data = "geo:0,0?q="+ _infoItem.COT_COORD_Y +","+ _infoItem.COT_COORD_X+"("+ _infoItem.COT_NAME + ")" + '?z=11';

                                    //launch(data);
                                  },
                                  child: new Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(child : Icon(Icons.map, size: 24.0,), radius: 24.0, backgroundColor: Colors.red.withOpacity(0.8), foregroundColor: Colors.white, ),
                                  ),
                                )
                            ),
                            new Container(
                                child: new GestureDetector(
                                  onTap: () {
                                    String data ='mailto:honeyhead@naver.com?&subject=Toilet Korea 문의&body=문의 장소 : '+_infoItem.COT_NAME.toString()+ '\n'+'문의 내용 : '+'\n';
                                    _callEmail(data);
                                    //launch('mailto:honeyhead@naver.com?&subject=Toilet Korea 문의&body=문의 장소 : '+_infoItem.COT_NAME.toString()+ '\n'+'문의 내용 : '+'\n');
                                  },
                                  child: new Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(child : Icon(Icons.mail, size: 24.0,), radius: 24.0, backgroundColor: Colors.red.withOpacity(0.8), foregroundColor: Colors.white, ),
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                      new Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Text('카카오맵, 구글맵으로 여세요', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500,color: Colors.indigo.withOpacity(0.9)),)
                        ],
                      )

                    ],
                  ),
                )
              ]));
        }).whenComplete(() {
      print('취소하셨거나 완료하였습니다');
    });
  }
  void _callEmail(String url) async{

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await _neverSatisfied();
      //await launch(url2);
    }
  }

  Future<Null> _neverSatisfied() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('이메일 어플이 없습니다'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('불편을 드려서 죄송합니다'),
                new Text('아래로 메일 부탁드립니다'),
                new Text('honeyhead@naver.com'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('완료'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _callMap(String url,String url2) async{
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await launch(url2);
    }
  }

  void _findLookAround() async{
    List<Marker> addMarker =new List<Marker>();
    markSet= null;
    markSet = new List<Marker>();

    for(int i=0; i< toiletSet.length;i++) {
      var distance = await Geolocator().distanceBetween(
          PACK_DefaultLat, PACK_DefaultLng,
          double.parse(toiletSet[i].COT_COORD_Y),
          double.parse(toiletSet[i].COT_COORD_X));

      //if ((distance/1000) < 0.5){
      if ((distance/searchDistance) < 0.5){
        addMarker.add(new Marker(
            width: _mapController.zoom * 2,
            height:_mapController.zoom * 2,
            point: new LatLng(double.parse(toiletSet[i].COT_COORD_Y),
                double.parse(toiletSet[i].COT_COORD_X)),
            builder: (ctx) => new Container(child: new RawMaterialButton(
              onPressed: () => _showModalSheet(toiletSet[i]),
              /*
              child: new  Icon(
                Icons.account_circle, color: Colors.white,
                size: 20.0,
              ),
              */
              child: Image.asset('assets/toilet-paper.png'),
              shape: new CircleBorder(side: BorderSide(color: Colors.black54, width: 2.0)),
              elevation: 0.5,
              fillColor: Colors.red.withOpacity(0.8),
            ),)));
      }


      //print((distance/1000).toString() + "KM 정도 거리가 있습니다");
      /*
      setState(() {
        markSet.clear();
        markSet.add(new Marker(
            width: 80.0,
            height: 80.0,
            point: new LatLng(double.parse(toiletSet[i].COT_COORD_Y),  double.parse(toiletSet[i].COT_COORD_X)),
            builder: (ctx) => new Container( child: new FlutterLogo()),
        ));
      });
      */




      setState(() {
        markSet = addMarker;
      });
    }
  }

  void callMyLocation(){
    Geolocator().getCurrentPosition(LocationAccuracy.high).then((onValue){
      PACK_DefaultLng = onValue.longitude;
      PACK_DefaultLat = onValue.latitude;
      setState(() {
        _animatedMapMove(new LatLng(PACK_DefaultLat, PACK_DefaultLng), _mapController.zoom);
      });
    });
  }

  void getBoundsFromLatLng() async{
    LatLng latlng = _mapController.center;
    rectBorder= null;
    rectBorder = new List<LatLng>();

    var lat_change = 10/111.2;
    var lon_change = (Math.cos(latlng.latitude*(Math.PI/180))).abs();

    var points = <LatLng>[
      new LatLng(latlng.latitude+ lon_change/100.0, latlng.longitude+lon_change/100.0),
      new LatLng(latlng.latitude+ lon_change/100.0, latlng.longitude-lon_change/100.0),
      new LatLng(latlng.latitude- lon_change/100.0, latlng.longitude-lon_change/100.0),
      new LatLng(latlng.latitude- lon_change/100.0, latlng.longitude+lon_change/100.0),
      new LatLng(latlng.latitude+ lon_change/100.0, latlng.longitude+lon_change/100.0),
    ];

    setState(() {
      rectBorder = points;
    });
  }
  void showMenuSelection(dynamic value) {
     searchDistance = value;
     _findLookAround();
     //print(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    String selectedUser;
    List<String> users = <String>['1M','2M'];

    return new MaterialApp(
      title: 'demo', debugShowCheckedModeBanner: false,
      home: new Scaffold(key: _scaffoldKey,
          /*floatingActionButton: new SizedBox ( width: 48.0, height: 48.0 ,child:  new FloatingActionButton(
              child: const Icon(Icons.my_location, color: Colors.white,),  backgroundColor: Colors.redAccent,
              shape: Border.all(color: Colors.black38, width: 5.0, style: BorderStyle.solid), onPressed: (){print('안녕하세요');},
            ),),*/
          floatingActionButton:  new GestureDetector( onTap: (){_findLookAround();},
            child: new Container(child: new Text('현 위치 다시 검색', style: TextStyle(color: Colors.white, fontSize: 18.0),), decoration: BoxDecoration(color: Colors.black54), margin: EdgeInsets.all(10.0),padding: EdgeInsets.all(10.0),),),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          appBar: new AppBar(
            backgroundColor: Colors.red,
            title: new Text(PACK_title),
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.my_location),
                tooltip: 'My Location',
                onPressed: () {
                  //initPlatformState();
                  callMyLocation();
                },),
              new PopupMenuButton( tooltip: '검색 반경 범위를 설정합니다', onSelected: showMenuSelection, icon: Icon(Icons.directions_walk),
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    new PopupMenuItem(child: new Text('거리 : 500M'), value: 500,),
                    new PopupMenuItem(child: new Text('거리 : 1KM'), value: 1000,),
                    new PopupMenuItem(child: new Text('거리 : 2KM'), value: 2000,),
                  ];
                },
              ),
            ],
          ),
          body:
          new Column(
            children: <Widget>[
              new Flexible(
                child: new FlutterMap(
                  options: new MapOptions(
                      center: new LatLng(PACK_DefaultLat, PACK_DefaultLng),
                      maxZoom: PACK_MaxZoom,
                      minZoom: PACK_MinZoom,
                      interactive: PACK_IsMapInteractive,
                      onPositionChanged: (position){
                        PACK_DefaultLng = position.center.longitude;
                        PACK_DefaultLat = position.center.latitude;
                      },
                      zoom: PACK_DefalutZoom),
                  mapController:  _mapController,
                  layers: [
                    new TileLayerOptions(
                      urlTemplate: "http://mt1.google.com/vt/street=y&hl=kr&x={x}&y={y}&z={z}",

                    ),
                    new MarkerLayerOptions(
                      markers: markSet,
                    ),

                    /*
                 new PolylineLayerOptions(
                   polylines: [
                     new Polyline(
                         points: rectBorder,
                         strokeWidth: 4.0,
                         color: Colors.blue),
                   ],
                 ),
                 */
                  ],
                ),
              )

            ],
          )
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _mapController = new MapController();
    initPlatformState();
  }
  initPlatformState() async {
    _Position = await Geolocator().getCurrentPosition(LocationAccuracy.high);
    PACK_DefaultLat = _Position.latitude;
    PACK_DefaultLng = _Position.longitude;

    setState(() {
      _animatedMapMove(
          new LatLng(PACK_DefaultLat, PACK_DefaultLng), _mapController.zoom);
    });

    toiletSet =  await loadCrossword();
    _findLookAround();
  }
}