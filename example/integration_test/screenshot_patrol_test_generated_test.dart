import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
// ignore: avoid_relative_lib_imports
import '../lib/main.dart' as app;

void main() {
  patrolTest(
    'main navigation screenshots',
    ($) async {
      app.main();
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await closeOpenPanels($);
      await assertAppQuality($, 'app launch');

      // Route: /
      await tapText($, 'Test rootOverlay', tapX: 336.818, tapY: 781.000);
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await assertAppQuality($, 'after tapping Test rootOverlay');
      await captureScreenshot($, 'test_roo_1_2verlay');
      await pinchZoomFirstZoomable($, 'test_roo_1_2verlay_pinch_zoom');
      await tapText($, 'Scroll Positioned', tapX: 283.636, tapY: 781.000);
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await assertAppQuality($, 'after tapping Scroll Positioned');
      await captureScreenshot($, 'scroll_positioned');
      await pinchZoomFirstZoomable($, 'scroll_positioned_pinch_zoom');
      await tapText($, 'Test Scroll Block', tapX: 195.000, tapY: 781.000);
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await assertAppQuality($, 'after tapping Test Scroll Block');
      await captureScreenshot($, 'test_scroll_block');
      await pinchZoomFirstZoomable($, 'test_scroll_block_pinch_zoom');
      await tapText($, 'Checkbox', tapX: 162.280, tapY: 306.000);
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await assertAppQuality($, 'after tapping Checkbox');
      await captureScreenshot($, 'checkbox');
      await pinchZoomFirstZoomable($, 'checkbox_pinch_zoom');
      await tapText($, 'Without scroll', tapX: 124.091, tapY: 781.000);
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await assertAppQuality($, 'after tapping Without scroll');
      await captureScreenshot($, 'without_scroll');
      await pinchZoomFirstZoomable($, 'without_scroll_pinch_zoom');
      await tapText($, 'With Scroll', tapX: 35.455, tapY: 781.000);
      await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
      await assertAppQuality($, 'after tapping With Scroll');
      await captureScreenshot($, 'with_scroll');
      await pinchZoomFirstZoomable($, 'with_scroll_pinch_zoom');
      // Viewport: Current screen
      await assertAppQuality($, 'before home_current_screen screenshot');
      await captureScreenshot($, 'home_current_screen');
      await pinchZoomFirstZoomable($, 'home_current_screen_pinch_zoom');

      // Route: MaterialPageRoute<no-args,standard,stateful>
      // Navigation path unavailable for MaterialPageRoute<no-args,standard,stateful>.
      // Skip reason: Navigation path unavailable for route: MaterialPageRoute<no-args,standard,stateful>.
    },
  );
}

Future<void> captureScreenshot(PatrolIntegrationTester $, String name) async {
  final TestWidgetsFlutterBinding binding = $.tester.binding;
  final RenderView renderView = binding.renderViews.first;
  final ContainerLayer? layer = renderView.debugLayer;
  if (layer == null) {
    throw StateError(
        'Screenshot capture started before the first frame was painted.');
  }

  final ui.Scene scene = layer.buildScene(ui.SceneBuilder());
  final ui.Size physicalSize = renderView.flutterView.physicalSize;
  final ui.Image image = await scene.toImage(
    physicalSize.width.ceil(),
    physicalSize.height.ceil(),
  );
  scene.dispose();
  try {
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Screenshot capture returned no PNG bytes.');
    }
    final Uint8List bytes = byteData.buffer.asUint8List();
    final Directory outputDir = await _patrolScreenshotDir();
    final String safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
    final String numberedName = await _nextScreenshotName(safeName);
    await File('${outputDir.path}/$numberedName.png')
        .writeAsBytes(bytes, flush: true);
    await _appendScreenshotManifest(numberedName, originalName: name);
  } finally {
    image.dispose();
  }
}

Future<void> assertAppQuality(
    PatrolIntegrationTester $, String checkpoint) async {
  await $.tester.pump();
  final dynamic uncaughtException = $.tester.takeException();
  if (uncaughtException != null) {
    throw TestFailure(
      'Uncaught Flutter exception at $checkpoint: $uncaughtException',
    );
  }
  expect(
    find.text('Test starting...'),
    findsNothing,
    reason: 'The app startup placeholder is still visible at $checkpoint.',
  );
  expect(
    find.byType(ErrorWidget),
    findsNothing,
    reason: 'A Flutter ErrorWidget is visible at $checkpoint.',
  );
  final Finder appStructure = find.byWidgetPredicate(
    (Widget widget) =>
        widget is MaterialApp ||
        widget is WidgetsApp ||
        widget is Navigator ||
        widget is Scaffold,
    description: 'MaterialApp, WidgetsApp, Navigator, or Scaffold',
  );
  expect(
    appStructure,
    findsWidgets,
    reason: 'No app structure widgets were found at $checkpoint.',
  );
}

Finder findVisibleZoomables() {
  Finder zoomables = find.byType(InteractiveViewer).hitTestable();
  if (zoomables.evaluate().isNotEmpty) return zoomables;
  zoomables = find
      .byWidgetPredicate(
        (Widget widget) => widget.runtimeType.toString().contains('PinchZoom'),
      )
      .hitTestable();
  if (zoomables.evaluate().isNotEmpty) return zoomables;
  zoomables = find.byType(InteractiveViewer);
  if (zoomables.evaluate().isNotEmpty) return zoomables;
  return find.byWidgetPredicate(
    (Widget widget) => widget.runtimeType.toString().contains('PinchZoom'),
  );
}

Future<bool> pinchZoomFirstZoomable(
    PatrolIntegrationTester $, String screenshotName) async {
  Finder zoomables = findVisibleZoomables();
  if (zoomables.evaluate().isEmpty) return false;
  Finder target = zoomables.first;
  await $.tester.ensureVisible(target);
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
  zoomables = findVisibleZoomables();
  if (zoomables.evaluate().isEmpty) return false;
  target = zoomables.first;
  final Offset center = $.tester.getCenter(target);
  final Size targetSize = $.tester.getSize(target);
  final double halfWidth = targetSize.width / 2;
  final double halfHeight = targetSize.height / 2;
  final double availableDelta = halfWidth < halfHeight ? halfWidth : halfHeight;
  final double startDelta = availableDelta < 60 ? availableDelta / 3 : 40;
  final double endDelta = availableDelta < 140 ? availableDelta - 8 : 120;
  if (endDelta <= startDelta) return false;
  final TestGesture finger1 = await $.tester.startGesture(
    center + Offset(-startDelta, -startDelta),
    pointer: 1,
  );
  final TestGesture finger2 = await $.tester.startGesture(
    center + Offset(startDelta, startDelta),
    pointer: 2,
  );
  await $.tester.pump();
  for (int step = 1; step <= 4; step += 1) {
    final double progress = step / 4;
    final double delta = startDelta + ((endDelta - startDelta) * progress);
    await finger1.moveTo(center + Offset(-delta, -delta));
    await finger2.moveTo(center + Offset(delta, delta));
    await $.tester.pump(const Duration(milliseconds: 50));
  }
  TransformationController? zoomController;
  Matrix4? previousZoomValue;
  final Finder visibleInteractiveViewers =
      find.byType(InteractiveViewer).hitTestable();
  if (visibleInteractiveViewers.evaluate().isNotEmpty) {
    final InteractiveViewer interactiveViewer =
        $.tester.widget<InteractiveViewer>(visibleInteractiveViewers.first);
    zoomController = interactiveViewer.transformationController;
    if (zoomController != null) {
      previousZoomValue = Matrix4.copy(zoomController.value);
      zoomController.value = Matrix4.identity()..scale(2.5);
      await $.tester.pump(const Duration(milliseconds: 50));
    }
  }
  await captureScreenshot($, screenshotName);
  if (zoomController != null && previousZoomValue != null) {
    zoomController.value = previousZoomValue;
  }
  await finger1.up();
  await finger2.up();
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
  return true;
}

Future<void> closeOpenPanels(PatrolIntegrationTester $) async {
  final Finder closeButtons = find.byIcon(Icons.close);
  if (closeButtons.evaluate().isEmpty) return;
  await $.tester.tap(closeButtons.first, warnIfMissed: false);
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
}

Future<Finder?> findPatrolTarget(String label) async {
  final List<Finder> candidates = <Finder>[
    find.byKey(ValueKey<String>(label)),
    find.text(label),
    find.bySemanticsLabel(label),
    find.byTooltip(label),
    find.widgetWithText(ElevatedButton, label),
    find.widgetWithText(FilledButton, label),
    find.widgetWithText(OutlinedButton, label),
    find.widgetWithText(TextButton, label),
    find.widgetWithText(ListTile, label),
    find.widgetWithText(SwitchListTile, label),
    find.widgetWithText(CheckboxListTile, label),
    find.widgetWithText(RadioListTile, label),
    find.widgetWithText(ActionChip, label),
  ];
  final Finder? typeFallback = findPatrolTargetByWidgetType(label);
  if (typeFallback != null) candidates.add(typeFallback);
  for (final Finder candidate in candidates) {
    if (candidate.evaluate().isNotEmpty) return candidate.first;
  }
  return null;
}

Finder? findPatrolTargetByWidgetType(String label) {
  switch (label) {
    case 'Checkbox':
      return find.byType(Checkbox);
    case 'CheckboxListTile':
      return find.byType(CheckboxListTile);
    case 'Switch':
      return find.byType(Switch);
    case 'SwitchListTile':
      return find.byType(SwitchListTile);
    case 'Radio':
      return find.byType(Radio);
    case 'RadioListTile':
      return find.byType(RadioListTile);
  }
  return null;
}

Future<void> tapText(PatrolIntegrationTester $, String text,
    {double? tapX, double? tapY}) async {
  Finder? target = await findPatrolTarget(text);
  for (int attempt = 0; target == null && attempt < 12; attempt++) {
    final Finder scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) break;
    await $.tester.drag(scrollables.last, const Offset(0, -320));
    await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
    target = await findPatrolTarget(text);
  }
  if (target == null) {
    if (tapX != null && tapY != null) {
      await $.tester.tapAt(Offset(tapX, tapY));
      return;
    }
    throw TestFailure('Could not find UI target: $text');
  }
  await $.tester.ensureVisible(target);
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
  await $.tester.tap(target, warnIfMissed: false);
}

Future<void> enterValue(PatrolIntegrationTester $, String label, String value,
    {double? tapX, double? tapY}) async {
  final Finder editableTarget = findEditableTarget(label);
  if (editableTarget.evaluate().isNotEmpty) {
    await $.tester.ensureVisible(editableTarget.first);
    await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
    await $.enterText(editableTarget.first, value);
    return;
  }

  final Finder? sliderTarget = findSliderTarget(label);
  if (sliderTarget != null) {
    await setSliderValue($, sliderTarget, value);
    return;
  }

  if (tapX != null && tapY != null) {
    await $.tester.tapAt(Offset(tapX, tapY));
    await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
    return;
  }

  throw TestFailure('Could not find editable field or slider for: $label');
}

Finder findEditableTarget(String label) {
  final List<Finder> candidates = <Finder>[
    find.widgetWithText(TextField, label),
    find.widgetWithText(TextFormField, label),
    find.byType(TextField),
    find.byType(TextFormField),
  ];
  for (final Finder candidate in candidates) {
    if (candidate.evaluate().isNotEmpty) return candidate.first;
  }
  return find.byType(TextField);
}

Finder? findSliderTarget(String label) {
  final Finder labels = find.text(label);
  for (final Element labelElement in labels.evaluate()) {
    Element? current = labelElement;
    while (current != null) {
      final Finder sliders = find.descendant(
        of: find.byWidget(current.widget),
        matching: find.byType(Slider),
      );
      if (sliders.evaluate().isNotEmpty) return sliders.first;
      Element? parent;
      current.visitAncestorElements((Element ancestor) {
        parent = ancestor;
        return false;
      });
      current = parent;
    }
  }
  final Finder sliders = find.byType(Slider);
  final int sliderCount = sliders.evaluate().length;
  if (sliderCount == 1) return sliders.first;
  if (sliderCount > 1 && isGenericSliderLabel(label)) {
    final int index = _sliderReplaySequence < sliderCount
        ? _sliderReplaySequence
        : sliderCount - 1;
    _sliderReplaySequence += 1;
    return sliders.at(index);
  }
  return null;
}

bool isGenericSliderLabel(String label) {
  final String value = label.trim();
  if (value == 'slider') return true;
  return double.tryParse(value) != null;
}

Future<void> setSliderValue(
    PatrolIntegrationTester $, Finder target, String value) async {
  final double? numericValue = double.tryParse(value);
  if (numericValue == null) {
    throw TestFailure('Slider value is not numeric: $value');
  }
  await $.tester.ensureVisible(target);
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
  final Slider slider = $.tester.widget<Slider>(target);
  final double range = slider.max - slider.min;
  final double fraction =
      range == 0 ? 0 : ((numericValue - slider.min) / range).clamp(0.0, 1.0);
  final Offset topLeft = $.tester.getTopLeft(target);
  final Size size = $.tester.getSize(target);
  final Offset tapPoint = Offset(
    topLeft.dx + (size.width * fraction),
    topLeft.dy + (size.height / 2),
  );
  await $.tester.tapAt(tapPoint);
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 2));
}

Future<String> _nextScreenshotName(String safeName) async {
  final int count = (_screenshotNameCounts[safeName] ?? 0) + 1;
  _screenshotNameCounts[safeName] = count;
  return '${safeName}_$count';
}

Future<void> _appendScreenshotManifest(String fileName,
    {required String originalName}) async {
  final Directory outputDir = await _patrolScreenshotDir();
  final File manifest = File('${outputDir.path}/manifest.txt');
  await manifest.writeAsString('$fileName.png => $originalName\n',
      mode: FileMode.append, flush: true);
}

final Map<String, int> _screenshotNameCounts = <String, int>{};
int _sliderReplaySequence = 0;

Future<Directory> _patrolScreenshotDir() async {
  const String explicitDir = String.fromEnvironment('PATROL_SCREENSHOT_DIR');
  if (explicitDir.isNotEmpty) {
    try {
      final Directory dir = Directory(explicitDir);
      await dir.create(recursive: true);
      return dir;
    } on FileSystemException {
      // iOS/macOS sandboxed test apps may not be allowed to write
      // directly to the host project. Fall back to the app temp dir.
    }
  }
  final Directory dir = Directory(
    '${Directory.systemTemp.path}/patrol_screenshots',
  );
  await dir.create(recursive: true);
  return dir;
}
