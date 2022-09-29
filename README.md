This package helps to create an instagram like zoom picture. With pinch to zoom and release to unzoom

In this video I explained how to use pinch to zoom, in a flutter project

https://youtu.be/V2DglEpynF8

![Zoom_demo](https://github.com/ivofernandes/pinch_zoom_release_unzoom/blob/master/doc/pinch_zoom_release_unzoom.gif?raw=true)

## Features

Let's your app show zoomable images in an user friendly way.

It's a container of an uncliped interactive viewer that let's the user zoom the image occupying the entire screen.
Once you release the screen and stop the pinch interaction the image/widget will come back to it's original size in an smooth animation.

## Getting started

Add the dependency to your `pubspec.yaml`:

```
pinch_zoom_release_unzoom: ^0.0.10
```

## Usage

```dart

PinchZoomReleaseUnzoomWidget(
  child: Image.network(
    'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png'
  ),
)
```

## Additional information

This package also support some extra params that may be useful depending on what are you trying to achieve

```dart
PinchZoomReleaseUnzoomWidget(
    child: Image.network('https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png'),
    minScale: 0.8,
    maxScale: 4,
    resetDuration: const Duration(milliseconds: 200),
    boundaryMargin: const EdgeInsets.only(bottom: 0),
    clipBehavior: Clip.none,
    useOverlay: true,
    maxOverlayOpacity: 0.5,
    overlayColor: Colors.black,
    fingersRequiredToPinch: 2
)
```

## Making it work well inside a scroll
The problem with making a pinch working inside a scroll is that the drag of a screen, 
as a simple gesture that can be done with just one finger, 
tends to override the more complex scale gesture that needs two fingers to work well,
the best way I found to overcome that challenge is to change the physics of the scroll to NeverScrollableScrollPhysics()
when the second finger touch the screen, that way the scroll stops to override the scale gesture and it's easy to interact with the interactive viewer.

Another consideration that you will need to have is that to avoid losing frames of the reset animation,
you need to delay the setState that will bring the scroll back to the parent widget

So the scroll build will look like this:
```dart
  bool blockScroll = false;
ScrollController controller = ScrollController();

@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
      controller: controller,
      physics: blockScroll ? NeverScrollableScrollPhysics() : ScrollPhysics(),
```

And the PinchWidget will have this two extra parameters: 
```dart
twoFingersOn: () => setState(() => blockScroll = true),
twoFingersOff: () => Future.delayed(
PinchZoomReleaseUnzoomWidget.defaultResetDuration,
() => setState(() => blockScroll = false),
```

For a complete widget example check this one:
```dart
class TestSimpleScroll extends StatefulWidget {
  const TestSimpleScroll({super.key});

  @override
  State<TestSimpleScroll> createState() => _TestSimpleScrollState();
}

class _TestSimpleScrollState extends State<TestSimpleScroll> {
  bool blockScroll = false;
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: blockScroll ? NeverScrollableScrollPhysics() : ScrollPhysics(),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 300,
                height: 250,
                child: PinchZoomReleaseUnzoomWidget(
                  child: Image.network(
                    'https://www.animalfriends.co.uk/siteassets/media/images/article-images/cat-articles/38_afi_article1_caring-for-a-kitten-tips-for-the-first-month.png',
                  ),
                  twoFingersOn: () => setState(() => blockScroll = true),
                  twoFingersOff: () => Future.delayed(
                    PinchZoomReleaseUnzoomWidget.defaultResetDuration,
                        () => setState(() => blockScroll = false),
                  ),
                ),
              ),
              const SizedBox(
                height: 5000,
              )
            ],
          ),
        ),
      ),
    );
  }
}
```


## Simulator test
To test in a simulator add a fingersRequiredToPinch to pinch with a -1 to disable the requirement of two fingers to start an interaction
```dart
PinchZoomReleaseUnzoomWidget(
    child: Image.network('https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png'),
    fingersRequiredToPinch: -1
)
```

## Like us on pub.dev
Package url:
https://pub.dev/packages/pinch_zoom_release_unzoom


## Instruction to publish the package to pub.dev
dart pub publish