import 'package:flutter/material.dart';
import 'tap_circles.dart';
/*
CoinFlip

This planned:

Divide teams
Order
Select First

 */

void main() => runApp(MaterialApp(
      home: FingerChooser(),
    ));

// The StatefulWidget's job is to take data and create a State class.
// In this case, the widget takes a title, and creates a _MyHomePageState.
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// The State class is responsible for two things: holding some data you can
// update and building the UI using that data.
class _MyHomePageState extends State<MyHomePage> {
  double _width = 100;
  double _height = 100;
  double _border_radius = 10;
  Color color = Colors.blue;
  Duration _duration = new Duration(seconds: 10);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          print("Tap Detectd");
          setState(() {
            _width = 10;
            _height = 10;
          });
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => FingerChooser()));
        },
        child: Center(
            child: AnimatedContainer(
              curve: Curves.bounceIn,
          duration: _duration,
          width: _width,
          height: _height,
//          color: color,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(_border_radius)),
          ),
        )),
      ),
    );
  }
}
