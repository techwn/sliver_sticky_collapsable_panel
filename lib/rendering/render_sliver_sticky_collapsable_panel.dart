import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/utils.dart';

/// A sliver with a [RenderBox] as header and a [RenderSliver] as child.
///
/// The [headerChild] stays pinned when it hits the start of the viewport until
/// the [panelChild] scrolls off the viewport.
class RenderSliverStickyCollapsablePanel extends RenderSliver with RenderSliverHelpers {
  RenderSliverStickyCollapsablePanel({
    RenderBox? headerChild,
    RenderSliver? panelChild,
    required bool overlapsContent,
    required bool sticky,
    required StickyCollapsablePanelController controller,
    required bool isExpanded,
    required bool iOSStyleSticky,
    required double devicePixelRatio,
  })  : _overlapsContent = overlapsContent,
        _sticky = sticky,
        _isExpanded = isExpanded,
        _iOSStyleSticky = iOSStyleSticky,
        _controller = controller,
        _tolerance = 1 / devicePixelRatio {
    this.headerChild = headerChild;
    this.panelChild = panelChild;
  }

  SliverStickyCollapsablePanelStatus? _oldStatus;

  double _headerExtent = 0;

  late bool _isPinned;

  void updateIsPinned() {
    _isPinned = _sticky && geometry!.visible && constraints.scrollOffset > 0 && constraints.overlap == 0;
  }

  bool _iOSStyleSticky;

  set iOSStyleSticky(bool value) {
    if (value == _iOSStyleSticky) return;
    _iOSStyleSticky = value;
    markNeedsLayout();
  }

  bool _isExpanded;

  set isExpanded(bool value) {
    if (_isExpanded == value) return;
    _isExpanded = value;
    markNeedsLayout();
  }

  bool _overlapsContent;

  set overlapsContent(bool value) {
    if (_overlapsContent == value) return;
    _overlapsContent = value;
    markNeedsLayout();
  }

  bool _sticky;

  set sticky(bool value) {
    if (_sticky == value) return;
    _sticky = value;
    markNeedsLayout();
  }

  StickyCollapsablePanelController _controller;

  set controller(StickyCollapsablePanelController value) {
    if (_controller == value) return;
    value.precedingScrollExtent = _controller.precedingScrollExtent;
    _controller = value;
  }

  double _tolerance;

  set devicePixelRatio(double value) {
    final tolerance = 1 / value;
    if (_tolerance == tolerance) return;
    _tolerance = tolerance;
    markNeedsLayout();
  }

  RenderBox? _headerChild;

  RenderBox? get headerChild => _headerChild;

  set headerChild(RenderBox? value) {
    if (_headerChild != null) dropChild(_headerChild!);
    _headerChild = value;
    if (_headerChild != null) adoptChild(_headerChild!);
  }

  RenderSliver? _panelChild;

  RenderSliver? get panelChild => _panelChild;

  set panelChild(RenderSliver? value) {
    if (_panelChild != null) dropChild(_panelChild!);
    _panelChild = value;
    if (_panelChild != null) adoptChild(_panelChild!);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    headerChild?.attach(owner);
    panelChild?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    headerChild?.detach();
    panelChild?.detach();
  }

  @override
  void redepthChildren() {
    if (headerChild != null) redepthChild(headerChild!);
    if (panelChild != null) redepthChild(panelChild!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (headerChild != null) visitor(headerChild!);
    if (panelChild != null) visitor(panelChild!);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    List<DiagnosticsNode> result = <DiagnosticsNode>[];
    if (headerChild != null) {
      result.add(headerChild!.toDiagnosticsNode(name: 'headerChild'));
    }
    if (panelChild != null) {
      result.add(panelChild!.toDiagnosticsNode(name: 'panelChild'));
    }
    return result;
  }

  double computeHeaderExtent() {
    assert(headerChild!.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return headerChild!.size.height;
      case Axis.horizontal:
        return headerChild!.size.width;
    }
  }

  @override
  void performLayout() {
    assert(headerChild != null && panelChild != null);
    final axisDirection = applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);
    //layout header first(but not compute paint offset), so we can compute constraints of sliver child
    headerChild!.layout(
      BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
        value: _oldStatus ?? SliverStickyCollapsablePanelStatus(0, false, _isExpanded),
        constraints: constraints.asBoxConstraints(),
      ),
      parentUsesSize: true,
    );
    _headerExtent = computeHeaderExtent();
    final double headerAndOverlapPaintExtent =
        calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild!));
    final double headerAndOverlapCacheExtent =
        calculateCacheOffset(constraints, from: 0, to: childScrollOffset(panelChild!));
    //layout sliver child, and compute paint offset
    panelChild!.layout(
      constraints.copyWith(
        scrollOffset: math.max(0, constraints.scrollOffset - childScrollOffset(panelChild!)),
        cacheOrigin: math.min(0, constraints.cacheOrigin + childScrollOffset(panelChild!)),
        overlap: 0,
        remainingPaintExtent: math.max(0, constraints.remainingPaintExtent - headerAndOverlapPaintExtent),
        remainingCacheExtent: math.max(0, constraints.remainingCacheExtent - headerAndOverlapCacheExtent),
        precedingScrollExtent: math.max(0, constraints.precedingScrollExtent + childScrollOffset(panelChild!)),
      ),
      parentUsesSize: true,
    );
    final SliverGeometry panelChildGeometry = panelChild!.geometry!;
    if (panelChildGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(scrollOffsetCorrection: panelChildGeometry.scrollOffsetCorrection);
      return;
    }
    geometry = SliverGeometry(
      paintOrigin: panelChildGeometry.paintOrigin,
      scrollExtent: childScrollOffset(panelChild!) + panelChildGeometry.scrollExtent,
      paintExtent: math.min(
        headerAndOverlapPaintExtent + panelChildGeometry.paintExtent,
        constraints.remainingPaintExtent,
      ),
      cacheExtent: math.min(
        headerAndOverlapCacheExtent + panelChildGeometry.cacheExtent,
        constraints.remainingCacheExtent,
      ),
      maxPaintExtent: childScrollOffset(panelChild!) + panelChildGeometry.maxPaintExtent,
      hitTestExtent: math.max(
        headerAndOverlapPaintExtent + panelChildGeometry.paintExtent,
        headerAndOverlapPaintExtent + panelChildGeometry.hitTestExtent,
      ),
      hasVisualOverflow: panelChildGeometry.hasVisualOverflow,
    );
    final childParentData = panelChild!.parentData as SliverPhysicalParentData;
    switch (axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        childParentData.paintOffset = Offset.zero;
        break;
      case AxisDirection.right:
        childParentData.paintOffset =
            Offset(calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild!)), 0);
        break;
      case AxisDirection.down:
        childParentData.paintOffset =
            Offset(0, calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild!)));
        break;
    }
    //update constraints of header if needed, update header paint Offset
    updateIsPinned();
    final headerPosition = childMainAxisPosition(headerChild!);
    double headerScrollRatio = (((headerPosition - constraints.overlap).abs() / _headerExtent)).clamp(0, 1);
    if (nearZero(headerScrollRatio, _tolerance)) {
      headerScrollRatio = 0;
    } else if (nearEqual(1.0, headerScrollRatio, _tolerance)) {
      headerScrollRatio = 1.0;
    }
    if (_controller.precedingScrollExtent != constraints.precedingScrollExtent) {
      _controller.precedingScrollExtent = constraints.precedingScrollExtent;
    }
    if (headerChild
        is RenderConstrainedLayoutBuilder<BoxValueConstraints<SliverStickyCollapsablePanelStatus>, RenderBox>) {
      final status = SliverStickyCollapsablePanelStatus(headerScrollRatio, _isPinned, _isExpanded);
      if (_oldStatus != status) {
        _oldStatus = status;
        headerChild!.layout(
          BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
            value: _oldStatus!,
            constraints: constraints.asBoxConstraints(),
          ),
          parentUsesSize: true,
        );
      }
    }
    if (_iOSStyleSticky) {
      geometry = SliverGeometry(
        scrollExtent: geometry!.scrollExtent,
        paintExtent: geometry!.paintExtent,
        paintOrigin: geometry!.paintOrigin,
        layoutExtent: geometry!.layoutExtent,
        maxPaintExtent: geometry!.maxPaintExtent,
        maxScrollObstructionExtent: geometry!.maxScrollObstructionExtent,
        hitTestExtent: geometry!.hitTestExtent + childScrollOffset(panelChild!),
        visible: geometry!.visible,
        hasVisualOverflow: geometry!.hasVisualOverflow,
        scrollOffsetCorrection: geometry!.scrollOffsetCorrection,
        cacheExtent: geometry!.cacheExtent,
      );
    }
    final headerParentData = headerChild!.parentData as SliverPhysicalParentData;
    switch (axisDirection) {
      case AxisDirection.up:
        headerParentData.paintOffset = Offset(0, geometry!.paintExtent - headerPosition - _headerExtent);
        break;
      case AxisDirection.down:
        headerParentData.paintOffset = Offset(0, headerPosition);
        break;
      case AxisDirection.left:
        headerParentData.paintOffset = Offset(geometry!.paintExtent - headerPosition - _headerExtent, 0);
        break;
      case AxisDirection.right:
        headerParentData.paintOffset = Offset(headerPosition, 0);
        break;
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0);
    bool tryHitTestPanelChild() {
      if (panelChild!.geometry!.hitTestExtent > 0) {
        return panelChild!.hitTest(
          result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(panelChild!),
          crossAxisPosition: crossAxisPosition,
        );
      }
      return false;
    }

    double headerPosition = childMainAxisPosition(headerChild!);
    if ((mainAxisPosition - headerPosition) <= _headerExtent) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        headerChild!,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
      if (didHitHeader) {
        return didHitHeader;
      } else if (_overlapsContent) {
        return tryHitTestPanelChild();
      } else {
        return didHitHeader;
      }
    } else {
      return tryHitTestPanelChild();
    }
  }

  @override
  double childMainAxisPosition(RenderObject child) {
    assert(child == headerChild || child == panelChild);
    final panelScrollExtent = panelChild!.geometry!.scrollExtent;
    if (child == headerChild) {
      final double headerPosition = _iOSStyleSticky
          ? (_isPinned ? constraints.overlap : -(constraints.scrollOffset - constraints.overlap))
          : (_isPinned
              ? math.min(constraints.overlap,
                  panelScrollExtent - constraints.scrollOffset - (_overlapsContent ? _headerExtent : 0))
              : -(constraints.scrollOffset - constraints.overlap));
      return headerPosition;
    } else {
      return calculatePaintOffset(
        constraints,
        from: 0,
        to: childScrollOffset(panelChild!),
      );
    }
  }

  @override
  double childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    assert(child == headerChild || child == panelChild);
    if (child == headerChild) {
      return constraints.overlap;
    } else {
      return _overlapsContent ? constraints.overlap : _headerExtent + constraints.overlap;
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      if (panelChild!.geometry!.visible) {
        final panelParentData = panelChild!.parentData as SliverPhysicalParentData;
        context.paintChild(panelChild!, offset + panelParentData.paintOffset);
      }
      final headerParentData = headerChild!.parentData as SliverPhysicalParentData;
      context.paintChild(headerChild!, offset + headerParentData.paintOffset);
    }
  }
}
