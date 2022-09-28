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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinch zoom relase unzoom '),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          const TestPinchWithScroll(),
          const TestPinchWithoutScroll(),
          GestureLogWidget()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'With Scroll',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Without scroll',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gesture),
            label: 'Gesture',
          ),
        ],
      ),
    );
  }

  void onTap(int value) {
    _selectedIndex = value;
    _pageController.animateToPage(value,
        duration: Duration(milliseconds: 200), curve: Curves.easeOut);

    setState(() {});
  }
}

class TestPinchWithScroll extends StatefulWidget {
  const TestPinchWithScroll({Key? key}) : super(key: key);

  @override
  State<TestPinchWithScroll> createState() => _TestPinchWithScrollState();
}

class _TestPinchWithScrollState extends State<TestPinchWithScroll> {
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
                height: 250,
                child: PinchZoomReleaseUnzoomWidget(
                  child: Image.network(
                    'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                    fit: BoxFit.fill,
                  ),
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

class TestPinchWithoutScroll extends StatelessWidget {
  const TestPinchWithoutScroll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class GestureLogWidget extends StatefulWidget {
  const GestureLogWidget({Key? key}) : super(key: key);

  @override
  State<GestureLogWidget> createState() => _GestureLogWidgetState();
}

class _GestureLogWidgetState extends State<GestureLogWidget> {
  String log = '';
  bool scroll = true;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          GestureDetector(
            onScaleStart: (details) => setState(() {
              log += details.toString() + '\n\n';
            }),
            onTap: () => setState(() {
              log += 'onTap\n\n';
            }),
            onVerticalDragStart: (details) => setState(() {
              log += details.toString() + '\n\n';
            }),
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.withOpacity(0.5),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height - 250,
              child: Text(
                log,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: () => setState(() {
                  log = '';
                }),
                child: const Text('Reset'),
                color: Colors.blueAccent,
              ),
              MaterialButton(
                onPressed: () => setState(() {
                  scroll = !scroll;
                }),
                child: Text(scroll ? 'Turn scroll off' : 'Turn scroll on'),
                color: Colors.orange,
              )
            ],
          ),
          SizedBox(
            height: scroll ? 200 : 0,
          )
        ],
      ),
    );

    return scroll
        ? SingleChildScrollView(
            child: container,
          )
        : container;
  }
}
