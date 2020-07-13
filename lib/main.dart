import 'dart:async';

import 'package:flutter/material.dart';
import 'radio.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sapin Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Sapin Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var maListDeRadio = [
    new Radios('Fun Radio', 'La radio du son dancefloor', 'assets/funradio.png', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Radios("Mouv'", "Mouv' on it", 'assets/mouv.png', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Radios maRadioActuelle;
  Duration position =  new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;


  @override
  void initState() {
    super.initState();
    maRadioActuelle = maListDeRadio[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(maRadioActuelle.imagePath),
              ),
            ),
            textAvecStyle(maRadioActuelle.titre, 1.5),
            textAvecStyle(maRadioActuelle.slogan, 1.0),
            new Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((statut == PlayerState.playing) ?Icons.pause: Icons.play_arrow, 45.0, (statut == PlayerState.playing) ? ActionMusic.pause: ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],

            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textAvecStyle(fromDuration(position), 0.9),
                textAvecStyle(fromDuration(duree), 0.8),
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 22.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    Duration nouvelleDuration = new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                    audioPlayer.seek(d);
                  });
                }
            )

          ],
        ),
      ),

    );
  }

  IconButton bouton (IconData icone, double scale, ActionMusic action) {
    return new IconButton(
      iconSize: 50.0,
        color: Colors.white,
        icon: new Icon(icone),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              play();
            break;
            case ActionMusic.pause:
              pause();
            break;
            case ActionMusic.rewind:
             rewind();
            break;
            case ActionMusic.forward:
            forward();
            break;

  }
    });

  }

  Text textAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
            (p) => setState(() => position = p)
    );

    stateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (s == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (msg) {
      print('$msg');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(maRadioActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
    if (index == maListDeRadio.length - 1) {
      index = 0;
    }else {
      index++;
    }
    maRadioActuelle = maListDeRadio[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();

  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = maListDeRadio.length - 1;
      }else {
        index--;
      }
      maRadioActuelle = maListDeRadio[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration (Duration duree) {
    print(duree);
    return duree.toString().split('.').first;
  }
}
enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused,
}
