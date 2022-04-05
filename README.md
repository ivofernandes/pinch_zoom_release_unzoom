<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

This package helps to create an instagram like zoom picture. With pinch to zoom and release to unzoom

## Features

This package is an container of an uncliped interactive viewer that let's the user zoom the image occupying the entire screen.

## Getting started

Add the dependency to your `pubspec.yaml`:

```
pinch_zoom_release_unzoom: 
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

For now the package already support the Clip.none so the image can be sized and will occupy extra space after zooming 