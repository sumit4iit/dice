import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class FingerChooser extends StatefulWidget {
  @override
  FingerChooserState createState() {
    return FingerChooserState();
  }
}

class FingerChooserState extends State<FingerChooser> {
  Map<int, ConcentricCircle> _concentricCircles =
      new Map<int, ConcentricCircle>();
  List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.deepOrangeAccent,
    Colors.cyanAccent,
    Colors.deepPurpleAccent,
    Colors.pinkAccent,
    Colors.limeAccent,
  ]..shuffle(new Random.secure());

//  ImmediateMultiDragGestureRecognizer dragGestureRecognizer =
//      new ImmediateMultiDragGestureRecognizer();

  void _onDragCancel() {
    print('Cancelling the drag');
  }

  void _onDragUpdate(DragUpdateDetails details) {
    print('Update position' + details.toString());
  }

  void _onDragEnd(DragEndDetails details) {
    print('End Drag' + details.toString());
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
//        MultiTapGestureRecognizer:
//            GestureRecognizerFactoryWithHandlers<MultiTapGestureRecognizer>(
//          () => MultiTapGestureRecognizer(),
//          (MultiTapGestureRecognizer instance) {
//            instance.onTapCancel = (int pointer) {
//              _concentricCircles.remove(pointer);
//              setState(() {});
//            };
//            instance.onTapUp = (int pointer, TapUpDetails details) {
//              _concentricCircles.remove(pointer);
//              setState(() {});
//            };
//            instance.onTapDown = (int pointer, TapDownDetails details) {
//              _concentricCircles[pointer] = ConcentricCircle(
//                  center: details.localPosition,
//                  color: _colors[pointer % _colors.length]);
//              HapticFeedback.lightImpact();
//              setState(() {});
//            };
//          },
//        ),
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                    ImmediateMultiDragGestureRecognizer>(
                () => ImmediateMultiDragGestureRecognizer(),
                (ImmediateMultiDragGestureRecognizer instance) {
          instance.onStart = (Offset d) {
            return CircleDrag(onUpdate: _onDragUpdate, onCancel: _onDragCancel, onEnd: _onDragEnd );
          };
        })
      },
      child: new Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.black,
        ),
        child: Container(
          child: CustomPaint(
            painter: new CirclePainter(
                concentricCircles: _concentricCircles.values),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  Iterable<ConcentricCircle> concentricCircles;

  CirclePainter({this.concentricCircles});

  @override
  void paint(Canvas canvas, Size size) {
    for (ConcentricCircle concentricCircle in this.concentricCircles) {
      Paint solidCirclePaint = new Paint()
        ..color = concentricCircle.color.withAlpha(90)
        ..strokeWidth = 10
        ..style = PaintingStyle.fill;
      canvas.drawCircle(concentricCircle.center, concentricCircle.innerRadius,
          solidCirclePaint);

      Paint concentricArc = new Paint()
        ..color = concentricCircle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(
          concentricCircle.center, concentricCircle.outerRadius, concentricArc);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ConcentricCircle {
  final Offset center;
  final double innerRadius;
  final double outerRadius;
  final Color color;

  ConcentricCircle(
      {this.center,
      this.innerRadius = 50,
      this.outerRadius = 60,
      this.color = Colors.blue});
}

class CircleDrag extends Drag {
  int counter;
  Offset center;
  GestureDragUpdateCallback onUpdate;
  GestureDragCancelCallback onCancel;
  GestureDragEndCallback onEnd;

  CircleDrag({this.onUpdate, this.onCancel, this.onEnd});

  @override
  void cancel() {
    onCancel();
  }

  @override
  end(DragEndDetails details) {
    onEnd(details);
  }

  @override
  void update(DragUpdateDetails details) {
    onUpdate(details);
  }
}
