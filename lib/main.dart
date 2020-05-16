import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage())
      ;
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  QrReaderViewController _controller;
  bool isOk = false;
  String data;
  Animation<Alignment> _animation;
  AnimationController _animationController;
  int _currentIndex = 0;
  bool _isTorchOn = false;
  bool isShowed = false;
  @override
  void initState() {
    super.initState();
    check();
    delai();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation =
        AlignmentTween(begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .animate(_animationController)
              ..addListener(() {
                setState(() {});
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  _animationController.reverse();
                } else if (status == AnimationStatus.dismissed) {
                  _animationController.forward();
                }
              });
    _animationController.forward();
        setState(() {});
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addObserver(this);

  }

   check() async {
      Map<PermissionGroup, PermissionStatus> permissions =
                    await PermissionHandler().requestPermissions([PermissionGroup.camera]);

      if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
       print(permissions);
      }
   }
       
       delai(){
        
             Future.delayed(const Duration(seconds: 2), () {
  setState(() {
    isOk=true;
  });
});
       }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("resumed");
      delai();
      _controller.startCamera(onScan);
      _animationController.reset();
    } else if (state == AppLifecycleState.inactive) {
      print("inactif");
      isOk=false;
      _controller.stopCamera();
      _animationController.stop();
    } else if (state == AppLifecycleState.paused) {
      print("pause");
      isOk=false;
      _controller.stopCamera();
      _animationController.stop();
    } else if (state == AppLifecycleState.suspending) {
      // app suspended (not used in iOS)
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.removeObserver(this);
  }

  tryAgainCallback() {
    setState(() {
      isOk=true;
    });
    _controller.startCamera(onScan);
    _animationController.reset();
  }

  void onTabTapped(int index) {
    index == 0 ? tryAgainCallback() :SystemNavigator.pop();
    setState(() {
      _currentIndex = index;
    });
  }

  alertDialog(BuildContext context, String message) {
    setState(() {
      isShowed = true;
    });
    Widget ok = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        setState(() {
          isShowed = false;
        });

        ;
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Resultat"),
          content: Text("$message"),
          actions: [
            ok,
          ],
          elevation: 5,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double deviceHeight =
        (MediaQuery.of(context).size.height) - statusBarHeight;
    double deviceWidth = MediaQuery.of(context).size.width;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body: 
        !isOk? Container(
          width: deviceWidth,
          height: deviceHeight,
        color: Colors.white,
        child: Center(
          child: Loading(indicator: BallPulseIndicator(), size: 100.0,color: Colors.pink),
        ),
      ):  
      Container(
          child: Stack(alignment: Alignment.center, children: <Widget>[
          Container(
          child: QrReaderView(
            width: deviceWidth,
            height: deviceHeight,
            callback: (container) {
              this._controller = container;
              _controller.startCamera(onScan);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 56),
          child: AspectRatio(
            aspectRatio: 264 / 258.0,
            child: Stack(
              alignment: _animation.value,
              children: <Widget>[
                Image.asset('assets/sao@3x.png'),
                Visibility(
                    visible: true, child: Image.asset('assets/tiao@3x.png'))
              ],
            ),
          ),
        ),
        Align(
          alignment:
              isPortrait ? Alignment.bottomCenter : Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              if (_isTorchOn) {
                _controller.setFlashlight();
              } else {
                _controller.setFlashlight();
              }
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
            child: Stack(
              children: <Widget>[
                Visibility(
                    visible: !_isTorchOn,
                    child: Image.asset(
                      'assets/tool_flashlight_close.png',
                      color: Colors.white,
                    )),
                Visibility(
                    visible: _isTorchOn,
                    child: Image.asset(
                      'assets/tool_flashlight_open.png',
                      color: Colors.white,
                    ))
              ],
            ),
          ),
        ),
      ])),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            title: Text('Scan'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app), title: Text('Exit'))
        ],
      ),
    );
  }

  void onScan(String v, List<Offset> offsets) {
    print([v]);
    setState(() {
      data = v;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _controller.stopCamera();
      _animationController.stop();
      if (!isShowed) {
        alertDialog(context, v);
      }
    });
  }
}
