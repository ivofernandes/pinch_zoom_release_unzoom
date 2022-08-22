This package helps to create an instagram like zoom picture. With pinch to zoom and release to unzoom

![Zoom_demo](https://github.com/ivofernandes/pinch_zoom_release_unzoom/blob/master/doc/pinch_zoom_release_unzoom.gif?raw=true)

In this video I explained how to use pinch to zoom, in a flutter project
https://youtu.be/V2DglEpynF8

## Features

Let's your app show zoomable images in an user friendly way.

It's a container of an uncliped interactive viewer that let's the user zoom the image occupying the entire screen.
Once you release the screen and stop the pinch interaction the image/widget will come back to it's original size in an smooth animation.

## Getting started

Add the dependency to your `pubspec.yaml`:

```
pinch_zoom_release_unzoom: ^0.0.8
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