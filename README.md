# sliver_sticky_collapsable_panel

A Sliver implementation of panel with a sticky collapsable header and a sliver as child.

![Screenshot](https://github.com/techwn/files/blob/main/imgs/sliver_sticky_collapsable_panel.gif?raw=true)

## Features

* Accepts one sliver as content.
* Header can overlap its sliver (useful for sticky side header for example).
* Notifies when the header scrolls outside the viewport.
* Can scroll in any direction.
* Supports overlapping (AppBars for example).
* Supports not sticky headers (with `sticky: false` parameter).
* Supports a controller which notifies the scroll offset of the current sticky header.
* Supports click the header to collapse the content.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  sliver_sticky_collapsable_panel:
```

In your library add the following import:

```dart
import 'package:sliver_sticky_collapsable_panel/sliver_sticky_collapsable_panel.dart';
```

## Thanks

Thanks to [letsar](https://github.com/letsar) with
it's [flutter_sticky_header](https://pub.dev/packages/flutter_sticky_header) which provide solid foundation to implement
the collapsable feature.