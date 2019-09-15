import 'package:flutter/animation.dart';

class RedisposableAnimationController {
  AnimationController animationController;
  bool _isDisposed = false;

  RedisposableAnimationController({this.animationController});

  dispose() {
    _isDisposed = true;
    if (!_isDisposed)
    animationController.dispose();
  }
}