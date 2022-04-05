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
          title: Text('Pinch zoom relase unzoom '),
        ),
        body: TestPinch(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home')
          ],
        ),
      ),
    );
  }
}

class TestPinch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Text to test the zoom'),
        Text('Text to test the zoom'),
        SizedBox(
          width: 300,
          height: 300,
          child: PinchZoomReleaseUnzoomWidget(
            child: Image.network(
                'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png'),
          ),
        ),
        Text('Text to test the zoom'),
        Text('Text to test the zoom'),
      ],
    );
  }
}
