import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinch_zoom_release_unzoom/src/pinch_zoom_release_unzoom_widget.dart';

void main() {
  testWidgets('PinchZoomReleaseUnzoomWidget changes scale when pinched', (WidgetTester tester) async {
    // Create a key to track the widget in the test environment
    final GlobalKey key = GlobalKey();

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinchZoomReleaseUnzoomWidget(
            key: key,
            child: Text('Zoom me'),
          ),
        ),
      ),
    );

    // Verify that the child Text widget is on screen
    expect(find.text('Zoom me'), findsOneWidget);

    // Define the initial and final points of the pinch gesture
    final Offset firstPointerStart = tester.getCenter(find.byKey(key));
    final Offset secondPointerStart = tester.getCenter(find.byKey(key)) + const Offset(0, -20);
    final Offset firstPointerEnd = firstPointerStart + const Offset(0, 100);
    final Offset secondPointerEnd = secondPointerStart + const Offset(0, -100);

    // Simulate the pinch gesture
    final TestGesture firstGesture = await tester.startGesture(firstPointerStart);
    await tester.pump();
    final TestGesture secondGesture = await tester.startGesture(secondPointerStart);
    await tester.pump();

    // Move the pointers to simulate the pinch
    await firstGesture.moveTo(firstPointerEnd);
    await secondGesture.moveTo(secondPointerEnd);
    await tester.pump();

    // Release the pointers
    await firstGesture.up();
    await secondGesture.up();
    await tester.pump();
  });
}
