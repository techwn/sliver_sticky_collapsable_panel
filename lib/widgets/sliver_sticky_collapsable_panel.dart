import 'package:flutter/widgets.dart';

import '../rendering/render_sliver_sticky_collapsable_panel.dart';
import '../sliver_sticky_collapsable_panel.dart';
import '../utils/slot.dart';

/// Callback used by [SliverStickyCollapsablePanel] to notify when the panel expand status change
typedef ExpandCallback = void Function(bool isExpanded);

/// Signature used by [SliverStickyCollapsablePanel] to build the header
/// when the sticky header status has changed.
typedef HeaderBuilder = Widget Function(BuildContext context, SliverStickyCollapsablePanelStatus status);

/// Controller to manage Sticker Header
class StickyCollapsablePanelController with ChangeNotifier {
  StickyCollapsablePanelController({
    this.key = 'default',
    this.disableCollapsable = false,
    this.defaultExpanded = true,
  }) {
    _isExpanded = defaultExpanded;
  }

  final String key;
  final bool disableCollapsable;
  final bool defaultExpanded;

  ExpandCallback? _expandCallback;

  void _register(ExpandCallback expandCallback) {
    _expandCallback = expandCallback;
  }

  void _unregister() {
    _expandCallback = null;
  }

  /// The offset used as calibration when collapse/expand the panel
  double _precedingScrollExtent = 0;

  double get precedingScrollExtent => _precedingScrollExtent;

  set precedingScrollExtent(double value) {
    if (_precedingScrollExtent != value) {
      _precedingScrollExtent = value;
      notifyListeners();
    }
  }

  /// Layout-time update that avoids notification storms during scrolling.
  void updatePrecedingScrollExtentFromLayout(double value) {
    if (_precedingScrollExtent != value) {
      _precedingScrollExtent = value;
    }
  }

  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  set isExpanded(bool value) {
    if (_isExpanded != value) {
      _isExpanded = value;
      notifyListeners();
    }
  }

  void collapsePanel() {
    if (disableCollapsable == false && _expandCallback != null) {
      _expandCallback?.call(false);
      isExpanded = false;
    }
  }

  void expandPanel() {
    if (disableCollapsable == false && _expandCallback != null) {
      _expandCallback?.call(true);
      isExpanded = true;
    }
  }

  @override
  void dispose() {
    _expandCallback = null;
    super.dispose();
  }
}

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
  });

  final ScrollController scrollController;

  /// Optional external controller. If null, the widget manages one internally.
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

  @override
  State<StatefulWidget> createState() => SliverStickyCollapsablePanelState();
}

class SliverStickyCollapsablePanelState extends State<SliverStickyCollapsablePanel>
    with SingleTickerProviderStateMixin {
  late StickyCollapsablePanelController _effectiveController;
  late bool isExpanded;
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _bindController();
    _expansionController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: isExpanded ? 1 : 0,
    );
    _expansionAnimation = CurvedAnimation(parent: _expansionController, curve: Curves.easeInOutCubic);
  }

  @override
  void didUpdateWidget(SliverStickyCollapsablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _expansionController.duration = widget.animationDuration;
    }
    if (oldWidget.panelController != widget.panelController) {
      _unbindController();
      _bindController();
      _animateToExpanded(isExpanded);
    }
  }

  void _bindController() {
    _effectiveController = widget.panelController;
    isExpanded = _effectiveController.isExpanded;
    _effectiveController._register(_expandPanel);
  }

  void _unbindController() {
    _effectiveController._unregister();
    _effectiveController.dispose();
  }

  void _jumpWhenPinned(SliverStickyCollapsablePanelStatus status) {
    if (status.isPinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.scrollController.hasClients) return;
        widget.scrollController.jumpTo(_effectiveController.precedingScrollExtent);
      });
    }
  }

  void _animateToExpanded(bool expanded) {
    _expansionController.animateTo(expanded ? 1 : 0, curve: Curves.easeInOutCubic);
  }

  void _expandPanel(bool isExpanded) {
    if (mounted) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
    _animateToExpanded(isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    Widget boxHeader = ValueLayoutBuilder<SliverStickyCollapsablePanelStatus>(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            if (!_effectiveController.disableCollapsable) {
              if (mounted) {
                setState(() {
                  isExpanded = !isExpanded;
                });
                _jumpWhenPinned(constraints.value);
                _animateToExpanded(isExpanded);
                widget.expandCallback?.call(isExpanded);
                _effectiveController.isExpanded = isExpanded;
              }
            }
          },
          child: widget.headerBuilder(context, constraints.value),
        );
      },
    );
    final isExpandedNow = _effectiveController.disableCollapsable || isExpanded;
    return _SliverStickyCollapsablePanel(
      boxHeader: boxHeader,
      sliverPanel: SliverPadding(
        padding: isExpandedNow ? widget.paddingBeforeCollapse : widget.paddingAfterCollapse,
        sliver: widget.sliverPanel,
      ),
      overlapsContent: widget.overlapsContent,
      sticky: widget.sticky,
      controller: _effectiveController,
      isExpanded: isExpandedNow,
      expansionAnimation: _expansionAnimation,
      iOSStyleSticky: widget.iOSStyleSticky,
      headerSize: widget.headerSize,
    );
  }

  @override
  void dispose() {
    _unbindController();
    _expansionController.dispose();
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
