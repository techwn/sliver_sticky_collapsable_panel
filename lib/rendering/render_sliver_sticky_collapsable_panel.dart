import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/slot.dart';
import '../utils/utils.dart';
import '../widgets/sliver_sticky_collapsable_panel.dart';

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
    required Animation<double> expansionAnimation,
    required bool iOSStyleSticky,
    required double devicePixelRatio,
    required Size? headerSize,
    required EdgeInsetsGeometry padding,
  }) : _overlapsContent = overlapsContent,
       _sticky = sticky,
       _isExpanded = isExpanded,
       _expansionAnimation = expansionAnimation,
       _iOSStyleSticky = iOSStyleSticky,
       _controller = controller,
       _tolerance = 1 / devicePixelRatio,
       _headerSize = headerSize,
       _padding = padding {
    _expansionAnimation?.addListener(_handleExpansionTick);
  }

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
    if (_oldStatus != null) _oldStatus = _oldStatus!.copyWith(isExpanded: _isExpanded);
    markNeedsLayout();
  }

  Animation<double>? _expansionAnimation;

  set expansionAnimation(Animation<double>? value) {
    if (_expansionAnimation == value) return;
    _expansionAnimation?.removeListener(_handleExpansionTick);
    _expansionAnimation = value;
    _expansionAnimation?.addListener(_handleExpansionTick);
    markNeedsLayout();
  }

  void _handleExpansionTick() {
    markNeedsLayout();
  }

  double get _expansionProgress {
    if (_expansionAnimation == null) {
      return _isExpanded ? 1 : 0;
    }
    return _expansionAnimation!.value.clamp(0.0, 1.0);
  }

  bool _iOSStyleSticky;

  set iOSStyleSticky(bool value) {
    if (_iOSStyleSticky == value) return;
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

  Size? _headerSize;

  set headerSize(Size? value) {
    if (_headerSize == value) return;
    _headerSize = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry _padding;

  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  get paddingExtent {
    switch (constraints.axis) {
      case Axis.vertical:
        return _padding.vertical;
      case Axis.horizontal:
        return _padding.horizontal;
    }
  }

  @override
  void dispose() {
    _expansionAnimation?.removeListener(_handleExpansionTick);
    super.dispose();
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
    if (_headerSize != null) {
      return switch (constraints.axis) {
        Axis.vertical => _headerSize!.height,
        Axis.horizontal => _headerSize!.width,
      };
    } else {
      assert(headerChild.hasSize);
      return switch (constraints.axis) {
        Axis.vertical => headerChild.size.height,
        Axis.horizontal => headerChild.size.width,
      };
    }
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final axisDirection = applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);
    //layout header first(but not compute paint offset), so we can compute constraints of sliver child
    if (_headerSize == null) {
      headerChild.layout(
        BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
          value: _oldStatus ?? SliverStickyCollapsablePanelStatus(0, false, _isExpanded),
          constraints: constraints.asBoxConstraints(),
        ),
        parentUsesSize: true,
      );
    }
    _headerExtent = computeHeaderExtent();
    final double panelChildScrollOffset = childScrollOffset(panelChild);
    final double headerAndOverlapPaintExtent = calculatePaintOffset(constraints, from: 0, to: panelChildScrollOffset);
    final double headerAndOverlapCacheExtent = calculateCacheOffset(constraints, from: 0, to: panelChildScrollOffset);
    //layout sliver child, and compute paint offset
    panelChild.layout(
      constraints.copyWith(
        scrollOffset: math.max(0, constraints.scrollOffset - panelChildScrollOffset),
        cacheOrigin: math.min(0, constraints.cacheOrigin + panelChildScrollOffset),
        overlap: 0,
        remainingPaintExtent: math.max(0, constraints.remainingPaintExtent - headerAndOverlapPaintExtent),
        remainingCacheExtent: math.max(0, constraints.remainingCacheExtent - headerAndOverlapCacheExtent),
        precedingScrollExtent: math.max(0, constraints.precedingScrollExtent + panelChildScrollOffset),
      ),
      parentUsesSize: true,
    );
    final SliverGeometry panelChildGeometry = panelChild.geometry!;
    if (panelChildGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(scrollOffsetCorrection: panelChildGeometry.scrollOffsetCorrection);
      return;
    }
    final expansionProgress = _expansionProgress;
    final paintExtent = math.min(
      headerAndOverlapPaintExtent + panelChildGeometry.paintExtent * expansionProgress,
      constraints.remainingPaintExtent,
    );
    if (paintExtent > paddingExtent) {
      final paintExtent = math.min(
        headerAndOverlapPaintExtent + math.max(panelChildGeometry.paintExtent * expansionProgress, paddingExtent),
        constraints.remainingPaintExtent,
      );
      geometry = SliverGeometry(
        paintOrigin: panelChildGeometry.paintOrigin,
        scrollExtent:
            panelChildScrollOffset + math.max(panelChildGeometry.scrollExtent * expansionProgress, paddingExtent),
        paintExtent: paintExtent,
        layoutExtent: math.min(
          headerAndOverlapPaintExtent + math.max(panelChildGeometry.layoutExtent * expansionProgress, paddingExtent),
          paintExtent,
        ),
        cacheExtent: math.min(
          headerAndOverlapCacheExtent + math.max(panelChildGeometry.cacheExtent * expansionProgress, paddingExtent),
          constraints.remainingCacheExtent,
        ),
        maxPaintExtent:
            panelChildScrollOffset + math.max(panelChildGeometry.maxPaintExtent * expansionProgress, paddingExtent),
        hitTestExtent: math.max(
          headerAndOverlapPaintExtent + math.max(panelChildGeometry.paintExtent * expansionProgress, paddingExtent),
          headerAndOverlapPaintExtent + math.max(panelChildGeometry.hitTestExtent * expansionProgress, paddingExtent),
        ),
        hasVisualOverflow: panelChildGeometry.hasVisualOverflow,
      );
    } else {
      geometry = SliverGeometry(
        paintOrigin: panelChildGeometry.paintOrigin,
        scrollExtent: panelChildScrollOffset + panelChildGeometry.scrollExtent * expansionProgress,
        paintExtent: paintExtent,
        layoutExtent: math.min(
          headerAndOverlapPaintExtent + panelChildGeometry.layoutExtent * expansionProgress,
          paintExtent,
        ),
        cacheExtent: math.min(
          headerAndOverlapCacheExtent + panelChildGeometry.cacheExtent * expansionProgress,
          constraints.remainingCacheExtent,
        ),
        maxPaintExtent: panelChildScrollOffset + panelChildGeometry.maxPaintExtent * expansionProgress,
        hitTestExtent: math.max(
          headerAndOverlapPaintExtent + panelChildGeometry.paintExtent * expansionProgress,
          headerAndOverlapPaintExtent + panelChildGeometry.hitTestExtent * expansionProgress,
        ),
        hasVisualOverflow: panelChildGeometry.hasVisualOverflow,
      );
    }

    final panelParentData = panelChild.parentData as SliverPhysicalParentData;
    panelParentData.paintOffset = switch (axisDirection) {
      AxisDirection.up || AxisDirection.left => Offset.zero,
      AxisDirection.right => Offset(headerAndOverlapPaintExtent, 0),
      AxisDirection.down => Offset(0, headerAndOverlapPaintExtent),
    };
    //update constraints of header if needed, update header paint Offset
    updateIsPinned();
    final headerPosition = childMainAxisPosition(headerChild);
    double headerScrollRatio = (((headerPosition - constraints.overlap).abs() / _headerExtent)).clamp(0, 1);
    if (nearZero(headerScrollRatio, _tolerance)) {
      headerScrollRatio = 0;
    } else if (nearEqual(1, headerScrollRatio, _tolerance)) {
      headerScrollRatio = 1;
    }
    if (_controller.precedingScrollExtent != constraints.precedingScrollExtent) {
      _controller.precedingScrollExtent = constraints.precedingScrollExtent;
    }
    final status = SliverStickyCollapsablePanelStatus(headerScrollRatio, _isPinned, _isExpanded);
    if (_oldStatus != status || _headerSize != null) {
      _oldStatus = status;
      headerChild.layout(
        BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
          value: _oldStatus!,
          constraints: constraints.asBoxConstraints(),
        ),
        parentUsesSize: true,
      );
    }
    if (_iOSStyleSticky) {
      geometry = geometry!.copyWith(hitTestExtent: geometry!.hitTestExtent + panelChildScrollOffset);
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
    assert(child == headerChild || child == panelChild);
    final SliverConstraints constraints = this.constraints;
    final panelScrollExtent = math.max(panelChild.geometry!.scrollExtent * _expansionProgress, paddingExtent);
    return switch (child) {
      RenderBox _ =>
        _iOSStyleSticky
            ? (_isPinned ? constraints.overlap : -(constraints.scrollOffset - constraints.overlap))
            : (_isPinned
                  ? math.min(
                      constraints.overlap,
                      panelScrollExtent - constraints.scrollOffset - (_overlapsContent ? _headerExtent : 0),
                    )
                  : -(constraints.scrollOffset - constraints.overlap)),
      _ => calculatePaintOffset(constraints, from: 0, to: childScrollOffset(panelChild)),
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
      if (panelChild.geometry!.visible && _expansionProgress != 0) {
        final panelParentData = panelChild.parentData as SliverPhysicalParentData;
        final panelOffset = offset + panelParentData.paintOffset;
        if (_expansionProgress == 1) {
          context.paintChild(panelChild, panelOffset);
        } else {
          context.pushClipRect(
            needsCompositing,
            panelOffset,
            Offset(0, 0) & Size(constraints.crossAxisExtent, panelChild.geometry!.paintExtent),
            (context, offset) => context.pushOpacity(
              offset,
              lerpDouble(0, 255, _expansionProgress)!.toInt(),
              (context, offset) => context.paintChild(panelChild, offset),
            ),
          );
        }
      }
      final headerParentData = headerChild.parentData as SliverPhysicalParentData;
      context.paintChild(headerChild, offset + headerParentData.paintOffset);
    }
  }
}
