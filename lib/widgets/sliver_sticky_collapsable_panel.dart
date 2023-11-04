import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../rendering/render_sliver_sticky_collapsable_panel.dart';
import '../sliver_sticky_collapsable_panel.dart';

typedef ExpandCallback = void Function(bool isExpanded);

/// A sliver that displays a header before its sliver and can allow click to collapse.
/// The header scrolls off the viewport only when the sliver does.
///
/// Place this widget inside a [CustomScrollView] or similar.
class SliverStickyCollapsablePanel extends StatefulWidget {
  const SliverStickyCollapsablePanel.builder({
    Key? key,
    required HeaderBuilder headerBuilder,
    Widget? sliver,
    bool overlapsContent = false,
    bool sticky = true,
    required StickyCollapsablePanelController controller,
    bool defaultExpanded = true,
    required ScrollController scrollController,
    ExpandCallback? expandCallback,
    bool disableCollapsable = false,
  }) : this._(
            key: key,
            headerBuilder: headerBuilder,
            sliver: sliver,
            overlapsContent: overlapsContent,
            sticky: sticky,
            headerController: controller,
            defaultExpanded: defaultExpanded,
            scrollController: scrollController,
            expandCallback: expandCallback,
            disableCollapsable: disableCollapsable);

  const SliverStickyCollapsablePanel._({
    Key? key,
    required this.headerBuilder,
    this.sliver,
    this.overlapsContent = false,
    this.sticky = true,
    required this.headerController,
    this.defaultExpanded = true,
    required this.scrollController,
    this.expandCallback,
    this.disableCollapsable = false,
  }) : super(key: key);

  /// The header to display before the sliver.
  final HeaderBuilder headerBuilder;

  /// The sliver to display after the header.
  final Widget? sliver;

  /// Whether the header should be drawn on top of the sliver
  /// instead of before.
  final bool overlapsContent;

  /// Whether to stick the header.
  /// Defaults to true.
  final bool sticky;

  /// The controller used to interact with this sliver.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of [DefaultStickyCollapsablePanelController.of]
  /// will be used.
  final StickyCollapsablePanelController headerController;

  final bool defaultExpanded;

  final ScrollController scrollController;

  final ExpandCallback? expandCallback;

  final bool disableCollapsable;

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
              if (!isExpanded && constraints.value.isPinned) {
                widget.scrollController.jumpTo(
                    widget.headerController.stickyCollapsablePanelScrollOffset);
              }
            });
            widget.expandCallback?.call(isExpanded);
          }
        },
        child: widget.headerBuilder(context, constraints.value),
      ),
    );
    return _SliverStickyCollapsablePanel(
      header: header,
      sliver: widget.disableCollapsable
          ? widget.sliver
          : isExpanded
              ? widget.sliver
              : null,
      overlapsContent: widget.overlapsContent,
      sticky: widget.sticky,
      controller: widget.headerController,
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
    this.header,
    this.sliver,
    this.overlapsContent = false,
    this.sticky = true,
    this.controller,
  }) : super(key: key);

  /// The header to display before the sliver.
  final Widget? header;

  /// The sliver to display after the header.
  final Widget? sliver;

  /// Whether the header should be drawn on top of the sliver
  /// instead of before.
  final bool overlapsContent;

  /// Whether to stick the header.
  /// Defaults to true.
  final bool sticky;

  /// The controller used to interact with this sliver.
  ///
  /// If a [StickyCollapsablePanelController] is not provided, then the value of [DefaultStickyCollapsablePanelController.of]
  /// will be used.
  final StickyCollapsablePanelController? controller;

  @override
  _SliverStickyCollapsablePanelRenderObjectElement createElement() =>
      _SliverStickyCollapsablePanelRenderObjectElement(this);

  @override
  RenderSliverStickyCollapsablePanel createRenderObject(BuildContext context) {
    return RenderSliverStickyCollapsablePanel(
      overlapsContent: overlapsContent,
      sticky: sticky,
      controller:
          controller ?? DefaultStickyCollapsablePanelController.of(context),
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
      ..controller =
          controller ?? DefaultStickyCollapsablePanelController.of(context);
  }
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
    if (child == _header) _header = null;
    if (child == _sliver) _sliver = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _header = updateChild(_header, widget.header, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void update(_SliverStickyCollapsablePanel newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _header = updateChild(_header, widget.header, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  RenderSliverStickyCollapsablePanel get renderObject {
    assert(super.renderObject is RenderSliverStickyCollapsablePanel,
        'renderObject type should be Render_SliverStickyCollapsablePanel');
    return super.renderObject as RenderSliverStickyCollapsablePanel;
  }

  @override
  void insertRenderObjectChild(RenderObject child, int? slot) {
    if (slot == 0) renderObject.headerChild = child as RenderBox?;
    if (slot == 1) renderObject.sliverChild = child as RenderSliver?;
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
