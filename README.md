# sliver_sticky_collapsable_panel

A Sliver implementation of panel with a sticky collapsable header and a sliver as child.

## Snap Shot
<img src="https://github.com/techwn/files/blob/main/imgs/sliver_sticky_collapsable_panel.gif?raw=true" width=360 alt="Snap Shot">

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
  sliver_sticky_collapsable_panel:
```

In your library add the following import:

```dart
import 'package:sliver_sticky_collapsable_panel/sliver_sticky_collapsable_panel.dart';
```

In your code, use the sliver like this:
```dart
CustomScrollView(
  controller: _scrollController,
  slivers: [
    SliverStickyCollapsablePanel.builer(
      scrollController: _scrollController,
      controller: StickyCollapsablePanelController(key:'key_1'),
      headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
      sliver: SliverList.list(children: [...]),
    ),
    SliverStickyCollapsablePanel.builer(
      scrollController: _scrollController,
      controller: StickyCollapsablePanelController(key:'key_2'),
      headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
      sliver: SliverList.list(children: [...]),
    ),
    ...,
  ],
);
```

## Thanks

Thanks to [letsar](https://github.com/letsar) with
it's [flutter_sticky_header](https://pub.dev/packages/flutter_sticky_header) which provide solid foundation to implement
the collapsable feature.