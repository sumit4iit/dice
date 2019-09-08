import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

/// Signature for a callback when the pointer is in contact with the screen and has moved again
/// Unlike [GestureDragUpdateCallback] this callback also provides the id of the drag
/// so that we can, act on individual pointers
typedef GestureDragUpdateCallbackWithPointerId = void Function(
    String uuid, DragUpdateDetails details);

/// Signature for a callback when the pointer is no longer in contact with the screen
/// Unlike [GestureDragEndCallback] this callback also provides the id of the drag
/// so that we can, act on individual pointers
typedef GestureDragEndCallbackWithPointerId = void Function(
    String uuid, DragEndDetails details);

/// Signature for a callback when the drag was cancelled.
/// Unlike [GestureDragCancelCallback] this callback also provies the id of the drag
/// so that we can, act on individual pointers
typedef GestureDragCancelCallbackWithPointerId = void Function(String uuid);

class FingerChooser extends StatefulWidget {
  @override
  FingerChooserState createState() {
    return FingerChooserState();
  }
}

class FingerChooserState extends State<FingerChooser> {
  /// Keep track of the number of pointers touching the screen simultaneously
  int _fingers = 0;

  Map<String, ConcentricCircle> _concentricCircles =
      new Map<String, ConcentricCircle>();
  Uuid _uuid = new Uuid();
  int _colorIndex = 0;
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

  void _onDragCancel(String uuid) {
    _fingers--;
    setState(() {
      _concentricCircles.remove(uuid);
    });
  }

  void _onDragUpdate(String uuid, DragUpdateDetails details) {
    setState(() {
      _concentricCircles[uuid].center = details.localPosition;
    });
  }

  void _onDragEnd(String uuid, DragEndDetails details) {
    _fingers--;
    setState(() {
      _concentricCircles.remove(uuid);
    });
  }

  void _timerCallBack() {
    // Get the list of keys and randomly shuffle
    List<String> keys = _concentricCircles.keys.toList()
      ..shuffle(Random.secure());
    String selectedKey = keys.first;
    ConcentricCircle selectedFinger = _concentricCircles[selectedKey];

    _concentricCircles = new Map<String, ConcentricCircle>();
    _concentricCircles[selectedKey] = selectedFinger;
    setState(() {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                    ImmediateMultiDragGestureRecognizer>(
                () => ImmediateMultiDragGestureRecognizer(),
                (ImmediateMultiDragGestureRecognizer instance) {
          instance.onStart = (Offset offset) {
            HapticFeedback.lightImpact();
            String id = _uuid.v1();
            CircleDrag circleDrag = new CircleDrag(
                uuid: id,
                onUpdate: _onDragUpdate,
                onCancel: _onDragCancel,
                onEnd: _onDragEnd);

            _concentricCircles[id] = ConcentricCircle(
                center: offset, color: _colors[_colorIndex++ % _colors.length]);

            _fingers++;
            if (_fingers == 3) {
              new Timer(new Duration(seconds: 4), _timerCallBack);
            }
            return circleDrag;
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
            painter:
                new CirclePainter(concentricCircles: _concentricCircles.values),
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
  Offset center;
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
  String uuid;
  GestureDragUpdateCallbackWithPointerId onUpdate;
  GestureDragCancelCallbackWithPointerId onCancel;
  GestureDragEndCallbackWithPointerId onEnd;

  CircleDrag({this.uuid, this.onUpdate, this.onCancel, this.onEnd});

  @override
  void cancel() {
    onCancel(uuid);
  }

  @override
  end(DragEndDetails details) {
    onEnd(uuid, details);
  }

  @override
  void update(DragUpdateDetails details) {
    onUpdate(uuid, details);
  }
}