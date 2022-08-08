import 'package:flutter/material.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pinch zoom relase unzoom '),
        ),
        body: const TestPinch(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'About'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Checkout')
          ],
        ),
      ),
    );
  }
}

class TestPinch extends StatefulWidget {
  const TestPinch({Key? key}) : super(key: key);

  @override
  State<TestPinch> createState() => _TestPinchState();
}

class _TestPinchState extends State<TestPinch> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Test the zoom with 2 fingers required'),
              SizedBox(
                width: 300,
                height: 300,
                child: PinchZoomReleaseUnzoomWidget(
                  child: Image.network(
                      'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png'),
                  minScale: 0.8,
                  maxScale: 4,
                  resetDuration: const Duration(milliseconds: 200),
                  boundaryMargin: const EdgeInsets.only(bottom: 0),
                  clipBehavior: Clip.none,
                  maxOverlayOpacity: 0.5,
                  overlayColor: Colors.black,
                ),
              ),
              const Text('Test the zoom with no fingers restrition'),
              SizedBox(
                width: 300,
                height: 300,
                child: PinchZoomReleaseUnzoomWidget(
                  child: Image.network(
                      'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png'),
                  minScale: 0.8,
                  maxScale: 6,
                  resetDuration: const Duration(milliseconds: 200),
                  boundaryMargin: const EdgeInsets.only(bottom: 0),
                  clipBehavior: Clip.none,
                  maxOverlayOpacity: 0.5,
                  overlayColor: Colors.black,
                  fingersRequiredToPinch: -1,
                ),
              ),
              Text('Test with text widget instead of an image'),
              SizedBox(
                width: 300,
                height: 300,
                child: PinchZoomReleaseUnzoomWidget(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.deepOrange,
                    width: 300,
                    height: 300,
                    child: Column(children: const [
                      Text(
                          'The purpouse of this text is to be an example that you can pinch any widget'),
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(Icons.fullscreen))
                    ]),
                  ),
                  zoomChild: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.deepOrange,
                    width: 300,
                    height: 300,
                    child: Column(children: const [
                      Text(
                          'The purpouse of this text is to be an example that you switch the zoomChild if you just set the zoomChild parameter'),
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(Icons.fullscreen))
                    ]),
                  ),
                  maxScale: 4,
                  fingersRequiredToPinch: -1,
                ),
              ),
              MaterialButton(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: Colors.blueGrey,
                onPressed: () => setState(() {
                  selected = !selected;
                }),
                child: selected
                    ? const Text('Selected')
                    : const Text('Unselected'),
              ),
              Text(
                  'Example of keeping scrolling state, this example sets useOverlay to false to avoid rebuilds that would destroy the scroll state:'),
              PinchZoomReleaseUnzoomWidget(
                useOverlay: false,
                child: SizedBox(
                    height: 500,
                    child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                      return Center(child: Text('$index'));
                    })),
              ),
              Container(height: 400, width: 200, color: Colors.grey),
              const Text('Text to test the zoom'),
              const Text('Text to test the zoom'),
            ],
          ),
        ),
      ),
    );
  }
}
