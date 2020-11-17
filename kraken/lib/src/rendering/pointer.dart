/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/gesture.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

mixin RenderPointerListenerMixin on RenderBox {
  /// Called when a pointer comes into contact with the screen (for touch
  /// pointers), or has its button pressed (for mouse pointers) at this widget's
  /// location.
  PointerDownEventListener onPointerDown;

  /// Called when a pointer that triggered an [onPointerDown] changes position.
  PointerMoveEventListener onPointerMove;

  /// Called when a pointer that triggered an [onPointerDown] is no longer in
  /// contact with the screen.
  PointerUpEventListener onPointerUp;

  /// Called when the input from a pointer that triggered an [onPointerDown] is
  /// no longer directed towards this receiver.
  PointerCancelEventListener onPointerCancel;

  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener onPointerSignal;

  GestureClickCallback onClick;

  /// called when click
  void initPointerCallback() {
    _recognizer.onClick = onClick;
  }

  KrakenClickGestureRecognizer _recognizer = KrakenClickGestureRecognizer();

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    /// addPointer when point down
    if (event is PointerDownEvent) {
      _recognizer.addPointer(event);
    }

    if (onPointerDown != null && event is PointerDownEvent)
      return onPointerDown(event);
    if (onPointerMove != null && event is PointerMoveEvent)
      return onPointerMove(event);
    if (onPointerUp != null && event is PointerUpEvent)
      return onPointerUp(event);
    if (onPointerCancel != null && event is PointerCancelEvent)
      return onPointerCancel(event);
    if (onPointerSignal != null && event is PointerSignalEvent)
      return onPointerSignal(event);

  }
}
