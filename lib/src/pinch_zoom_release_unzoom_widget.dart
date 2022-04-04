import 'package:flutter/material.dart';

class PinchZoomReleaseUnzoomWidget extends StatefulWidget {
  final Widget child;

  const PinchZoomReleaseUnzoomWidget({required this.child, Key? key})
      : super(key: key);

  @override
  State<PinchZoomReleaseUnzoomWidget> createState() =>
      _PinchZoomReleaseUnzoomWidgetState();
}

class _PinchZoomReleaseUnzoomWidgetState
    extends State<PinchZoomReleaseUnzoomWidget> with TickerProviderStateMixin {
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;

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
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() => controller.value = animation!.value);

    return InteractiveViewer(
      clipBehavior: Clip.none,
      transformationController: controller,
      onInteractionEnd: (details) {
        resetAnimation();
      },
      panEnabled: false,
      boundaryMargin: const EdgeInsets.only(bottom: 0),
      child: widget.child,
    );
  }

  void resetAnimation() {
    animation = Matrix4Tween(begin: controller.value, end: Matrix4.identity())
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.ease));
    animationController.forward(from: 0);
  }
}
