import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_sticky_collapsable_panel/sliver_sticky_collapsable_panel.dart';

void main() {
  testWidgets('stickyCollapsablePanelController.stickyCollapsablePanelScrollOffset', (WidgetTester tester) async {
    final StickyCollapsablePanelController stickyCollapsablePanelController = StickyCollapsablePanelController();
    final ScrollController scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            cacheExtent: 0,
            controller: scrollController,
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
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    final gesture = await tester.startGesture(const Offset(200, 100));

    // We scroll just before the Header #1.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsNothing);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    // We scroll just after the Header #1 so that it is visible.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    // We scroll in a way that Headers 0 and 1 are side by side.
    await gesture.moveBy(const Offset(0, -640));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    // We scroll in a way that Header #1 is at the top of the screen.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    // We scroll in a way that Header #1 is not visible.
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(header00Finder, findsNothing);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(880));
  });

  testWidgets('stickyCollapsablePanelController.stickyCollapsablePanelScrollOffset - reverse',
      (WidgetTester tester) async {
    final StickyCollapsablePanelController stickyCollapsablePanelController = StickyCollapsablePanelController();
    final ScrollController scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            controller: scrollController,
            cacheExtent: 0,
            reverse: true,
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
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    final gesture = await tester.startGesture(const Offset(200, 100));

    // We scroll just before the Header #1.
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsNothing);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    // We scroll just after the Header #1 so that it is visible.
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));

    // We scroll in a way that Headers 0 and 1 are side by side.
    await gesture.moveBy(const Offset(0, 640));
    await tester.pump();

    expect(header00Finder, findsOneWidget);
    expect(header01Finder, findsOneWidget);
    expect(header02Finder, findsNothing);
    expect(stickyCollapsablePanelController.precedingScrollExtent, equals(0));
  });
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
