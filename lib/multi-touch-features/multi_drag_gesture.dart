import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'custom_gesture_detector.dart';
import 'delayed_process_handler.dart';

/// Class for recognizing multi touch vertical gestures
class CustomVerticalMultiDragRecognizer
    extends VerticalMultiDragGestureRecognizer {
  /// Amount of current simultaneous pointers/touches
  int _pointerCount = 0;

  /// Amount of minimum required simultaneous pointers/touches
  final int supportedPointerCount;

  /// A delayed process handler to execute single touch alternative
  /// of a gesture if multi touch gesture's minimum was not recognized properly
  /// within a limited amount of time
  DelayedProcessHandler? _delayedProcessHandler;

  /// Multi touch vertical drag start
  final GestureMultiDragStartCallback onMultiVerticalDragStart;

  /// Multi touch vertical drag update
  final GestureMultiDragUpdateCallback onMultiVerticalDragUpdate;

  /// Multi touch vertical drag end
  final GestureMultiDragEndCallback onMultiVerticalDragEnd;

  /// Multi touch vertical drag cancel
  final GestureMultiDragCancelCallback onMultiVerticalDragCancel;

  /// Single touch vertical drag start
  final GestureDragStartCallback onVerticalDragStart;

  /// Single touch vertical drag update
  final GestureDragUpdateCallback onVerticalDragUpdate;

  /// Single touch vertical drag end
  final GestureDragEndCallback onVerticalDragEnd;

  /// Single touch vertical drag cancel
  final GestureDragCancelCallback onVerticalDragCancel;

  /// Public constructor
  CustomVerticalMultiDragRecognizer(
      debugOwner,
      this.supportedPointerCount,
      this.onMultiVerticalDragStart,
      this.onMultiVerticalDragUpdate,
      this.onMultiVerticalDragEnd,
      this.onMultiVerticalDragCancel,
      this.onVerticalDragStart,
      this.onVerticalDragUpdate,
      this.onVerticalDragEnd,
      this.onVerticalDragCancel)
      : super(debugOwner: debugOwner) {
    onStart = _handleMultiDragOnStart;
  }

  Drag _handleMultiDragOnStart(Offset position) {
    if (_pointerCount < supportedPointerCount) {
      _pointerCount++;
      _delayedProcessHandler!.startWaiting();
    }
    return ItemDrag(_onDragUpdate, _onDragEnd, _onCancel);
  }

  void _onDragUpdate(
    Offset initialPosition,
    Offset latestPosition,
    double delta,
  ) {
    if (_pointerCount == 1) {
      if (onVerticalDragUpdate == null) {
        return;
      }
      onVerticalDragUpdate(DragUpdateDetails(
          globalPosition: latestPosition,
          delta: Offset(0.0, delta),
          primaryDelta: delta));
    } else {
      onMultiVerticalDragUpdate(initialPosition, latestPosition, delta);
    }
  }

  void _onDragEnd(
    Offset initialPosition,
    Offset latestPosition,
    double delta,
  ) {
    if (_pointerCount == 1) {
      if (onVerticalDragEnd == null) {
        return;
      }
      onVerticalDragEnd(DragEndDetails(
          velocity: Velocity(
              pixelsPerSecond:
                  fromDifference(initialPosition, latestPosition))));
    } else {
      if (onMultiVerticalDragEnd == null) {
        return;
      }
      onMultiVerticalDragEnd(initialPosition, latestPosition, delta);
    }
    _pointerCount = 0;
  }

  void _onCancel() {
    if (_pointerCount == 1) {
      if (onVerticalDragCancel == null) {
        return;
      }
      onVerticalDragCancel();
    } else {
      if (onMultiVerticalDragCancel == null) {
        return;
      }
      onMultiVerticalDragCancel();
    }
    _pointerCount = 0;
  }

  /// Method to confirm that the minimum pointer requirements is matched
  void confirmAdditionalPointers() {
    if (_pointerCount <= supportedPointerCount) {
      // do something when minimum pointer requirements is not matched
    }
  }
}

/// Class for recognizing multi touch vertical gestures
class CustomHorizontalMultiDragRecognizer
    extends HorizontalMultiDragGestureRecognizer {
  /// Amount of current simultaneous pointers/touches
  int pointerCount = 0;

  /// Amount of minimum required simultaneous pointers/touches
  final int supportedPointerCount;

  /// A delayed process handler to execute single touch alternative
  /// of a gesture if multi touch gesture's minimum was not recognized properly
  /// within a limited amount of time
  DelayedProcessHandler? _delayedProcessHandler;

  /// Multi touch horizontal drag start
  final GestureMultiDragStartCallback onMultiHorizontalDragStart;

  /// Multi touch horizontal drag update
  final GestureMultiDragUpdateCallback onMultiHorizontalDragUpdate;

  /// Multi touch horizontal drag end
  final GestureMultiDragEndCallback onMultiHorizontalDragEnd;

  /// Multi touch horizontal drag cancel
  final GestureMultiDragCancelCallback onMultiHorizontalDragCancel;

  /// Single touch horizontal drag start
  final GestureDragStartCallback onHorizontalDragStart;

  /// Single touch horizontal drag update
  final GestureDragUpdateCallback onHorizontalDragUpdate;

  /// Single touch horizontal drag end
  final GestureDragEndCallback onHorizontalDragEnd;

  /// Single touch horizontal drag cancel
  final GestureDragCancelCallback onHorizontalDragCancel;

  /// Public constructor
  CustomHorizontalMultiDragRecognizer(
    Object debugOwner,
    this.onMultiHorizontalDragStart,
    this.onMultiHorizontalDragUpdate,
    this.onMultiHorizontalDragEnd,
    this.onMultiHorizontalDragCancel,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.supportedPointerCount,
  )   : assert(onMultiHorizontalDragStart != null ||
            onMultiHorizontalDragUpdate != null),
        super(debugOwner: debugOwner) {
    onStart = _handleMultiDragOnStart;
  }

  Drag _handleMultiDragOnStart(Offset position) {
    if (pointerCount < supportedPointerCount) {
      pointerCount++;
      _delayedProcessHandler!.startWaiting();
    }

    return ItemDrag(_onDragUpdate, _onDragEnd, _onCancel);
  }

  void _onDragUpdate(
    Offset initialPosition,
    Offset latestPosition,
    double delta,
  ) {
    if (pointerCount == 1) {
      if (onHorizontalDragUpdate == null) {
        return;
      }
      onHorizontalDragUpdate(DragUpdateDetails(
          globalPosition: latestPosition,
          delta: Offset(delta, 0.0),
          primaryDelta: delta));
    } else {
      onMultiHorizontalDragUpdate(initialPosition, latestPosition, delta);
    }
  }

  void _onDragEnd(
    Offset initialPosition,
    Offset latestPosition,
    double delta,
  ) {
    if (pointerCount == 1) {
      if (onHorizontalDragEnd == null) {
        return;
      }
      onHorizontalDragEnd(DragEndDetails(
          velocity: Velocity(
              pixelsPerSecond:
                  fromDifference(initialPosition, latestPosition))));
    } else {
      if (onMultiHorizontalDragEnd == null) {
        return;
      }
      onMultiHorizontalDragEnd(initialPosition, latestPosition, delta);
    }
    pointerCount = 0;
  }

  void _onCancel() {
    if (pointerCount == 1) {
      if (onHorizontalDragCancel == null) {
        return;
      }
      onHorizontalDragCancel();
    } else {
      if (onMultiHorizontalDragCancel == null) {
        return;
      }
      onMultiHorizontalDragCancel();
    }
    pointerCount = 0;
  }

  /// Method to confirm that the minimum pointer requirements is matched
  void confirmAdditionalPointers() {
    if (pointerCount == supportedPointerCount) {
      pointerCount = 0;
    }
  }
}

/// This Class is required to detect single or simultaneous multi touch
/// events on the surface
class ItemDrag extends Drag {
  Offset? _initialPosition;
  Offset? _latestPosition;
  double _delta = 0;

  /// A drag update gesture, it can be any of following:
  ///  - vertical multi drag update
  ///  - vertical single drag update
  ///  - horizontal multi drag update
  ///  - horizontal single drag update
  final GestureMultiDragUpdateCallback onDragUpdate;

  /// A drag update gesture, it can be any of following:
  ///  - vertical multi drag end
  ///  - vertical single drag end
  ///  - horizontal multi drag end
  ///  - horizontal single drag end
  final GestureMultiDragEndCallback onDragEnd;

  /// A drag update gesture, it can be any of following:
  ///  - vertical multi drag cancel
  ///  - vertical single drag cancel
  ///  - horizontal multi drag cancel
  ///  - horizontal single drag cancel
  final GestureMultiDragCancelCallback onCancel;

  /// public constructor
  ItemDrag(this.onDragUpdate, this.onDragEnd, this.onCancel);

  @override
  void update(DragUpdateDetails details) {
    _latestPosition = details.globalPosition;
    // delta = details.delta.dx;
    _delta = _latestPosition!.dx - _initialPosition!.dx;
    onDragUpdate(_initialPosition!, _latestPosition!, _delta);
    super.update(details);
  }

  @override
  void cancel() {
    onCancel();
    reset();
    super.cancel();
  }

  @override
  void end(DragEndDetails details) {
    onDragEnd(_initialPosition!, _latestPosition!, _delta);
    reset();
    super.end(details);
  }

  /// Method to set the gesture data to it's initial state
  void reset() {
    _initialPosition = null;
    _latestPosition = null;
    _delta = 0;
  }
}

/// Method to get a multi horizontal drag gesture
GestureRecognizerFactoryWithHandlers<CustomHorizontalMultiDragRecognizer>
    getMultiHorizontalDragGestureRecognizer(
  Object debugOwner, {
  GestureMultiDragStartCallback? onMultiHorizontalDragStart,
  GestureMultiDragUpdateCallback? onMultiHorizontalDragUpdate,
  GestureMultiDragEndCallback? onMultiHorizontalDragEnd,
  GestureMultiDragCancelCallback? onMultiHorizontalDragCancel,
  GestureDragStartCallback? onHorizontalDragStart,
  GestureDragUpdateCallback? onHorizontalDragUpdate,
  GestureDragEndCallback? onHorizontalDragEnd,
  GestureDragCancelCallback? onHorizontalDragCancel,
  int? supportedPointerCount,
}) {
  return GestureRecognizerFactoryWithHandlers<
      CustomHorizontalMultiDragRecognizer>(
    () => CustomHorizontalMultiDragRecognizer(
      debugOwner,
      onMultiHorizontalDragStart!,
      onMultiHorizontalDragUpdate!,
      onMultiHorizontalDragEnd!,
      onMultiHorizontalDragCancel!,
      onHorizontalDragStart!,
      onHorizontalDragUpdate!,
      onHorizontalDragEnd!,
      onHorizontalDragCancel!,
      supportedPointerCount!,
    ),
    (CustomHorizontalMultiDragRecognizer instance) {},
  );
}

/// Method to get a multi vertical drag gesture
GestureRecognizerFactoryWithHandlers<CustomVerticalMultiDragRecognizer>
    getMultiVerticalDragGestureRecognizer(
  Object debugOwner, {
  GestureMultiDragStartCallback? onMultiVerticalDragStart,
  GestureMultiDragUpdateCallback? onMultiVerticalDragUpdate,
  GestureMultiDragEndCallback? onMultiVerticalDragEnd,
  GestureMultiDragCancelCallback? onMultiVerticalDragCancel,
  GestureDragStartCallback? onVerticalDragStart,
  GestureDragUpdateCallback? onVerticalDragUpdate,
  GestureDragEndCallback? onVerticalDragEnd,
  GestureDragCancelCallback? onVerticalDragCancel,
  int? supportedPointerCount,
}) {
  return GestureRecognizerFactoryWithHandlers<
      CustomVerticalMultiDragRecognizer>(
    () => CustomVerticalMultiDragRecognizer(
      debugOwner,
      supportedPointerCount!,
      onMultiVerticalDragStart!,
      onMultiVerticalDragUpdate!,
      onMultiVerticalDragEnd!,
      onMultiVerticalDragCancel!,
      onVerticalDragStart!,
      onVerticalDragUpdate!,
      onVerticalDragEnd!,
      onVerticalDragCancel!,
    ),
    (CustomVerticalMultiDragRecognizer instance) {},
  );
}

/// a Method to find Difference in offset based on given [initial] and [latest]
/// offset values
Offset fromDifference(Offset initial, Offset latest) {
  return Offset((latest.dx - initial.dx), (latest.dy - initial.dy));
}
