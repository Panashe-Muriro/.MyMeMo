import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GeoListenPage(),
    );
  }
}

class GeoListenPage extends StatefulWidget {
  @override
  _GeoListenPageState createState() => _GeoListenPageState();
}

class _GeoListenPageState extends State<GeoListenPage> {
  List mylocation = [];
  var newD;
  var newDt;
  Timer _timer;
  int _start = 10;
  String currentposition = 'Still at Home';
  bool isinmyLocation = false;
  Color activecolor = Color(0xff700000);
  Geolocator geolocator = Geolocator();
  Position userLocation;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  var spinkit = SpinKitFadingCube(
    color: Colors.white,
    size: 30.0,
  );

  List<String> litems = [];
  final TextEditingController eCtrl = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();

    FlutterLocalNotificationsPlugin().initialize(initializationSettings);
    WidgetsBinding.instance.addPostFrameCallback((_) {
// put the code here where you are using context.
    });

    initializing();

    _getLocation().then((position) {
      userLocation = position;
    });
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications() async {
    await notification();
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Memo', 'Hey, check your to do list now', notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
    // we can set navigator to navigate another screen
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);

    _timer = new Timer.periodic(oneSec, (Timer timer) {
      var dt = DateTime.now();
      newDt = DateFormat.Hms().format(dt);
      newD = DateFormat.MMMd().format(dt);
      newcolor();
      print(newDt.toString());
      print(newD);

      _getLocation().then((value) {
        setState(() {
          userLocation = value;
          print(userLocation.latitude < 44);
          if (userLocation.latitude < 42.05243) {
            isinmyLocation = true;
            currentposition = 'Still at home';
          }
          if (userLocation.latitude > 42.0525) {
            isinmyLocation = false;
            currentposition = 'Out of home';
            _showNotifications();
          }
        });
      });
    });
  }

  void newcolor() {
    if (isinmyLocation) {
      activecolor = Color(0xff700000);
    } else {
      activecolor = Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff959089),
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Color(0xfff7c5a8),
        backgroundColor: Color(0xFF1c1c1c),
      ),
      body: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 200,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                      child: ClipPath(
                        clipper: OvalBottomBorderClipper(),
                        child: Container(
//                    color: Color(0xfff7c5a8),
                            color: Color(0xFF1c1c1c)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: MediaQuery.of(context).size.width / 12,
                child: GestureDetector(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Container(
                      color: activecolor,
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 100,
                      child: userLocation == null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Waiting for Location',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 35.0),
                              child: Text(
                                currentposition,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: Colors.white)),
                              ),
                            ),
                    ),
                  ),
                  onTap: () {
//                    _getLocation().then((value) {
//                      setState(() {
//                        userLocation = value;
//                      });
//                    });
                    notification();
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 120,
                child: Text(
                  'MEMO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      textStyle:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 40),
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[],
          ),
          SizedBox(
            width: 20,
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              color: Color.fromRGBO(255, 255, 255, 0.6),
              child: TextField(
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(255, 255, 255, 0.6))),
                  focusColor: Color(0xff700000),
                  hintText: 'Enter a new Note',
                ),
                textAlign: TextAlign.center,
                controller: eCtrl,
                onSubmitted: (text) {
                  litems.add(text);
                  eCtrl.clear();
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
              child: new ListView.builder(
                  itemCount: litems.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 1),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            color: Color(0xffffffff),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xff700000),
                                foregroundColor: Colors.white,
                              ),
                              title: Text(litems[Index]),
                              subtitle: Text('Swipe left to delete'),
                            ),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Archive',
                          color: Colors.blue,
                          icon: Icons.archive,
//                            onTap: () => _showSnackBar('Archive'),
                        ),
                        IconSlideAction(
                          caption: 'Share',
                          color: Colors.indigo,
                          icon: Icons.share,
//                            onTap: () => _showSnackBar('Share'),
                        ),
                      ],
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'More',
                          color: Colors.black45,
                          icon: Icons.more_horiz,
//                            onTap: () => _showSnackBar('More'),
                        ),
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
//                            onTap: () => _showSnackBar('Delete'),
                        ),
                      ],
                    );
                  }))
        ],
      ),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }
}
