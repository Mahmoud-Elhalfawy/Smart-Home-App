import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:temprature_app/HomePage.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}





Future <void> main(){

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Splash()));
}
class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  int _counter = 0;

  AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1700),
    );
    _animationController.forward();
    Future.delayed(
      Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
    );
  }






  @override
  void dispose() {
    _animationController.dispose();
    // Add code before the super
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 15),
                width: 350,
                height: 350,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FittedBox(
                    child: Image.asset('images/smart_home.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              Text(
                "Smart Homiee",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, color: Colors.green, fontFamily: "Lobster"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
