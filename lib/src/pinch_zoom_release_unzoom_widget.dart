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
      this.resetDuration = const Duration(milliseconds: 200),
      this.boundaryMargin = const EdgeInsets.only(bottom: 0),
      this.clipBehavior = Clip.none,
      this.minScale = 0.8,
      this.maxScale = 2.5,
      this.log = false,
      Key? key})
      : assert(minScale > 0),
        assert(maxScale > 0),
        assert(maxScale >= minScale),
        super(key: key);

  /// Debug logs
  final bool log;

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

  /// The
  final EdgeInsets boundaryMargin;

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
  double scale = 1;

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    controller = TransformationController();
    animationController =
        AnimationController(vsync: this, duration: widget.resetDuration)
          ..addListener(() => controller.value = animation!.value)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              log('remove overlay');
              removeOverlay();
            }
          });

    return buildWidget();
  }

  void resetAnimation() {
    log('reset animation');
    animation = Matrix4Tween(begin: controller.value, end: Matrix4.identity())
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.ease));
    animationController.forward(from: 0);
  }

  Widget buildWidget() {
    return Builder(
        builder: (context) => InteractiveViewer(
              clipBehavior: widget.clipBehavior,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              transformationController: controller,
              onInteractionStart: (details) {
                showOverlay(context);
              },
              onInteractionEnd: (details) {
                resetAnimation();
              },
              onInteractionUpdate: (details) {
                if (entry == null) return;

                //scale = details.scale;
                //entry?.markNeedsBuild();
              },
              panEnabled: false,
              boundaryMargin: widget.boundaryMargin,
              child: widget.child,
            ));
  }

  void showOverlay(BuildContext context) {
    OverlayState? overlay = Overlay.of(context);

    Size size = MediaQuery.of(context).size;
    RenderBox? renderBox = context.findRenderObject() as RenderBox;

    Offset? offset = renderBox.localToGlobal(Offset.zero);

    /**
     * Positioned.fill(
        child: Opacity(
        opacity: opacity, child: Container(color: Colors.black))),


        left: offset.dx,
        top: offset.dy +
        MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom,
        width: size.width,
     */

    entry = OverlayEntry(builder: (context) {
      double opacity = ((scale - 1) / (widget.maxScale - 1)).clamp(0, 1);
      return Stack(
        children: [
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Container(
                width: renderBox.size.width,
                height: renderBox.size.height,
                child: buildWidget()),
          ),
        ],
      );
    });
    overlay?.insert(entry!);
    log('insert overlay ' + renderBox.size.width.toString());
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }

  void log(String s) {
    if (widget.log) {
      print(s);
    }
  }
}
