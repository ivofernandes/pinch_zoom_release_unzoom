import 'package:flutter/material.dart';

class PinchZoomReleaseUnzoomWidget extends StatefulWidget {
  final Widget child;

  /// Create an PinchZoomReleaseUnzoomWidget,
  /// remeber that is just a little bit of customization over an interactive viewer
  ///
  /// * [child] is the widget used for zooming.
  /// This parameter is required because without a child there is nothing to zoom on
  const PinchZoomReleaseUnzoomWidget(
      {required this.child,
      this.zoomChild,
      this.resetDuration = const Duration(milliseconds: 200),
      this.boundaryMargin = const EdgeInsets.only(bottom: 0),
      this.clipBehavior = Clip.none,
      this.minScale = 0.8,
      this.maxScale = 2.5,
      this.useOverlay = true,
      this.maxOverlayOpacity = 0.5,
      this.overlayColor = Colors.black,
      Key? key})
      : assert(minScale > 0),
        assert(maxScale > 0),
        assert(maxScale >= minScale),
        super(key: key);

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

  /// The max opacity of the overlay when users zooms in
  final double maxOverlayOpacity;

  /// Overlay color
  final Color overlayColor;

  @override
  State<PinchZoomReleaseUnzoomWidget> createState() =>
      _PinchZoomReleaseUnzoomWidgetState();
}

class _PinchZoomReleaseUnzoomWidgetState
    extends State<PinchZoomReleaseUnzoomWidget> with TickerProviderStateMixin {
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  OverlayEntry? entry;
  List<OverlayEntry> entries = [];
  double scale = 1;

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller = TransformationController();
    animationController =
        AnimationController(vsync: this, duration: widget.resetDuration)
          ..addListener(() => controller.value = animation!.value)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && widget.useOverlay) {
              removeOverlay();
            }
          });

    return buildWidget(widget.child);
  }

  void resetAnimation() {
    animation = Matrix4Tween(begin: controller.value, end: Matrix4.identity())
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.ease));
    animationController.forward(from: 0);
  }

  Widget buildWidget(Widget zoomableWidget) {
    return Builder(
        builder: (context) => InteractiveViewer(
              clipBehavior: widget.clipBehavior,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              transformationController: controller,
              onInteractionStart: (details) {
                print('start with ${details.pointerCount} fingers');
                if (details.pointerCount != 2) return;
                if (widget.useOverlay) {
                  showOverlay(context);
                }
              },
              onInteractionEnd: (details) {
                resetAnimation();
              },
              onInteractionUpdate: (details) {
                if (entry == null) return;

                scale = details.scale;
                entry?.markNeedsBuild();
              },
              panEnabled: false,
              boundaryMargin: widget.boundaryMargin,
              child: zoomableWidget,
            ));
  }

  void showOverlay(BuildContext context) {
    OverlayState? overlay = Overlay.of(context);
    RenderBox? renderBox = context.findRenderObject() as RenderBox;
    Offset? offset = renderBox.localToGlobal(Offset.zero);

    entry = OverlayEntry(builder: (context) {
      double opacity = ((scale - 1) / (widget.maxScale - 1))
          .clamp(0, widget.maxOverlayOpacity);

      return Material(
        color: Colors.green.withOpacity(0.0),
        child: Stack(
          children: [
            Positioned.fill(
                child: Opacity(
                    opacity: opacity,
                    child: Container(color: widget.overlayColor))),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: SizedBox(
                  width: renderBox.size.width,
                  height: renderBox.size.height,
                  child: buildWidget(widget.zoomChild ?? widget.child)),
            ),
          ],
        ),
      );
    });
    overlay?.insert(entry!);

    // We need to control all the overlays added to avoid problems in scrolling,
    entries.add(entry!);
  }

  void removeOverlay() {
    for (OverlayEntry entry in entries) {
      entry.remove();
    }
    entries.clear();
    entry = null;
  }
}
