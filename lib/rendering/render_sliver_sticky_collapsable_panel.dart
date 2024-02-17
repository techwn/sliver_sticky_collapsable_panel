import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/slot.dart';
import '../utils/utils.dart';

/// A sliver with a [RenderBox] as header and a [RenderSliver] as child.
///
/// The [headerChild] stays pinned when it hits the start of the viewport until
/// the [panelChild] scrolls off the viewport.
class RenderSliverStickyCollapsablePanel extends RenderSliver
    with SlottedContainerRenderObjectMixin<Slot, RenderObject>, RenderSliverHelpers {
  RenderSliverStickyCollapsablePanel({
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
        _tolerance = 1.0 / devicePixelRatio;

  SliverStickyCollapsablePanelStatus? _oldStatus;

  double _headerExtent = 0;

  late bool _isPinned;

  void updateIsPinned() {
    _isPinned = _sticky && geometry!.visible && constraints.scrollOffset > 0 && constraints.overlap == 0;
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

  bool _isExpanded;

  set isExpanded(bool value) {
    if (_isExpanded == value) return;
    _isExpanded = value;
    markNeedsLayout();
  }

  bool _iOSStyleSticky;

  set iOSStyleSticky(bool value) {
    if (value == _iOSStyleSticky) return;
    _iOSStyleSticky = value;
    markNeedsLayout();
  }

  double _tolerance;

  set devicePixelRatio(double value) {
    final tolerance = 1 / value;
    if (_tolerance == tolerance) return;
    _tolerance = tolerance;
    markNeedsLayout();
  }

  RenderBox get headerChild => childForSlot(Slot.headerSlot) as RenderBox;

  RenderSliver get panelChild => childForSlot(Slot.panelSlot) as RenderSliver;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  double computeHeaderExtent() {
    assert(headerChild.hasSize);
    return switch (constraints.axis) {
      Axis.vertical => headerChild.size.height,
      Axis.horizontal => headerChild.size.width,
    };
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final axisDirection = applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);
    //layout header first(but not compute paint offset), so we can compute constraints of sliver child
    headerChild.layout(
      BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
        value: _oldStatus ?? SliverStickyCollapsablePanelStatus(0, false, _isExpanded),
        constraints: constraints.asBoxConstraints(),
      ),
      parentUsesSize: true,
    );
    _headerExtent = computeHeaderExtent();
    final double headerAndOverlapPaintExtent =
        calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild));
    final double headerAndOverlapCacheExtent =
        calculateCacheOffset(constraints, from: 0, to: childScrollOffset(panelChild));
    //layout sliver child, and compute paint offset
    panelChild.layout(
      constraints.copyWith(
        scrollOffset: math.max(0, constraints.scrollOffset - childScrollOffset(panelChild)),
        cacheOrigin: math.min(0, constraints.cacheOrigin + childScrollOffset(panelChild)),
        overlap: 0,
        remainingPaintExtent: math.max(0, constraints.remainingPaintExtent - headerAndOverlapPaintExtent),
        remainingCacheExtent: math.max(0, constraints.remainingCacheExtent - headerAndOverlapCacheExtent),
        precedingScrollExtent: math.max(0, constraints.precedingScrollExtent + childScrollOffset(panelChild)),
      ),
      parentUsesSize: true,
    );
    final SliverGeometry panelChildGeometry = panelChild.geometry!;
    if (panelChildGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(scrollOffsetCorrection: panelChildGeometry.scrollOffsetCorrection);
      return;
    }
    geometry = SliverGeometry(
      paintOrigin: panelChildGeometry.paintOrigin,
      scrollExtent: childScrollOffset(panelChild) + panelChildGeometry.scrollExtent,
      paintExtent: math.min(
        headerAndOverlapPaintExtent + panelChildGeometry.paintExtent,
        constraints.remainingPaintExtent,
      ),
      cacheExtent: math.min(
        headerAndOverlapCacheExtent + panelChildGeometry.cacheExtent,
        constraints.remainingCacheExtent,
      ),
      maxPaintExtent: childScrollOffset(panelChild) + panelChildGeometry.maxPaintExtent,
      hitTestExtent: math.max(
        headerAndOverlapPaintExtent + panelChildGeometry.paintExtent,
        headerAndOverlapPaintExtent + panelChildGeometry.hitTestExtent,
      ),
      hasVisualOverflow: panelChildGeometry.hasVisualOverflow,
    );
    final childParentData = panelChild.parentData as SliverPhysicalParentData;
    childParentData.paintOffset = switch (axisDirection) {
      AxisDirection.up || AxisDirection.left => Offset.zero,
      AxisDirection.right => Offset(calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild)), 0),
      AxisDirection.down => Offset(0, calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild))),
    };
    //update constraints of header if needed, update header paint Offset
    updateIsPinned();
    final headerPosition = childMainAxisPosition(headerChild);
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
        headerChild.layout(
          BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
            value: _oldStatus!,
            constraints: constraints.asBoxConstraints(),
          ),
          parentUsesSize: true,
        );
      }
    }
    if (_iOSStyleSticky) {
      geometry = geometry!.copyWith(hitTestExtent: geometry!.hitTestExtent + childScrollOffset(panelChild));
    }
    final headerParentData = headerChild.parentData as SliverPhysicalParentData;
    headerParentData.paintOffset = switch (axisDirection) {
      AxisDirection.up => Offset(0, geometry!.paintExtent - headerPosition - _headerExtent),
      AxisDirection.down => Offset(0, headerPosition),
      AxisDirection.left => Offset(geometry!.paintExtent - headerPosition - _headerExtent, 0),
      AxisDirection.right => Offset(headerPosition, 0),
    };
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0);
    bool tryHitTestPanelChild() {
      if (panelChild.geometry!.hitTestExtent > 0) {
        return panelChild.hitTest(
          result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(panelChild),
          crossAxisPosition: crossAxisPosition,
        );
      }
      return false;
    }

    double headerPosition = childMainAxisPosition(headerChild);
    if ((mainAxisPosition - headerPosition) <= _headerExtent) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        headerChild,
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
    final SliverConstraints constraints = this.constraints;
    assert(child == headerChild || child == panelChild);
    final panelScrollExtent = panelChild.geometry!.scrollExtent;
    return switch (child) {
      RenderBox _ => _iOSStyleSticky
          ? (_isPinned ? constraints.overlap : -(constraints.scrollOffset - constraints.overlap))
          : (_isPinned
              ? math.min(constraints.overlap,
                  panelScrollExtent - constraints.scrollOffset - (_overlapsContent ? _headerExtent : 0))
              : -(constraints.scrollOffset - constraints.overlap)),
      _ => calculatePaintOffset(
          constraints,
          from: 0,
          to: childScrollOffset(panelChild),
        ),
    };
  }

  @override
  double childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    assert(child == headerChild || child == panelChild);
    return switch (child) {
      RenderBox _ => constraints.overlap,
      _ => _overlapsContent ? constraints.overlap : _headerExtent + constraints.overlap,
    };
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      if (panelChild.geometry!.visible) {
        final panelParentData = panelChild.parentData as SliverPhysicalParentData;
        context.paintChild(panelChild, offset + panelParentData.paintOffset);
      }
      final headerParentData = headerChild.parentData as SliverPhysicalParentData;
      context.paintChild(headerChild, offset + headerParentData.paintOffset);
    }
  }
}
