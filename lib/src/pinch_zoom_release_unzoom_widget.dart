import 'package:flutter/material.dart';
import 'package:pinch_zoom_release_unzoom/src/pinch_zoom_logger.dart';

class PinchZoomReleaseUnzoomWidget extends StatefulWidget {
  static const Duration defaultResetDuration = Duration(milliseconds: 200);

  /// Create an PinchZoomReleaseUnzoomWidget,
  /// remeber that is just a little bit of customization over an interactive viewer
  ///
  /// * [child] is the widget used for zooming.
  /// This parameter is required because without a child there is nothing to zoom on
  const PinchZoomReleaseUnzoomWidget({
    required this.child,
    this.buildContextOverlayState,
    this.zoomChild,
    this.resetDuration = defaultResetDuration,
    this.resetCurve = Curves.ease,
    this.boundaryMargin = EdgeInsets.zero,
    this.clipBehavior = Clip.none,
    this.minScale = 0.8,
    this.maxScale = 8,
    this.useOverlay = true,
    this.rootOverlay = false,
    this.maxOverlayOpacity = 0.5,
    this.overlayColor = Colors.black,
    this.fingersRequiredToPinch = 2,
    this.twoFingersOn,
    this.twoFingersOff,
    this.log = false,
    super.key,
  })  : assert(minScale > 0),
        assert(maxScale > 0),
        assert(maxScale >= minScale);

  /// Widget where the pinch will be done
  final Widget child;

  final BuildContext? buildContextOverlayState;

  /// If you set a zoomChild, the zoom will be done in this widget,
  /// this can be useful if you have an animation in the child widget,
  /// and want to zoom only in the last frame of that animation
  final Widget? zoomChild;

  /// If set to [Clip.none], the child may extend beyond the size of the InteractiveViewer,
  /// but it will not receive gestures in these areas.
  /// Be sure that the InteractiveViewer is the desired size when using [Clip.none].
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// The maximum allowed scale.
  ///
  /// The scale will be clamped between this and [minScale] inclusively.
  ///
  /// Defaults to 2.5.
  ///
  /// Cannot be null, and must be greater than zero and greater than minScale.
  final double maxScale;

  /// The minimum allowed scale.
  ///
  /// The scale will be clamped between this and [maxScale] inclusively.
  ///
  /// Scale is also affected by [boundaryMargin]. If the scale would result in
  /// viewing beyond the boundary, then it will not be allowed. By default,
  /// boundaryMargin is EdgeInsets.zero, so scaling below 1.0 will not be
  /// allowed in most cases without first increasing the boundaryMargin.
  ///
  /// Defaults to 0.8.
  ///
  /// Cannot be null, and must be a finite number greater than zero and less
  /// than maxScale.
  final double minScale;

  /// The duration of the reset animation
  final Duration resetDuration;

  /// The curve of the reset animation
  final Curve resetCurve;

  /// The boundary margin of the interactive viewer,
  /// this can be used to give margin in the bottom
  /// in case you want the user to zoom out
  final EdgeInsets boundaryMargin;

  /// If it's true will create a new widget to zoom, to occupy the entire screen
  ///
  /// The problem of using an overlay is if you want to zoom in a scrollable widget
  /// as the widget is rebuilt to occupy the entire screen
  /// can lose the scroll or any other state
  final bool useOverlay;

  /// If `rootOverlay` is set to true, the state from the furthest instance of
  /// this class is given instead. Useful for installing overlay entries above
  /// all subsequent instances of [Overlay].
  final bool rootOverlay;

  /// The max opacity of the overlay when users zooms in
  final double maxOverlayOpacity;

  /// Overlay color
  final Color overlayColor;

  /// Fingers required to start a pinch,
  /// if it's zero or below zero no validation will be performed
  final int fingersRequiredToPinch;

  /// This function is super useful to block scroll and make the pinch to zoom easier
  final void Function()? twoFingersOn;

  /// Function to unblock scroll again
  final void Function()? twoFingersOff;

  /// Log what's happening
  final bool log;

  @override
  State<PinchZoomReleaseUnzoomWidget> createState() =>
      _PinchZoomReleaseUnzoomWidgetState();
}

class _PinchZoomReleaseUnzoomWidgetState
    extends State<PinchZoomReleaseUnzoomWidget> with TickerProviderStateMixin {
  /// Transformation controller of the interactive viewer,
  /// This property is very used to animate the zoom reset as we need to programmatically change the scale
  late TransformationController transformationController;

  /// Animation controller used to trigger the animate the zoom reset
  late AnimationController animationController;
  Animation<Matrix4>? animation;

  /// Overlay entry used to show the zoomed widget
  OverlayEntry? entry;

  /// List of all the overlays added to the screen
  List<OverlayEntry> overlayEntries = [];

  /// Scale of the widget, used to calculate the opacity of the overlay
  double scale = 1;

  /// List of onPointerUp and onPointerDown, used to count number of fingers on the widget
  final List<int> events = [];

  @override
  void initState() {
    super.initState();
    PinchZoomLogger().logFlag = widget.log;

    transformationController = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: widget.resetDuration,
    )
      ..addListener(
        () => transformationController.value = animation!.value,
      )
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed && widget.useOverlay) {
            Future.delayed(const Duration(milliseconds: 100), removeOverlay);
          }
        },
      );
  }

  @override
  void dispose() {
    transformationController.dispose();
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildWidget(widget.child);

  void resetAnimation() {
    if (mounted) {
      animation = Matrix4Tween(
              begin: transformationController.value, end: Matrix4.identity())
          .animate(CurvedAnimation(
              parent: animationController, curve: widget.resetCurve));
      animationController.forward(from: 0);
    }
  }

  Widget buildWidget(Widget zoomableWidget) => Builder(
        builder: (context) => Listener(
          onPointerDown: (PointerEvent event) {
            events.add(event.pointer);
            final int pointers = events.length;
            PinchZoomLogger().log('added new pointer. Total: $pointers');

            if (pointers >= 2 && widget.twoFingersOn != null) {
              PinchZoomLogger()
                  .log('two fingers on. Parent widget should block scroll');
              widget.twoFingersOn!.call();
            }
          },
          onPointerUp: (event) {
            events.clear();
            PinchZoomLogger().log('removed pointer. Total: 0');

            if (widget.twoFingersOff != null) {
              PinchZoomLogger()
                  .log('two fingers off. Parent widget should unblock scroll');
              widget.twoFingersOff!.call();
            }
          },
          child: InteractiveViewer(
            clipBehavior: widget.clipBehavior,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            transformationController: transformationController,
            onInteractionStart: (details) {
              if (widget.fingersRequiredToPinch > 0 &&
                  details.pointerCount != widget.fingersRequiredToPinch) {
                PinchZoomLogger()
                    .log('avoided start with ${details.pointerCount} fingers');
                return;
              }
              if (widget.useOverlay) {
                PinchZoomLogger().log('started interaction. Show overlay');
                showOverlay(context);
              }
            },
            onInteractionEnd: (details) {
              PinchZoomLogger().log('stopped interaction. Hide overlay');
              if (overlayEntries.isEmpty) {
                return;
              }

              resetAnimation();
            },
            onInteractionUpdate: (details) {
              if (entry == null) {
                return;
              }

              scale = details.scale;
              entry?.markNeedsBuild();
            },
            panEnabled: false,
            boundaryMargin: widget.boundaryMargin,
            child: zoomableWidget,
          ),
        ),
      );

  void showOverlay(BuildContext context) {
    PinchZoomLogger()
        .log('Show overlay. Count before: ${overlayEntries.length}');
    final OverlayState overlay = Overlay.of(
      widget.buildContextOverlayState ?? context,
      rootOverlay: widget.rootOverlay,
    );
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final Offset offset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlay.context.findRenderObject(),
    );

    entry = OverlayEntry(builder: (context) {
      final double opacity = ((scale - 1) / (widget.maxScale - 1))
          .clamp(0, widget.maxOverlayOpacity);

      return Material(
        color: Colors.green.withOpacity(0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: opacity,
                child: Container(color: widget.overlayColor),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: SizedBox(
                width: renderBox.size.width,
                height: renderBox.size.height,
                child: buildWidget(widget.zoomChild ?? widget.child),
              ),
            ),
          ],
        ),
      );
    });
    overlay.insert(entry!);

    // We need to control all the overlays added to avoid problems in scrolling,
    overlayEntries.add(entry!);
  }

  void removeOverlay() {
    PinchZoomLogger().log('remove overlay. Count: ${overlayEntries.length}');
    for (final OverlayEntry entry in overlayEntries) {
      entry.remove();
    }
    overlayEntries.clear();
    entry = null;
  }
}
