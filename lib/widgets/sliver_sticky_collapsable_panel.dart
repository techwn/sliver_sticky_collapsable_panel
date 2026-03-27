import 'package:flutter/widgets.dart';

import '../rendering/render_sliver_sticky_collapsable_panel.dart';
import '../sliver_sticky_collapsable_panel.dart';
import '../utils/slot.dart';

part '../utils/sliver_sticky_collapsable_panel_controller.dart';

/// Callback used by [SliverStickyCollapsablePanel] to notify when the panel expand status change
typedef ExpandCallback = void Function(bool isExpanded);

/// Signature used by [SliverStickyCollapsablePanel] to build the header
/// when the sticky header status has changed.
typedef HeaderBuilder = Widget Function(BuildContext context, SliverStickyCollapsablePanelStatus status);

/// A sliver that displays a header before its sliver and can allow click to collapse.
/// The header scrolls off the viewport only when the sliver does.
///
/// Place this widget inside a [CustomScrollView] or similar.
class SliverStickyCollapsablePanel extends StatefulWidget {
  const SliverStickyCollapsablePanel({
    Key? key,
    required ScrollController scrollController,
    required StickyCollapsablePanelController panelController,
    required HeaderBuilder headerBuilder,
    Widget? sliverPanel,
    bool sticky = true,
    bool overlapsContent = false,
    ExpandCallback? expandCallback,
    bool iOSStyleSticky = false,
    EdgeInsetsGeometry paddingBeforeCollapse = const EdgeInsets.only(),
    EdgeInsetsGeometry paddingAfterCollapse = const EdgeInsets.only(),
    Size? headerSize,
    Duration panelAnimationDuration = const Duration(milliseconds: 0),
    Cubic panelAnimationCurve = Curves.easeInOut,
  }) : this._(
         key: key,
         scrollController: scrollController,
         panelController: panelController,
         headerBuilder: headerBuilder,
         sliverPanel: sliverPanel,
         sticky: sticky,
         overlapsContent: overlapsContent,
         expandCallback: expandCallback,
         iOSStyleSticky: iOSStyleSticky,
         paddingBeforeCollapse: paddingBeforeCollapse,
         paddingAfterCollapse: paddingAfterCollapse,
         headerSize: headerSize,
         animationDuration: panelAnimationDuration,
         panelAnimationCurve: panelAnimationCurve,
       );

  const SliverStickyCollapsablePanel._({
    super.key,
    required this.scrollController,
    required this.panelController,
    required this.headerBuilder,
    this.sliverPanel,
    required this.sticky,
    required this.overlapsContent,
    this.expandCallback,
    required this.iOSStyleSticky,
    required this.paddingBeforeCollapse,
    required this.paddingAfterCollapse,
    this.headerSize,
    required this.animationDuration,
    required this.panelAnimationCurve,
  });

  final ScrollController scrollController;

  /// The controller used to interact with this sliver.
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

  final ExpandCallback? expandCallback;

  /// Like the iOS contact, header replace another header when it reaches the edge
  final bool iOSStyleSticky;

  /// Padding used for sliver child before collapse
  final EdgeInsetsGeometry paddingBeforeCollapse;

  /// Padding used for sliver child after collapse, it means even it's collapsed, Padding still exist between headers
  final EdgeInsetsGeometry paddingAfterCollapse;

  /// Size of Header, this is used for optimize layout speed
  final Size? headerSize;

  /// Duration of expand/collapse animation for panel sliver.
  final Duration animationDuration;

  /// Curve of the panel animation.
  final Cubic panelAnimationCurve;

  @override
  State<StatefulWidget> createState() => SliverStickyCollapsablePanelState();
}

class SliverStickyCollapsablePanelState extends State<SliverStickyCollapsablePanel>
    with SingleTickerProviderStateMixin {
  late StickyCollapsablePanelController _panelController;
  late AnimationController _animationController;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _bindController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _panelController.isExpanded ? 1 : 0,
    );
    _expansionAnimation = CurvedAnimation(parent: _animationController, curve: widget.panelAnimationCurve);
  }

  @override
  void didUpdateWidget(SliverStickyCollapsablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
    if (oldWidget.panelAnimationCurve != widget.panelAnimationCurve) {
      _expansionAnimation = CurvedAnimation(parent: _animationController, curve: widget.panelAnimationCurve);
    }
    if (oldWidget.panelController != widget.panelController) {
      _unbindController();
      _bindController();
      _animateToExpanded(_panelController.isExpanded);
    }
  }

  void _bindController() {
    _panelController = widget.panelController;
    _panelController._register(_expandPanel);
  }

  void _unbindController() {
    _panelController._unregister();
    _panelController.dispose();
  }

  void _jumpWhenPinned(SliverStickyCollapsablePanelStatus status) {
    if (status.isPinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.scrollController.hasClients) return;
        widget.scrollController.jumpTo(_panelController.precedingScrollExtent);
      });
    }
  }

  void _animateToExpanded(bool expanded) {
    _animationController.animateTo(expanded ? 1 : 0, curve: widget.panelAnimationCurve);
  }

  void _expandPanel(bool isExpanded) {
    setState(() {
      _panelController.isExpanded = isExpanded;
      _animateToExpanded(isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget boxHeader = ValueLayoutBuilder<SliverStickyCollapsablePanelStatus>(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            if (!_panelController.disableCollapsable) {
              setState(() {
                _panelController.isExpanded = !_panelController.isExpanded;
                _jumpWhenPinned(constraints.value);
                _animateToExpanded(_panelController.isExpanded);
                widget.expandCallback?.call(_panelController.isExpanded);
              });
            }
          },
          child: widget.headerBuilder(context, constraints.value),
        );
      },
    );
    final isExpandedNow = _panelController.disableCollapsable || _panelController.isExpanded;
    return _SliverStickyCollapsablePanel(
      boxHeader: boxHeader,
      sliverPanel: SliverPadding(
        padding: isExpandedNow ? widget.paddingBeforeCollapse : widget.paddingAfterCollapse,
        sliver: widget.sliverPanel,
      ),
      overlapsContent: widget.overlapsContent,
      sticky: widget.sticky,
      controller: _panelController,
      isExpanded: isExpandedNow,
      expansionAnimation: _expansionAnimation,
      iOSStyleSticky: widget.iOSStyleSticky,
      headerSize: widget.headerSize,
    );
  }

  @override
  void dispose() {
    _unbindController();
    _animationController.dispose();
    super.dispose();
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
  const _SliverStickyCollapsablePanel({
    required this.boxHeader,
    required this.sliverPanel,
    required this.controller,
    required this.expansionAnimation,
    this.overlapsContent = false,
    this.sticky = true,
    this.isExpanded = true,
    this.iOSStyleSticky = false,
    this.headerSize,
  });

  /// The header to display before the sliver.
  final Widget boxHeader;

  /// The sliver to display after the header.
  final Widget sliverPanel;

  /// The controller used to interact with this sliver.
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

  /// Animation driving panel expansion in render layout.
  final Animation<double> expansionAnimation;

  /// Like the iOS contact, header replace another header when it reaches the viewport edge
  final bool iOSStyleSticky;

  /// Size of Header, this is used for optimize layout speed
  final Size? headerSize;

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
      expansionAnimation: expansionAnimation,
      iOSStyleSticky: iOSStyleSticky,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      headerSize: headerSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverStickyCollapsablePanel renderObject) {
    renderObject
      ..overlapsContent = overlapsContent
      ..sticky = sticky
      ..controller = controller
      ..isExpanded = isExpanded
      ..expansionAnimation = expansionAnimation
      ..iOSStyleSticky = iOSStyleSticky
      ..devicePixelRatio = MediaQuery.of(context).devicePixelRatio
      ..headerSize = headerSize;
  }
}
