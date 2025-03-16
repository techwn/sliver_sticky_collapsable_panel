# sliver_sticky_collapsable_panel
[![pub](https://img.shields.io/badge/pub-2.0.7-blue)](https://pub.dev/packages/sliver_sticky_collapsable_panel)
[![license](https://img.shields.io/badge/license-MIT-orange)](https://github.com/techwn/sliver_sticky_collapsable_panel/blob/main/LICENSE)
[![build status](https://img.shields.io/badge/build-passing-green?logo=github&logoColor=white)](https://github.com/techwn/sliver_sticky_collapsable_panel)
[![flutter compatibility](https://img.shields.io/badge/flutter-3.13+-blue)](https://flutter.dev/)
[![dart compatibility](https://img.shields.io/badge/dart-3.1+-blue)](https://dart.dev/)

A Sliver implementation of sticky collapsable panel, with a box header rebuild on status and a sliver child as panel content.

## Snap Shot
<img src="https://raw.githubusercontent.com/techwn/files/main/imgs/sliver_sticky_collapsable_pannel/simple_demo.gif" width=360 alt="simple Shot">

---
## Features
- Relying solely on the Flutter framework itself.
- Accept one box child as header and one sliver child as panel content.
- Header can overlap panel content (useful for sticky side header for example).
- Notify and rebuild the header when status changed (scroll outside the viewport for example).
- Support not sticky headers (with `sticky: false` parameter).
- Support a controller which notifies the scroll offset of the current sticky header.
- Support click the header to collapse the panel, or disable collapse (with `disableCollapsable = true` parameter).
- Support iOS style sticky header, just like iOS's system contact app (with `iOSStyleSticky = true` parameter).
- Support add padding for sliver child (with `paddingBeforeCollapse` parameter).
- Support add padding after the header even the panel collapsed (with `paddingAfterCollapse` parameter).
- Support setting/getting the collapsable panel expansion, pinned, and disabled status using `isExpanded`, `isPinned`, and `isDisabled` properties of the controller.

---
## Getting started

- In the `pubspec.yaml` of your flutter project, add the following dependency:

    ```yaml
    dependencies:
      sliver_sticky_collapsable_panel: ^2.1.0
    ```

- In your library add the following import:

    ```dart
    import 'package:sliver_sticky_collapsable_panel/sliver_sticky_collapsable_panel.dart';
    ```

- In your code, use the sliver like this:
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliverPanel: SliverList.list(children: [...]),
        ),
        SliverStickyCollapsablePanel(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_2'),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliverPanel: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```

- For simple right side header arrow hint `^`, you can build with widget in flutter framework like `AnimatedRotation`:
    ```dart
    SliverStickyCollapsablePanel(
      scrollController: _scrollController,
      controller: StickyCollapsablePanelController(key:'key_1'),
      headerBuilder: (context, status) => Container(
        width: double.infinity,
        height: 48,
        child: Stack(
          children: [
            Text("your title, or any other box widget you like"),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 0),
                turns: status.isExpanded ? 0 : 0.5,
                child: const Icon(Icons.expand_more),
              ),
            ), 
          ],
        ),
      ),
      sliverPanel: SliverList.list(children: [...]),
    ),
    ```
---
## More Advanced Feature:

- You can use the controller to set/get the status of the panel through `isExpanded`,`isPinned`,`isDisabled`.
    ```dart
    final StickyCollapsablePanelController panelController = StickyCollapsablePanelController(key:'key_1');
    ...
    panelController.isExpanded = true; // or panelController.toggleExpanded();
    ```

- You can disable collapse for any sliver you wanted, just add `disableCollapsable = true`.
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          disableCollapsable = true
          sliverPanel: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```
---
- You can enable iOS style sticky header, just like the system's contact app with just one parameter `iOSStyleSticky = true`.
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          iOSStyleSticky: true,
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliverPanel: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```
    <img src="https://raw.githubusercontent.com/techwn/files/main/imgs/sliver_sticky_collapsable_pannel/ios_style_sticky.gif" width=360 alt="simple Shot">

---
- You can add padding for sliver child (with `paddingBeforeCollapse`), even if the panel is collapsed, the padding still work between headers with  `paddingAfterCollapse`.
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          paddingBeforeCollapse: const EdgeInsets.all(16),
          paddingAfterCollapse: const EdgeInsets.only(bottom: 10),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliverPanel: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```
    <img src="https://raw.githubusercontent.com/techwn/files/main/imgs/sliver_sticky_collapsable_pannel/padding.gif" width=360 alt="simple Shot">

---
## Performance configuration
- You can use optional parameter `headerSize` to speed up the layout process
  - headerSize means width and height of your header，it should keep unchanged during scrolling
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          iOSStyleSticky: true,
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          headerSize: Size(MediaQuery.of(context).size.width, 48),
          sliverPanel: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```
---
## Thanks
- Thanks to [letsar](https://github.com/letsar) with
it's [flutter_sticky_header](https://github.com/letsar/flutter_sticky_header) which provide solid foundation and inspire me for this project.