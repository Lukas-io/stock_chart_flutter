import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'multi_drag_gesture.dart';

typedef GestureMultiDragUpdateCallback = void Function(
    Offset initialPosition, Offset latestPosition, double delta);
typedef GestureMultiDragEndCallback = void Function(
    Offset initialPosition, Offset latestPosition, double delta);
typedef GestureMultiDragCancelCallback = void Function();

/// This is an advanced version of normal Gesture detector.
///
/// This detector includes MultiDrag Gestures along with most of the
/// normal gestures supported by [GestureDetector] widget.
///

class CustomGestureDetector extends StatefulWidget {
  /// The widget which needs to access the gestures
  final Widget? child;

  /// This is the number of pointers which is required to
  /// at least consider a gesture
  ///
  /// It can range from minimum 1 to max pointers supported by the [MultiDragGestureRecognizer]
  ///
  /// If the value is set to 2, then the the gesture recognizer
  /// will handle simple touch gestures (requiring only one pointer) and
  /// multi touch gestures (requiring more than one pointers).
  ///
  final int? supportedPointerCount;

  /// A [HitTestBehavior] value is used to define how the user's touch
  /// event should be handled on detection.
  final HitTestBehavior? behaviour;

  /// A [DragStartBehavior] value is used to define if the initial value
  /// of a drag gesture will be user's first touch or the position when drag
  /// event actually starts/detected.
  final DragStartBehavior dragStartBehavior;

  /// A callback? for simple horizontal drag start gesture
  final GestureDragStartCallback? onHorizontalDragStart;

  /// A callback? for simple horizontal drag update gesture
  final GestureDragUpdateCallback? onHorizontalDragUpdate;

  /// A callback? for simple horizontal drag end gesture
  final GestureDragEndCallback? onHorizontalDragEnd;

  /// A callback? for simple horizontal drag cancel gesture
  final GestureDragCancelCallback? onHorizontalDragCancel;

  /// A callback? for simple vertical drag start gesture
  final GestureDragStartCallback? onVerticalDragStart;

  /// A callback? for simple vertical drag update gesture
  final GestureDragUpdateCallback? onVerticalDragUpdate;

  /// A callback? for simple vertical drag end gesture
  final GestureDragEndCallback? onVerticalDragEnd;

  /// A callback? for simple vertical drag cancel gesture
  final GestureDragCancelCallback? onVerticalDragCancel;

  /// A callback? for multi touch horizontal drag start gesture
  final GestureMultiDragStartCallback? onMultiHorizontalDragStart;

  /// A callback? for multi touch horizontal drag update gesture
  final GestureMultiDragUpdateCallback? onMultiHorizontalDragUpdate;

  /// A callback? for multi touch horizontal drag end gesture
  final GestureMultiDragEndCallback? onMultiHorizontalDragEnd;

  /// A callback? for multi touch horizontal drag cancel gesture
  final GestureMultiDragCancelCallback? onMultiHorizontalDragCancel;

  /// A callback? for multi touch vertical drag start gesture
  final GestureMultiDragStartCallback? onMultiVerticalDragStart;

  /// A callback? for multi touch vertical drag update gesture
  final GestureMultiDragUpdateCallback? onMultiVerticalDragUpdate;

  /// A callback? for multi touch vertical drag end gesture
  final GestureMultiDragEndCallback? onMultiVerticalDragEnd;

  /// A callback? for multi touch vertical drag cancel gesture
  final GestureMultiDragCancelCallback? onMultiVerticalDragCancel;

  /// A callback? for simple PAN start gesture
  final GestureDragStartCallback? onPanStart;

  /// A callback? for simple PAN update gesture
  final GestureDragUpdateCallback? onPanUpdate;

  /// A callback? for simple PAN end gesture
  final GestureDragEndCallback? onPanEnd;

  /// A callback? for simple PAN cancel gesture
  final GestureDragCancelCallback? onPanCancel;

  /// A callback? for simple scale start gesture
  final GestureScaleStartCallback? onScaleStart;

  /// A callback? for simple scale update gesture
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// A callback? for simple scale end gesture
  final GestureScaleEndCallback? onScaleEnd;

  /// A callback? for a double tap gesture
  final GestureTapCallback? onDoubleTap;

  /// A callback? for a long press gesture
  final GestureLongPressCallback? onLongPress;

  /// Public constructor
  const CustomGestureDetector({
    super.key,
    this.supportedPointerCount = 1,
    this.child,
    this.behaviour,
    this.onDoubleTap,
    this.onLongPress,
    this.onMultiHorizontalDragStart,
    this.onMultiHorizontalDragUpdate,
    this.onMultiHorizontalDragEnd,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onMultiHorizontalDragCancel,
    this.onMultiVerticalDragStart,
    this.onMultiVerticalDragUpdate,
    this.onMultiVerticalDragEnd,
    this.onMultiVerticalDragCancel,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(child != null),
        assert(supportedPointerCount != null && supportedPointerCount > 0);

  @override
  State<CustomGestureDetector> createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector> {
  int? get supportedPointerCount => widget.supportedPointerCount;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    if (widget.onDoubleTap != null) {
      _addDoubleTapGesture(gestures, widget.onDoubleTap!);
    }

    if (widget.onLongPress != null) {
      _addLongPressGesture(gestures, widget.onLongPress!);
    }
    if (widget.onPanStart != null ||
        widget.onPanUpdate != null ||
        widget.onPanEnd != null ||
        widget.onPanCancel != null) {
      _addPanGesture(
        gestures,
        widget.onPanStart,
        widget.onPanUpdate,
        widget.onPanEnd,
        widget.onPanCancel,
        widget.dragStartBehavior,
      );
    }

    if (widget.onScaleStart != null ||
        widget.onScaleUpdate != null ||
        widget.onScaleEnd != null) {
      _addScaleGesture(gestures, widget.onScaleStart!, widget.onScaleUpdate!,
          widget.onScaleEnd!, widget.dragStartBehavior);
    }

    if (supportedPointerCount! > 1) {
      if (widget.onMultiHorizontalDragStart != null ||
          widget.onMultiHorizontalDragUpdate != null ||
          widget.onMultiHorizontalDragEnd != null ||
          widget.onMultiHorizontalDragCancel != null ||
          widget.onHorizontalDragStart != null ||
          widget.onHorizontalDragUpdate != null ||
          widget.onHorizontalDragEnd != null ||
          widget.onHorizontalDragCancel != null) {
        _addMultiHorizontalDragGesture(
          gestures,
          widget.onMultiHorizontalDragStart,
          widget.onMultiHorizontalDragUpdate,
          widget.onMultiHorizontalDragEnd,
          widget.onMultiHorizontalDragCancel,
          widget.onHorizontalDragStart,
          widget.onHorizontalDragUpdate,
          widget.onHorizontalDragEnd,
          widget.onHorizontalDragCancel,
        );
      }
      if (widget.onMultiVerticalDragStart != null ||
          widget.onMultiVerticalDragUpdate != null ||
          widget.onMultiVerticalDragEnd != null ||
          widget.onMultiVerticalDragCancel != null ||
          widget.onVerticalDragStart != null ||
          widget.onVerticalDragUpdate != null ||
          widget.onVerticalDragEnd != null ||
          widget.onVerticalDragCancel != null) {
        _addMultiVerticalDragGesture(
          gestures,
          widget.onMultiVerticalDragStart,
          widget.onMultiVerticalDragUpdate,
          widget.onMultiVerticalDragEnd,
          widget.onMultiVerticalDragCancel,
          widget.onVerticalDragStart,
          widget.onVerticalDragUpdate,
          widget.onVerticalDragEnd,
          widget.onVerticalDragCancel,
        );
      }
    } else {
      if (widget.onVerticalDragStart != null ||
          widget.onVerticalDragUpdate != null ||
          widget.onVerticalDragEnd != null ||
          widget.onVerticalDragCancel != null) {
        _addVerticalDragGesture(
          gestures,
          widget.onVerticalDragStart,
          widget.onVerticalDragUpdate,
          widget.onVerticalDragEnd,
          widget.onVerticalDragCancel,
          widget.dragStartBehavior,
        );
      }
      if (widget.onHorizontalDragStart != null ||
          widget.onHorizontalDragUpdate != null ||
          widget.onHorizontalDragEnd != null ||
          widget.onHorizontalDragCancel != null) {
        _addHorizontalDragGesture(
            gestures,
            widget.onHorizontalDragStart,
            widget.onHorizontalDragUpdate,
            widget.onHorizontalDragEnd,
            widget.onHorizontalDragCancel,
            widget.dragStartBehavior);
      }
    }

    return RawGestureDetector(
      behavior: widget.behaviour,
      gestures: gestures,
      child: widget.child,
    );
  }

  void _addDoubleTapGesture(
      Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
      GestureTapCallback? onDoubleTap) {
    gestures[DoubleTapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
      () => DoubleTapGestureRecognizer(debugOwner: this),
      (DoubleTapGestureRecognizer instance) {
        instance.onDoubleTap = onDoubleTap;
      },
    );
  }

  void _addLongPressGesture(
      Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
      GestureLongPressCallback? onLongPress) {
    gestures[LongPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
      () => LongPressGestureRecognizer(debugOwner: this),
      (LongPressGestureRecognizer instance) {
        instance.onLongPress = onLongPress;
      },
    );
  }

  void _addVerticalDragGesture(
      Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
      GestureDragStartCallback? onVerticalDragStart,
      GestureDragUpdateCallback? onVerticalDragUpdate,
      GestureDragEndCallback? onVerticalDragEnd,
      GestureDragCancelCallback? onVerticalDragCancel,
      DragStartBehavior dragStartBehavior) {
    gestures[VerticalDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
      () => VerticalDragGestureRecognizer(debugOwner: this),
      (VerticalDragGestureRecognizer instance) {
        instance
          ..onStart = onVerticalDragStart
          ..onUpdate = onVerticalDragUpdate
          ..onEnd = onVerticalDragEnd
          ..onCancel = onVerticalDragCancel
          ..dragStartBehavior = dragStartBehavior;
      },
    );
  }

  void _addHorizontalDragGesture(
      Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
      GestureDragStartCallback? onHorizontalDragStart,
      GestureDragUpdateCallback? onHorizontalDragUpdate,
      GestureDragEndCallback? onHorizontalDragEnd,
      GestureDragCancelCallback? onHorizontalDragCancel,
      DragStartBehavior dragStartBehavior) {
    gestures[HorizontalDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
      () => HorizontalDragGestureRecognizer(debugOwner: this),
      (HorizontalDragGestureRecognizer instance) {
        instance
          ..onStart = onHorizontalDragStart
          ..onUpdate = onHorizontalDragUpdate
          ..onEnd = onHorizontalDragEnd
          ..onCancel = onHorizontalDragCancel
          ..dragStartBehavior = dragStartBehavior;
      },
    );
  }

  void _addPanGesture(
      Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
      GestureDragStartCallback? onPanStart,
      GestureDragUpdateCallback? onPanUpdate,
      GestureDragEndCallback? onPanEnd,
      GestureDragCancelCallback? onPanCancel,
      DragStartBehavior dragStartBehavior) {
    gestures[PanGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
      () => PanGestureRecognizer(debugOwner: this),
      (PanGestureRecognizer instance) {
        instance
          ..onStart = onPanStart
          ..onUpdate = onPanUpdate
          ..onEnd = onPanEnd
          ..onCancel = onPanCancel
          ..dragStartBehavior = dragStartBehavior;
      },
    );
  }

  void _addScaleGesture(
      Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
      GestureScaleStartCallback? onScaleStart,
      GestureScaleUpdateCallback? onScaleUpdate,
      GestureScaleEndCallback? onScaleEnd,
      DragStartBehavior dragStartBehavior) {
    gestures[ScaleGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      () => ScaleGestureRecognizer(debugOwner: this),
      (ScaleGestureRecognizer instance) {
        instance
          ..onStart = onScaleStart
          ..onUpdate = onScaleUpdate
          ..onEnd = onScaleEnd;
      },
    );
  }

  void _addMultiHorizontalDragGesture(
    Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
    GestureMultiDragStartCallback? onMultiHorizontalDragStart,
    GestureMultiDragUpdateCallback? onMultiHorizontalDragUpdate,
    GestureMultiDragEndCallback? onMultiHorizontalDragEnd,
    GestureMultiDragCancelCallback? onMultiHorizontalDragCancel,
    GestureDragStartCallback? onHorizontalDragStart,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragEndCallback? onHorizontalDragEnd,
    GestureDragCancelCallback? onHorizontalDragCancel,
  ) {
    gestures[CustomHorizontalMultiDragRecognizer] =
        getMultiHorizontalDragGestureRecognizer(
      this,
      onMultiHorizontalDragStart: onMultiHorizontalDragStart,
      onMultiHorizontalDragUpdate: onMultiHorizontalDragUpdate,
      onMultiHorizontalDragEnd: onMultiHorizontalDragEnd,
      onMultiHorizontalDragCancel: onMultiHorizontalDragCancel,
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragCancel: onHorizontalDragCancel,
      supportedPointerCount: supportedPointerCount,
    );
  }

  void _addMultiVerticalDragGesture(
    Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures,
    GestureMultiDragStartCallback? onMultiVerticalDragStart,
    GestureMultiDragUpdateCallback? onMultiVerticalDragUpdate,
    GestureMultiDragEndCallback? onMultiVerticalDragEnd,
    GestureMultiDragCancelCallback? onMultiVerticalDragCancel,
    GestureDragStartCallback? onVerticalDragStart,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    GestureDragEndCallback? onVerticalDragEnd,
    GestureDragCancelCallback? onVerticalDragCancel,
  ) {
    print('reached');
    gestures[CustomVerticalMultiDragRecognizer] =
        getMultiVerticalDragGestureRecognizer(
      this,
      supportedPointerCount: supportedPointerCount,
      onMultiVerticalDragStart: onMultiVerticalDragStart,
      onMultiVerticalDragUpdate: onMultiVerticalDragUpdate,
      onMultiVerticalDragEnd: onMultiVerticalDragEnd,
      onMultiVerticalDragCancel: onMultiVerticalDragCancel,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      onVerticalDragCancel: onVerticalDragCancel,
    );
  }
}
