import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../rendering/render_sliver_sticky_collapsable_panel.dart';
import '../sliver_sticky_collapsable_panel.dart';

/// Callback used by [SliverStickyCollapsablePanel.builder] to notify when the panel expand status change
typedef ExpandCallback = void Function(bool isExpanded);

/// Signature used by [SliverStickyCollapsablePanel.builder] to build the header
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
  const SliverStickyCollapsablePanel.builder({
    Key? key,
    required ScrollController scrollController,
    required StickyCollapsablePanelController controller,
    required HeaderBuilder headerBuilder,
    Widget? sliver,
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
          sliver: sliver,
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
    Key? key,
    required this.scrollController,
    required this.panelController,
    required this.headerBuilder,
    this.sliver,
    required this.sticky,
    required this.overlapsContent,
    required this.defaultExpanded,
    this.expandCallback,
    required this.disableCollapsable,
    required this.iOSStyleSticky,
    required this.paddingBeforeCollapse,
    required this.paddingAfterCollapse,
  }) : super(key: key);

  final ScrollController scrollController;

  /// The controller used to interact with this sliver.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of [DefaultStickyCollapsablePanelController.of]
  /// will be used.
  final StickyCollapsablePanelController panelController;

  /// The header to display before the sliver.
  final HeaderBuilder headerBuilder;

  /// The sliver to display after the header.
  final Widget? sliver;

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

class SliverStickyCollapsablePanelState
    extends State<SliverStickyCollapsablePanel> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.defaultExpanded;
  }

  @override
  Widget build(BuildContext context) {
    Widget header = ValueLayoutBuilder<SliverStickyCollapsablePanelStatus>(
      builder: (context, constraints) => GestureDetector(
        onTap: () {
          if (!widget.disableCollapsable) {
            setState(() {
              isExpanded = !isExpanded;
              if (constraints.value.isPinned) {
                widget.scrollController
                    .jumpTo(widget.panelController.precedingScrollExtent);
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
      header: header,
      sliver: SliverPadding(
        padding: isExpandedNow
            ? widget.paddingBeforeCollapse
            : widget.paddingAfterCollapse,
        sliver: isExpandedNow ? widget.sliver : null,
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
class _SliverStickyCollapsablePanel extends RenderObjectWidget {
  /// Creates a sliver that displays the [header] before its [sliver], unless
  /// [overlapsContent] it's true.
  /// The [header] stays pinned when it hits the start of the viewport until
  /// the [sliver] scrolls off the viewport.
  ///
  /// The [overlapsContent] and [sticky] arguments must not be null.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of
  /// [DefaultStickyCollapsablePanelController.of] will be used.
  const _SliverStickyCollapsablePanel({
    Key? key,
    required this.header,
    required this.sliver,
    required this.controller,
    this.overlapsContent = false,
    this.sticky = true,
    this.isExpanded = true,
    this.iOSStyleSticky = false,
  }) : super(key: key);

  /// The header to display before the sliver.
  final Widget header;

  /// The sliver to display after the header.
  final Widget sliver;

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
  _SliverStickyCollapsablePanelRenderObjectElement createElement() =>
      _SliverStickyCollapsablePanelRenderObjectElement(this);

  @override
  RenderSliverStickyCollapsablePanel createRenderObject(BuildContext context) {
    return RenderSliverStickyCollapsablePanel(
      overlapsContent: overlapsContent,
      sticky: sticky,
      controller: controller,
      isExpanded: isExpanded,
      iOSStyleSticky: iOSStyleSticky,
    );
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
      ..iOSStyleSticky = iOSStyleSticky;
  }
}

enum _Slot {
  headerSlot,
  sliverSlot,
}

class _SliverStickyCollapsablePanelRenderObjectElement
    extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  _SliverStickyCollapsablePanelRenderObjectElement(
      _SliverStickyCollapsablePanel widget)
      : super(widget);

  @override
  _SliverStickyCollapsablePanel get widget =>
      super.widget as _SliverStickyCollapsablePanel;

  Element? _header;

  Element? _sliver;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_sliver != null) visitor(_sliver!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _header || child == _sliver);
    if (child == _header) _header = null;
    if (child == _sliver) _sliver = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _header = updateChild(_header, widget.header, _Slot.headerSlot);
    _sliver = updateChild(_sliver, widget.sliver, _Slot.sliverSlot);
  }

  @override
  void update(_SliverStickyCollapsablePanel newWidget) {
    super.update(newWidget);
    _header = updateChild(_header, widget.header, _Slot.headerSlot);
    _sliver = updateChild(_sliver, widget.sliver, _Slot.sliverSlot);
  }

  @override
  RenderSliverStickyCollapsablePanel get renderObject {
    return super.renderObject as RenderSliverStickyCollapsablePanel;
  }

  @override
  void insertRenderObjectChild(RenderObject child, _Slot slot) {
    switch (slot) {
      case _Slot.headerSlot:
        renderObject.headerChild = child as RenderBox;
        break;
      case _Slot.sliverSlot:
        renderObject.sliverChild = child as RenderSliver;
        break;
    }
  }

  @override
  void moveRenderObjectChild(RenderObject child, oldSlot, newSlot) {
    assert(false,
        '_SliverStickyCollapsablePanelRenderObjectElement.moveRenderObjectChild should never called');
  }

  @override
  void removeRenderObjectChild(RenderObject child, slot) {
    if (renderObject.headerChild == child) renderObject.headerChild = null;
    if (renderObject.sliverChild == child) renderObject.sliverChild = null;
  }
}
