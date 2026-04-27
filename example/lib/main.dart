import 'package:flutter/material.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:touch_indicator/touch_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) => TouchIndicator(
        indicator: const TapCircle(size: 30),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pinch zoom release unzoom'),
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              TestPinchWithScroll(),
              TestPinchWithoutScroll(),
              TestSimpleScroll(),
              TestScrollablePositionedList(),
              TestRootOverlay(),
              Test2Scaffolds(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: onTap,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
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
                label: 'Test Scroll Block',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Scroll Positioned',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Test rootOverlay',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.scatter_plot_outlined),
                label: '2 scaffolds',
              )
            ],
          ),
        ),
      );

  void onTap(int value) {
    _selectedIndex = value;
    _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );

    setState(() {});
  }
}

class Test2Scaffolds extends StatelessWidget {
  const Test2Scaffolds({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('2 Scaffolds'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 300,
                height: 250,
                child: PinchZoomReleaseUnzoomWidget(
                  minScale: 0.8,
                  maxScale: 4,
                  resetDuration: const Duration(milliseconds: 150),
                  boundaryMargin: const EdgeInsets.only(bottom: 0),
                  clipBehavior: Clip.none,
                  maxOverlayOpacity: 0.5,
                  overlayColor: Colors.black,
                  child: Image.network(
                    'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                height: 250,
                child: PinchZoomReleaseUnzoomWidget(
                  minScale: 0.8,
                  maxScale: 4,
                  resetDuration: const Duration(milliseconds: 150),
                  boundaryMargin: const EdgeInsets.only(bottom: 0),
                  clipBehavior: Clip.none,
                  maxOverlayOpacity: 0.5,
                  overlayColor: Colors.black,
                  rootOverlay: false,
                  child: Image.network(
                    'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      );
}

class TestPinchWithScroll extends StatefulWidget {
  const TestPinchWithScroll({
    super.key,
  });

  @override
  State<TestPinchWithScroll> createState() => _TestPinchWithScrollState();
}

class _TestPinchWithScrollState extends State<TestPinchWithScroll> {
  final ScrollController controller = ScrollController();
  bool selected = false;
  bool blockScroll = false;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: controller,
        physics: blockScroll ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                const Text('Test the zoom with 2 fingers required'),
                SizedBox(
                  width: 300,
                  height: 250,
                  child: PinchZoomReleaseUnzoomWidget(
                    twoFingersOn: () => setState(() => blockScroll = true),
                    twoFingersOff: () => Future.delayed(
                      const Duration(milliseconds: 150),
                      () => setState(() => blockScroll = false),
                    ),
                    minScale: 0.8,
                    maxScale: 4,
                    resetDuration: const Duration(milliseconds: 150),
                    boundaryMargin: const EdgeInsets.only(bottom: 0),
                    clipBehavior: Clip.none,
                    maxOverlayOpacity: 0.5,
                    overlayColor: Colors.black,
                    child: Image.network(
                      'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                    ),
                  ),
                ),
                const Text('Test the zoom with no fingers restriction'),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: PinchZoomReleaseUnzoomWidget(
                    twoFingersOn: () => setState(() => blockScroll = true),
                    twoFingersOff: () => Future.delayed(
                      const Duration(milliseconds: 200),
                      () => setState(() => blockScroll = false),
                    ),
                    minScale: 0.8,
                    maxScale: 6,
                    resetDuration: const Duration(milliseconds: 200),
                    boundaryMargin: const EdgeInsets.only(bottom: 0),
                    clipBehavior: Clip.none,
                    maxOverlayOpacity: 0.5,
                    overlayColor: Colors.black,
                    fingersRequiredToPinch: -1,
                    child: Image.network(
                      'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png',
                    ),
                  ),
                ),
                const Text('Test with text widget instead of an image'),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: PinchZoomReleaseUnzoomWidget(
                    twoFingersOn: () => setState(() => blockScroll = true),
                    twoFingersOff: () => Future.delayed(
                      const Duration(milliseconds: 250),
                      () => setState(() => blockScroll = false),
                    ),
                    zoomChild: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.deepOrange,
                      width: 300,
                      height: 300,
                      child: const Column(
                        children: <Widget>[
                          Text(
                            'The purpose of this text is to be an example that you switch the zoomChild if you just set the zoomChild parameter',
                          ),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Icon(Icons.fullscreen),
                          ),
                        ],
                      ),
                    ),
                    maxScale: 4,
                    fingersRequiredToPinch: -1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.deepOrange,
                      width: 300,
                      height: 300,
                      child: const Column(
                        children: <Widget>[
                          Text(
                            'The purpose of this text is to be an example that you can pinch any widget',
                          ),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Icon(Icons.fullscreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blueGrey,
                  onPressed: () => setState(() {
                    selected = !selected;
                  }),
                  child: selected ? const Text('Selected') : const Text('Unselected'),
                ),
                const Text(
                  'Example of keeping scrolling state, this example sets useOverlay to false to avoid rebuilds that would destroy the scroll state:',
                ),
                PinchZoomReleaseUnzoomWidget(
                  useOverlay: false,
                  child: SizedBox(
                    height: 500,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) => Center(
                        child: Text('$index'),
                      ),
                    ),
                  ),
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

class TestPinchWithoutScroll extends StatelessWidget {
  const TestPinchWithoutScroll({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 300,
        height: 300,
        child: PinchZoomReleaseUnzoomWidget(
          minScale: 0.8,
          maxScale: 4,
          resetDuration: const Duration(milliseconds: 200),
          boundaryMargin: const EdgeInsets.only(bottom: 0),
          clipBehavior: Clip.none,
          maxOverlayOpacity: 0.5,
          overlayColor: Colors.black,
          child: Image.network(
            'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png',
          ),
        ),
      );
}

class TestSimpleScroll extends StatefulWidget {
  const TestSimpleScroll({super.key});

  @override
  State<TestSimpleScroll> createState() => _TestSimpleScrollState();
}

class _TestSimpleScrollState extends State<TestSimpleScroll> {
  /// Variable to control if the scroll is blocked or not
  bool blockScroll = false;

  /// Checkbox to control if is possible to block the scroll
  /// (this just for checkbox example, no need to copy this part)
  bool canBlockScroll = true;

  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: controller,
        physics: blockScroll ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 150),
                Card(
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        const Text('Can block scroll'),
                        Checkbox(
                          value: canBlockScroll,
                          onChanged: (value) => setState(() => canBlockScroll = value!),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'This widget tries to show the difference between a normal scroll and a scroll with the pinch zoom, and a block scroll approach',
                ),
                SizedBox(
                  width: 300,
                  height: 250,
                  child: PinchZoomReleaseUnzoomWidget(
                    child: Image.network(
                      'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                    ),
                    twoFingersOn: () {
                      if (canBlockScroll) {
                        debugPrint('scroll blocked because of two fingers');
                        setState(() => blockScroll = true);
                      }
                    },
                    twoFingersOff: () {
                      debugPrint('scroll unblocked because of two fingers off');
                      Future.delayed(
                        PinchZoomReleaseUnzoomWidget.defaultResetDuration,
                        () => setState(
                          () => blockScroll = false,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 50),
                const Text('Scroll'),
                const SizedBox(height: 5000),
              ],
            ),
          ),
        ),
      );
}

class TestScrollablePositionedList extends StatefulWidget {
  const TestScrollablePositionedList({super.key});

  @override
  State<TestScrollablePositionedList> createState() => _TestScrollablePositionedListState();
}

class _TestScrollablePositionedListState extends State<TestScrollablePositionedList> {
  bool blockScroll = false;

  final ItemScrollController controller = ItemScrollController();

  static const List<String> testImages = [
    'https://www.kasandbox.org/programming-images/avatars/spunky-sam.png',
    'https://www.kasandbox.org/programming-images/avatars/spunky-sam-green.png',
    'https://www.kasandbox.org/programming-images/avatars/mr-pants.png',
    'https://www.kasandbox.org/programming-images/avatars/mr-pants-green.png',
    'https://www.kasandbox.org/programming-images/avatars/mr-pants-purple.png',
    'https://www.kasandbox.org/programming-images/avatars/marcimus.png',
    'https://www.kasandbox.org/programming-images/avatars/marcimus-red.png',
    'https://www.kasandbox.org/programming-images/avatars/marcimus-orange.png',
    'https://www.kasandbox.org/programming-images/avatars/marcimus-purple.png',
  ];

  void twoFingersOn() {
    setState(() {
      blockScroll = true;
    });
  }

  void twoFingersOff() {
    setState(() {
      blockScroll = false;
    });
  }

  @override
  Widget build(BuildContext context) => ScrollablePositionedList.separated(
        itemScrollController: controller,
        itemCount: testImages.length,
        physics: blockScroll ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) => _ListItem(
          twoFingersOn: twoFingersOn,
          twoFingersOff: twoFingersOff,
          url: testImages[index],
        ),
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
      );
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.url,
    this.twoFingersOn,
    this.twoFingersOff,
    super.key,
  });

  final String url;
  final VoidCallback? twoFingersOn;
  final VoidCallback? twoFingersOff;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: PinchZoomReleaseUnzoomWidget(
          twoFingersOn: twoFingersOff,
          twoFingersOff: twoFingersOff,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              url,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
}

class TapCircle extends StatelessWidget {
  final double size;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  const TapCircle({
    this.size = 60.0,
    this.color = Colors.white,
    this.borderColor = Colors.grey,
    this.borderWidth = 3.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: borderWidth,
          ),
          shape: BoxShape.circle,
        ),
      );
}

class TestRootOverlay extends StatefulWidget {
  const TestRootOverlay({super.key});

  @override
  State<TestRootOverlay> createState() => _TestRootOverlayState();
}

class _TestRootOverlayState extends State<TestRootOverlay> {
  bool rootOverlay = false;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          OutlinedButton(
            onPressed: () {
              setState(() {
                rootOverlay = !rootOverlay;
              });
            },
            child: Text('rootOverlay: $rootOverlay'),
          ),
          Expanded(
            child: Navigator(
              initialRoute: '/',
              onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                settings: settings,
                builder: (context) => Scaffold(
                  body: Center(
                    child: PinchZoomReleaseUnzoomWidget(
                      minScale: 0.8,
                      maxScale: 4,
                      resetDuration: const Duration(milliseconds: 150),
                      boundaryMargin: const EdgeInsets.only(bottom: 0),
                      clipBehavior: Clip.none,
                      maxOverlayOpacity: 0.5,
                      overlayColor: Colors.black,
                      rootOverlay: rootOverlay,
                      child: Image.network(
                        'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
