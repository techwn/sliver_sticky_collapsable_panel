import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_sticky_collapsable_panel/sliver_sticky_collapsable_panel.dart';
import 'package:sliver_tools/sliver_tools.dart';

void main() {
  testWidgets('Mix sticky and not sticky headers', (WidgetTester tester) async {
    final StickyCollapsablePanelController stickyCollapsablePanelController = StickyCollapsablePanelController();
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            cacheExtent: 0,
            slivers: <Widget>[
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _Header(index: 0),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
                sliverPanel: const _Sliver(),
              ),
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _Header(index: 1),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
                sliverPanel: const _Sliver(),
              ),
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _Header(index: 2),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
                sliverPanel: const _Sliver(),
              ),
            ],
          ),
        ),
      ),
    );

    final header00Finder = find.text('Header #0');
    final header01Finder = find.text('Header #1');
    final header02Finder = find.text('Header #2');

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsNothing);
    expect(header02Finder, findsNothing);

    final gesture = await tester.startGesture(const Offset(200, 100));

    // We scroll just before the Header #1.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsNothing);
    expect(header02Finder, findsNothing);

    // We scroll just after the Header #1 so that it is visible.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);

    // We scroll in a way that Headers 0 and 1 are side by side.
    await gesture.moveBy(const Offset(0, -640));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);

    // We scroll in a way that Header #1 is at the top of the screen.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsNothing);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);

    // We scroll in a way that Header #1 is not visible.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsNothing);
    // Header #1 is in the tree (because the sliver is onstage).
    expect(tester.getRect(header01Finder), const Rect.fromLTRB(0, 0, 400, 80));
    expect(header02Finder, findsNothing);
  });

  testWidgets('Mix sticky and not sticky headers - reverse', (WidgetTester tester) async {
    final StickyCollapsablePanelController stickyCollapsablePanelController = StickyCollapsablePanelController();
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            cacheExtent: 0,
            reverse: true,
            slivers: <Widget>[
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _Header(index: 0),
                sliverPanel: const _Sliver(),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
              ),
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _Header(index: 1),
                sliverPanel: const _Sliver(),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
              ),
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _Header(index: 2),
                sliverPanel: const _Sliver(),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
              ),
            ],
          ),
        ),
      ),
    );

    final header00Finder = find.text('Header #0');
    final header01Finder = find.text('Header #1');
    final header02Finder = find.text('Header #2');

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsNothing);
    expect(header02Finder, findsNothing);

    final gesture = await tester.startGesture(const Offset(200, 100));

    // We scroll just before the Header #1.
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsNothing);
    expect(header02Finder, findsNothing);

    // We scroll just after the Header #1 so that it is visible.
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);

    // We scroll in a way that Headers 0 and 1 are side by side.
    await gesture.moveBy(const Offset(0, 640));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);

    // We scroll in a way that Header #1 is at the top of the screen.
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(header00Finder, findsNothing);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);

    // We scroll in a way that Header #1 is no longer visible.
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(header00Finder, findsNothing);
    // Header #1 is in the tree (because the sliver is onstage).
    expect(tester.getRect(header01Finder), const Rect.fromLTRB(0, 720, 400, 800));
    expect(header02Finder, findsNothing);
  });

  testWidgets('Testing multi-depth sticky headers', (tester) async {
    final StickyCollapsablePanelController stickyCollapsablePanelController = StickyCollapsablePanelController();
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            cacheExtent: 0,
            slivers: <Widget>[
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '1'),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
                sliverPanel: MultiSliver(
                  children: [
                    SliverStickyCollapsablePanel(
                      headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '1.1'),
                      controller: stickyCollapsablePanelController,
                      scrollController: scrollController,
                      sliverPanel: const _Sliver100(),
                    ),
                    SliverStickyCollapsablePanel(
                      headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '1.2'),
                      controller: stickyCollapsablePanelController,
                      scrollController: scrollController,
                      sliverPanel: MultiSliver(
                        children: [
                          SliverStickyCollapsablePanel(
                            headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '1.2.1'),
                            controller: stickyCollapsablePanelController,
                            scrollController: scrollController,
                            sliverPanel: const _Sliver100(),
                          ),
                          SliverStickyCollapsablePanel(
                            headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '1.2.2'),
                            controller: stickyCollapsablePanelController,
                            scrollController: scrollController,
                            sliverPanel: const _Sliver100(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '2'),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
                sliverPanel: const _Sliver100(),
              ),
              SliverStickyCollapsablePanel(
                headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '3'),
                controller: stickyCollapsablePanelController,
                scrollController: scrollController,
                sliverPanel: MultiSliver(
                  children: [
                    SliverStickyCollapsablePanel(
                      headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '3.1'),
                      controller: stickyCollapsablePanelController,
                      scrollController: scrollController,
                      sliverPanel: const _Sliver100(),
                    ),
                    SliverStickyCollapsablePanel(
                      headerBuilder: (_, status) => const _HierarchyHeader(hierarchy: '3.2'),
                      controller: stickyCollapsablePanelController,
                      scrollController: scrollController,
                      sliverPanel: const _Sliver100(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final header001Finder = find.text('Header 1');
    final header011Finder = find.text('Header 1.1');
    final header012Finder = find.text('Header 1.2');
    final header121Finder = find.text('Header 1.2.1');

    expect(header001Finder, findsOneWidget);
    expect(header011Finder, findsOneWidget);
    expect(header012Finder, findsOneWidget);
    expect(header121Finder, findsOneWidget);

    expect(tester.getTopLeft(header011Finder).dy, 50);
    expect(tester.getTopLeft(header012Finder).dy, 200);
    expect(tester.getTopLeft(header121Finder).dy, 250);

    // We scroll a little and expect that header 1 is sticky.
    final gesture = await tester.startGesture(const Offset(200, 100));
    await gesture.moveBy(const Offset(0, -25));
    await tester.pump();

    expect(tester.getTopLeft(header011Finder).dy, 50);
    expect(tester.getTopLeft(header012Finder).dy, 175);
    expect(tester.getTopLeft(header121Finder).dy, 225);

    await gesture.moveBy(const Offset(0, -125));
    await tester.pump();

    expect(tester.getTopLeft(header011Finder).dy, 0);
    expect(tester.getTopLeft(header012Finder).dy, 50);
    expect(tester.getTopLeft(header121Finder).dy, 100);

    await gesture.moveBy(const Offset(0, -25));
    await tester.pump();

    expect(tester.getTopLeft(header012Finder).dy, 50);
    expect(tester.getTopLeft(header121Finder).dy, 100);
  });
}

class _HierarchyHeader extends StatelessWidget {
  const _HierarchyHeader({
    required this.hierarchy,
  });

  final String hierarchy;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 50,
      child: Text('Header $hierarchy'),
    );
  }
}

class _Sliver100 extends StatelessWidget {
  const _Sliver100();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox(height: 100),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 80,
      child: Text('Header #$index'),
    );
  }
}

class _Sliver extends StatelessWidget {
  const _Sliver();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => const _SliverItem(),
        childCount: 20,
      ),
    );
  }
}

class _SliverItem extends StatelessWidget {
  const _SliverItem();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 40);
  }
}
