# sliver_sticky_collapsable_panel
A Sliver implementation of sticky collapsable panel, with a box header rebuild on status and a sliver child as panel content.

## Snap Shot
<img src="https://github.com/techwn/files/blob/main/imgs/sliver_sticky_collapsable_pannel/simple_demo.gif?raw=true" width=360 alt="simple Shot">

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

---
## Getting started

- In the `pubspec.yaml` of your flutter project, add the following dependency:

    ```yaml
    dependencies:
      sliver_sticky_collapsable_panel: ^1.1.3
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
        SliverStickyCollapsablePanel.builder(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliver: SliverList.list(children: [...]),
        ),
        SliverStickyCollapsablePanel.builder(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_2'),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliver: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```

- For simple right side header arrow hint `^`, you can build with widget in flutter framework like `AnimatedRotation`:
    ```dart
    SliverStickyCollapsablePanel.builder(
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
      sliver: SliverList.list(children: [...]),
    ),
    ```
---
## More Advanced Feature:

- You can disable collapse for any sliver you wanted, just add `disableCollapsable = true`.
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel.builder(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          disableCollapsable = true
          sliver: SliverList.list(children: [...]),
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
        SliverStickyCollapsablePanel.builder(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          iOSStyleSticky: true,
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliver: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```
    <img src="https://github.com/techwn/files/blob/main/imgs/sliver_sticky_collapsable_pannel/ios_style_sticky.gif?raw=true" width=360 alt="simple Shot">

---
- You can add padding for sliver child (with `paddingBeforeCollapse`), even if the panel is collapsed, the padding still work between headers with  `paddingAfterCollapse`.
    ```dart
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverStickyCollapsablePanel.builder(
          scrollController: _scrollController,
          controller: StickyCollapsablePanelController(key:'key_1'),
          paddingBeforeCollapse: const EdgeInsets.all(16),
          paddingAfterCollapse: const EdgeInsets.only(bottom: 10),
          headerBuilder: (context, status) => SizedBox.fromSize(size: Size.fromHeight(48)),
          sliver: SliverList.list(children: [...]),
        ),
        ...,
      ],
    );
    ```
    <img src="https://github.com/techwn/files/blob/main/imgs/sliver_sticky_collapsable_pannel/padding.gif?raw=true" width=360 alt="simple Shot">

---
## Thanks
- Thanks to [letsar](https://github.com/letsar) with
it's [flutter_sticky_header](https://github.com/letsar/flutter_sticky_header) which provide solid foundation and inspire me for this project.