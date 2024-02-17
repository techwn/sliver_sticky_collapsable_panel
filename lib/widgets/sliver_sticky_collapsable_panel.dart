import 'package:flutter/widgets.dart';

import '../rendering/render_sliver_sticky_collapsable_panel.dart';
import '../sliver_sticky_collapsable_panel.dart';
import '../utils/slot.dart';

/// Callback used by [SliverStickyCollapsablePanel] to notify when the panel expand status change
typedef ExpandCallback = void Function(bool isExpanded);

/// Signature used by [SliverStickyCollapsablePanel] to build the header
/// when the sticky header status has changed.
typedef HeaderBuilder = Widget Function(
  BuildContext context,
  SliverStickyCollapsablePanelStatus status,
);

/// A sliver that displays a header before its sliver and can allow click to collapse.
/// The header scrolls off the viewport only when the sliver does.
///
/// Place this widget inside a [CustomScrollView] or similar.
class SliverStickyCollapsablePanel extends StatefulWidget {
  const SliverStickyCollapsablePanel({
    Key? key,
    required ScrollController scrollController,
    required StickyCollapsablePanelController controller,
    required HeaderBuilder headerBuilder,
    Widget? sliverPanel,
    bool sticky = true,
    bool overlapsContent = false,
    bool defaultExpanded = true,
    ExpandCallback? expandCallback,
    bool disableCollapsable = false,
    bool iOSStyleSticky = false,
    EdgeInsetsGeometry paddingBeforeCollapse = const EdgeInsets.only(),
    EdgeInsetsGeometry paddingAfterCollapse = const EdgeInsets.only(),
  }) : this._(
          key: key,
          scrollController: scrollController,
          panelController: controller,
          headerBuilder: headerBuilder,
          sliverPanel: sliverPanel,
          sticky: sticky,
          overlapsContent: overlapsContent,
          defaultExpanded: defaultExpanded,
          expandCallback: expandCallback,
          disableCollapsable: disableCollapsable,
          iOSStyleSticky: iOSStyleSticky,
          paddingBeforeCollapse: paddingBeforeCollapse,
          paddingAfterCollapse: paddingAfterCollapse,
        );

  const SliverStickyCollapsablePanel._({
    super.key,
    required this.scrollController,
    required this.panelController,
    required this.headerBuilder,
    this.sliverPanel,
    required this.sticky,
    required this.overlapsContent,
    required this.defaultExpanded,
    this.expandCallback,
    required this.disableCollapsable,
    required this.iOSStyleSticky,
    required this.paddingBeforeCollapse,
    required this.paddingAfterCollapse,
  });

  final ScrollController scrollController;

  /// The controller used to interact with this sliver.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of [DefaultStickyCollapsablePanelController.of]
  /// will be used.
  final StickyCollapsablePanelController panelController;

  /// The header to display before the sliver panel content.
  final HeaderBuilder headerBuilder;

  /// The sliver to display after the header as panel content.
  final Widget? sliverPanel;

  /// Whether to stick the header.
  /// Defaults to true.
  final bool sticky;

  /// Whether the header should be drawn on top of the sliver
  /// instead of before.
  final bool overlapsContent;

  final bool defaultExpanded;

  final ExpandCallback? expandCallback;

  final bool disableCollapsable;

  /// Like the iOS contact, header replace another header when it reaches the edge
  final bool iOSStyleSticky;

  /// Padding used for sliver child before collapse
  final EdgeInsetsGeometry paddingBeforeCollapse;

  /// Padding used for sliver child after collapse, it means even it's collapsed, Padding still exist between headers
  final EdgeInsetsGeometry paddingAfterCollapse;

  @override
  State<StatefulWidget> createState() => SliverStickyCollapsablePanelState();
}

class SliverStickyCollapsablePanelState extends State<SliverStickyCollapsablePanel> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.defaultExpanded;
  }

  @override
  Widget build(BuildContext context) {
    Widget boxHeader = ValueLayoutBuilder<SliverStickyCollapsablePanelStatus>(
      builder: (context, constraints) => GestureDetector(
        onTap: () {
          if (!widget.disableCollapsable) {
            setState(() {
              isExpanded = !isExpanded;
              if (constraints.value.isPinned) {
                widget.scrollController.jumpTo(widget.panelController.precedingScrollExtent);
              }
            });
            widget.expandCallback?.call(isExpanded);
          }
        },
        child: widget.headerBuilder(context, constraints.value),
      ),
    );
    final isExpandedNow = (widget.disableCollapsable || isExpanded);
    return _SliverStickyCollapsablePanel(
      boxHeader: boxHeader,
      sliverPanel: SliverPadding(
        padding: isExpandedNow ? widget.paddingBeforeCollapse : widget.paddingAfterCollapse,
        sliver: isExpandedNow ? widget.sliverPanel : null,
      ),
      overlapsContent: widget.overlapsContent,
      sticky: widget.sticky,
      controller: widget.panelController,
      isExpanded: isExpandedNow,
      iOSStyleSticky: widget.iOSStyleSticky,
    );
  }
}

/// A sliver that displays a header before its sliver.
/// The header scrolls off the viewport only when the sliver does.
///
/// Place this widget inside a [CustomScrollView] or similar.
class _SliverStickyCollapsablePanel extends SlottedMultiChildRenderObjectWidget<Slot, RenderObject> {
  /// Creates a sliver that displays the [boxHeader] before its [sliverPanel], unless
  /// [overlapsContent] it's true.
  /// The [boxHeader] stays pinned when it hits the start of the viewport until
  /// the [sliverPanel] scrolls off the viewport.
  ///
  /// The [overlapsContent] and [sticky] arguments must not be null.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of
  /// [DefaultStickyCollapsablePanelController.of] will be used.
  const _SliverStickyCollapsablePanel({
    required this.boxHeader,
    required this.sliverPanel,
    required this.controller,
    this.overlapsContent = false,
    this.sticky = true,
    this.isExpanded = true,
    this.iOSStyleSticky = false,
  });

  /// The header to display before the sliver.
  final Widget boxHeader;

  /// The sliver to display after the header.
  final Widget sliverPanel;

  /// The controller used to interact with this sliver.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of [DefaultStickyCollapsablePanelController.of]
  /// will be used.
  final StickyCollapsablePanelController controller;

  /// Whether the header should be drawn on top of the sliver
  /// instead of before.
  final bool overlapsContent;

  /// Whether to stick the header.
  /// Defaults to true.
  final bool sticky;

  /// Whether we are expanded,
  /// Default to true.
  final bool isExpanded;

  /// Like the iOS contact, header replace another header when it reaches the viewport edge
  final bool iOSStyleSticky;

  @override
  Iterable<Slot> get slots => Slot.values;

  @override
  Widget childForSlot(Slot slot) {
    return switch (slot) {
      Slot.headerSlot => boxHeader,
      Slot.panelSlot => sliverPanel,
    };
  }

  @override
  RenderSliverStickyCollapsablePanel createRenderObject(BuildContext context) {
    return RenderSliverStickyCollapsablePanel(
        overlapsContent: overlapsContent,
        sticky: sticky,
        controller: controller,
        isExpanded: isExpanded,
        iOSStyleSticky: iOSStyleSticky,
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverStickyCollapsablePanel renderObject,
  ) {
    renderObject
      ..overlapsContent = overlapsContent
      ..sticky = sticky
      ..controller = controller
      ..isExpanded = isExpanded
      ..iOSStyleSticky = iOSStyleSticky
      ..devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  }
}
