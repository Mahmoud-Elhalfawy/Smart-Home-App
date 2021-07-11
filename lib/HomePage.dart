import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool stop=false;
  bool alert=false;
  bool knocking=false;
  String tempReading="loading...";
  String humidityReading="loading...";
  String pinReading="";
  String knockReading="";
  bool firstTime=true;
  bool connected=false;
  Color inColor=Colors.green;
  Color outColor=Colors.red;
  bool timerStart=false;
  Timer timer;
  VideoPlayerController videoPlayerController;
  final TextEditingController ipController=TextEditingController();
  AnimationController _animationController;
  Future<void> initializeVideoPlayer()async{

    videoPlayerController=VideoPlayerController.asset("images/intruder.mp4");
    videoPlayerController.setLooping(false);
    videoPlayerController.setVolume(1.0);
    await videoPlayerController.initialize();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeVideoPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1700),
    );
    _animationController.forward();
  }

  // import 'package:http/http.dart' as http;

  Future<String> getData(String path) async {
    path="http://"+path;
    var url = Uri.parse(path);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if(response.statusCode==200)
    return response.body;
    else
      return "loading 2 ...";
  }


  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  setUpTimedFetch(){
    timer=Timer.periodic(Duration(milliseconds: 1500), (timer) async{
      // if(alert==true) {
      //  setState(() {
      //    alert = false;
      //  });
      // }
      String temp = ipController.text.toString() + "/temperature";
      String humidity = ipController.text.toString() + "/humidity";
      String pin = ipController.text.toString() + "/keypad";
      String knock = ipController.text.toString() + "/knock";

      tempReading = await getData(temp);
      humidityReading = await getData(humidity);
      pinReading = await getData(pin);
      knockReading=await getData(knock);
      if(pinReading=="WRONG PIN"&& stop==false) {
        stop=true;
        await initializeVideoPlayer();
        alert = true;
        videoPlayerController.play();
      }

      if(knockReading=="knock")
        knocking=true;

      print("hi");
        setState(()  {
        });
    });

  }
  stopTimer(){
    timer.cancel();
  }

  Widget createField(IconData icon,bool connected, String text){
    return TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      enabled: !connected,
      controller: ipController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        focusColor: Colors.white,
        hoverColor: Colors.green,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.blue[700])),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.red[700])),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.green[700])),
        prefixIcon: Icon(icon),
        hintText: text,
      ),
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[300], Colors.white],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Center(
            child:
                //Expanded(
                //   child: Image.asset('images/doctor.png'),
                // ),
                CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  toolbarHeight: 60,
                  backgroundColor: Colors.teal[800],
                  shadowColor: Colors.black,
                  //expandedHeight: 100,
                  centerTitle: true,
                  automaticallyImplyLeading: true,
                  leadingWidth: 100,
                  stretch: true,
                  title: Text(
                    'Smart Homiee',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lobster',
                      fontSize: 30,
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(child: Icon(Icons.ac_unit)),
                  ),

                  // flexibleSpace: FlexibleSpaceBar(
                  //   background: Image.asset('images/doctor.png'),
                  // ),
                ),
                SliverToBoxAdapter(
                  child: IntrinsicHeight(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.9,
                        //maximum height set to 100% of vertical height
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                margin: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white60,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Expanded(
                                          flex:5,
                                          child: createField(
                                              Icons.home_work_outlined, connected,"IP Address"),
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: LiteRollingSwitch(
                                            value: false,
                                            textOff: 'connect',
                                            textOn: 'disconnect',
                                            colorOff: Colors.blueAccent,
                                            colorOn: Colors.red,
                                            iconOff: Icons.account_tree,
                                            iconOn: Icons.account_tree_outlined,
                                            onChanged: (bool position) {
                                              if (position) {
                                                setState(()  {
                                                  firstTime=false;
                                                  connected=true;
                                                  setUpTimedFetch();
                                                });
                                              }
                                              else if (connected && !firstTime) {
                                                setState(() {
                                                  stopTimer();
                                                  connected = false;
                                                });
                                              }
                                            },


                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 35,
                                    ),
                                    connected?Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        margin: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)),
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 5,
                                        shadowColor: Colors.black,
                                        color: Colors.grey[100],
                                        child: Column(
                                          children: [
                                            Container(
                                              child: connected?ListTile(
                                              title: Text(
                                              "Temperature : "+tempReading,
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                leading: ImageIcon(
                                  AssetImage("images/splash.png"),
                                  color: Colors.green,
                                ),
                              ):null,
                                            ),

                                            SizedBox(
                                              height: 20,
                                            ),

                                            Container(
                                              child: connected?ListTile(
                                                title: Text(
                                                  "Humidity : "+humidityReading,
                                                  style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontFamily: 'Nunito',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                leading: ImageIcon(
                                                  AssetImage("images/splash.png"),
                                                  color: Colors.green,
                                                ),
                                              ):null,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            Center(
                                              child: Container(
                                                child: connected?ListTile(
                                                  title: Text(
                                                    "*data is updated every 1.5 second*",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontFamily: 'Nunito',
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  // leading: ImageIcon(
                                                  //   AssetImage("images/splash.png"),
                                                  //   color: Colors.green,
                                                  // ),
                                                ):null,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ):Text(""),

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        alert && connected?Center(
                                          child: Text("Intruder Alert !!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.red,
                                                fontSize: 25,
                                                fontFamily: "Nunito",
                                                fontWeight: FontWeight.bold)
                                            ,),
                                        ):knocking&&connected?Center(
                                          child: Text("Someone's at the door",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 25,
                                                fontFamily: "Nunito",
                                                fontWeight: FontWeight.bold)
                                            ,),
                                        ):Text(""),

                                        SizedBox(
                                          height: 35,
                                        ),
                                        alert && connected?Container(
                                          margin: EdgeInsets.all(8),
                                          child: AspectRatio(
                                            aspectRatio: videoPlayerController.value.aspectRatio,
                                            // Use the VideoPlayer widget to display the video.
                                            child: VideoPlayer(videoPlayerController),
                                          ),
                                        ):Text("")
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
