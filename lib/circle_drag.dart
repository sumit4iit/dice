import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
