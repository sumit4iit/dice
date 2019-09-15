import 'dart:async';

import 'package:dice/redisposable_animation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'concentric_circle.dart';
import 'circle_drag.dart';

typedef PointerTouchAnimationCallback = void Function(
    String uuid, double value);

class FingerChooser extends StatefulWidget {
  @override
  _FingerChooserState createState() {
    return _FingerChooserState();
  }
}

class _FingerChooserState extends State<FingerChooser>
    with TickerProviderStateMixin {
  /// Keep track of the number of pointers touching the screen simultaneously
  int _fingers = 0;

  Map<String, ConcentricCircle> _concentricCircles =
      new Map<String, ConcentricCircle>();

  Map<String, AnimationController> _circlePopAnimator =
      new Map<String, AnimationController>();

  RedisposableAnimationController _winnerController;
  Timer _winningTimer;

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

  bool _removeFinger(String uuid) {
    _fingers--;

    // if all fingers have been removed from the screen
    if (_fingers == 0) {
      _winningTimer.cancel();
      if (_winnerController != null) _winnerController.dispose();
    }

    _circlePopAnimator[uuid].dispose();
    _circlePopAnimator.remove(uuid);

    return _concentricCircles.remove(uuid) != null;
  }

  void _addFinger(String uuid, ConcentricCircle concentricCircle) {
    _fingers++;
    _concentricCircles[uuid] = concentricCircle;

    if (_fingers == 2) {
      _winningTimer = new Timer(new Duration(seconds: 2), _winnerTimerCallBack);
    }
  }

  /// Callback for when the drag gesture has been cancelled for the current
  /// pointer
  void _onDragCancel(String uuid) {
    if (_removeFinger(uuid)) {
      setState(() {});
    }
  }

  /// Callback when the drag gesture has ended and the pointer is no longer
  /// in contact with the screen
  void _onDragEnd(String uuid, DragEndDetails details) {
    _onDragCancel(uuid);
  }

  /// Callback for when the pointer is in contact with the screen and is moving
  void _onDragUpdate(String uuid, DragUpdateDetails details) {
    ConcentricCircle concentricCircle = _concentricCircles[uuid];
    if (concentricCircle != null) {
      concentricCircle.center = details.localPosition;
      setState(() {});
    }
  }

  /// Timer callback to decide the winner pointer among the ones which are still
  /// in contact with the screen
  void _winnerTimerCallBack() {
    // Get the list of keys and randomly shuffle
    List<String> keys = _concentricCircles.keys.toList()
      ..shuffle(Random.secure());

    if (keys.isNotEmpty) {
      String selectedKey = keys.first;
      ConcentricCircle selectedFinger = _concentricCircles[selectedKey];

      _concentricCircles.clear();
      _concentricCircles[selectedKey] = selectedFinger;
      _winnerAnimate(selectedFinger);
    }
  }

  void _winnerAnimate(ConcentricCircle concentricCircle) {
    HapticFeedback.heavyImpact();
    AnimationController animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _winnerController = new RedisposableAnimationController(
        animationController: animationController);
    Animation<double> winnerSelector = new Tween<double>(
            begin: 70,
            end: max(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height))
        .animate(new CurvedAnimation(
            parent: animationController, curve: Curves.easeInCirc));
    winnerSelector.addListener(() {
      setState(() {
        concentricCircle.innerRadius = winnerSelector.value;
      });
    });

    animationController.forward();
  }

  void _animateOnTouch(String id, ConcentricCircle concentricCircle) {
    // Add animation controller to control the size of the radius
    AnimationController radiusController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));

    Animation<double> circlePopAnimation = new Tween<double>(begin: 0, end: 1)
        .animate(new CurvedAnimation(
            parent: radiusController, curve: Curves.bounceOut));
    _circlePopAnimator[id] = radiusController;
    circlePopAnimation.addListener(() {
      setState(() {
        concentricCircle.innerRadius = circlePopAnimation.value * 70;
        concentricCircle.outerRadius = circlePopAnimation.value * 50;
        concentricCircle.strokeWidth = circlePopAnimation.value * 10;
      });
    });
    radiusController.forward();
  }

  Drag _onTouchStart(Offset offset) {
    HapticFeedback.lightImpact();
    String id = _uuid.v1();
    CircleDrag circleDrag = new CircleDrag(
        uuid: id,
        onUpdate: _onDragUpdate,
        onCancel: _onDragCancel,
        onEnd: _onDragEnd);

    ConcentricCircle concentricCircle = ConcentricCircle(
        center: offset, color: _colors[_colorIndex++ % _colors.length]);

    _addFinger(id, concentricCircle);

    _animateOnTouch(id, concentricCircle);
    return circleDrag;
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
          instance.onStart = _onTouchStart;
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

  @override
  void dispose() {
    super.dispose();

    // Cleanup leftover animation controllers
//    _winnerController.dispose();
    for (AnimationController controller in _circlePopAnimator.values) {
      controller.dispose();
    }
  }
}
