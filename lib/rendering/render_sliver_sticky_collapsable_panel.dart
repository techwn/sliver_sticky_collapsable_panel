import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/utils.dart';

/// A sliver with a [RenderBox] as header and a [RenderSliver] as child.
///
/// The [headerChild] stays pinned when it hits the start of the viewport until
/// the [sliverChild] scrolls off the viewport.
class RenderSliverStickyCollapsablePanel extends RenderSliver
    with RenderSliverHelpers {
  RenderSliverStickyCollapsablePanel({
    RenderBox? headerChild,
    RenderSliver? sliverChild,
    required bool overlapsContent,
    required bool sticky,
    required StickyCollapsablePanelController controller,
    required bool isExpanded,
    required bool iOSStyleSticky,
  })  : _overlapsContent = overlapsContent,
        _sticky = sticky,
        _isExpanded = isExpanded,
        _iOSStyleSticky = iOSStyleSticky,
        _controller = controller {
    this.headerChild = headerChild;
    this.sliverChild = sliverChild;
  }

  SliverStickyCollapsablePanelStatus? _oldStatus;

  double _headerExtent = 0;

  late bool _isPinned;

  void updateIsPinned() {
    _isPinned = _sticky &&
        geometry!.visible &&
        constraints.scrollOffset > 0 &&
        constraints.overlap == 0;
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
    // We copy the status of the old controller.
    value.precedingScrollExtent = _controller.precedingScrollExtent;
    _controller = value;
  }

  RenderBox? _headerChild;

  RenderBox? get headerChild => _headerChild;

  set headerChild(RenderBox? value) {
    if (_headerChild != null) dropChild(_headerChild!);
    _headerChild = value;
    if (_headerChild != null) adoptChild(_headerChild!);
  }

  RenderSliver? _sliverChild;

  RenderSliver? get sliverChild => _sliverChild;

  set sliverChild(RenderSliver? value) {
    if (_sliverChild != null) dropChild(_sliverChild!);
    _sliverChild = value;
    if (_sliverChild != null) adoptChild(_sliverChild!);
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
    if (_headerChild != null) _headerChild!.attach(owner);
    if (_sliverChild != null) _sliverChild!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (_headerChild != null) _headerChild!.detach();
    if (_sliverChild != null) _sliverChild!.detach();
  }

  @override
  void redepthChildren() {
    if (_headerChild != null) redepthChild(_headerChild!);
    if (_sliverChild != null) redepthChild(_sliverChild!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_headerChild != null) visitor(_headerChild!);
    if (_sliverChild != null) visitor(_sliverChild!);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    List<DiagnosticsNode> result = <DiagnosticsNode>[];
    if (headerChild != null) {
      result.add(headerChild!.toDiagnosticsNode(name: 'headerChild'));
    }
    if (sliverChild != null) {
      result.add(sliverChild!.toDiagnosticsNode(name: 'sliverChild'));
    }
    return result;
  }

  double computeHeaderExtent() {
    if (headerChild == null) return 0;
    assert(headerChild!.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return headerChild!.size.height;
      case Axis.horizontal:
        return headerChild!.size.width;
    }
  }

  double get headerAndOverLapExtent => _headerExtent + constraints.overlap;

  @override
  void performLayout() {
    if (headerChild == null && sliverChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final axisDirection = applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    );
    if (headerChild != null) {
      headerChild!.layout(
        BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
          value: _oldStatus ??
              SliverStickyCollapsablePanelStatus(0, false, _isExpanded),
          constraints: constraints.asBoxConstraints(),
        ),
        parentUsesSize: true,
      );
    }
    _headerExtent = computeHeaderExtent();
    final double headerAndOverlapPaintExtent =
        calculatePaintOffset(constraints, from: 0, to: headerAndOverLapExtent);
    final double headerAndOverlapCacheExtent =
        calculateCacheOffset(constraints, from: 0, to: headerAndOverLapExtent);
    if (sliverChild == null) {
      geometry = SliverGeometry(
        scrollExtent: headerAndOverLapExtent,
        maxPaintExtent: headerAndOverLapExtent,
        paintExtent: headerAndOverlapPaintExtent,
        cacheExtent: headerAndOverlapCacheExtent,
        hitTestExtent: headerAndOverlapPaintExtent,
        hasVisualOverflow: _headerExtent > headerAndOverlapPaintExtent,
      );
    } else {
      sliverChild!.layout(
        constraints.copyWith(
          scrollOffset: math.max(
            0,
            constraints.scrollOffset - childScrollOffset(sliverChild!),
          ),
          cacheOrigin: math.min(
            0,
            constraints.cacheOrigin + childScrollOffset(sliverChild!),
          ),
          overlap: 0,
          remainingPaintExtent: math.max(
            0,
            constraints.remainingPaintExtent - headerAndOverlapPaintExtent,
          ),
          remainingCacheExtent: math.max(
            0,
            constraints.remainingCacheExtent - headerAndOverlapCacheExtent,
          ),
          precedingScrollExtent: math.max(
            0,
            constraints.precedingScrollExtent + childScrollOffset(sliverChild!),
          ),
        ),
        parentUsesSize: true,
      );
      final SliverGeometry sliverChildLayoutGeometry = sliverChild!.geometry!;
      if (sliverChildLayoutGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
          scrollOffsetCorrection:
              sliverChildLayoutGeometry.scrollOffsetCorrection,
        );
        return;
      }
      final paintExtent = math.min(
        headerAndOverlapPaintExtent + sliverChildLayoutGeometry.paintExtent,
        constraints.remainingPaintExtent,
      );
      geometry = SliverGeometry(
        paintOrigin: sliverChildLayoutGeometry.paintOrigin,
        scrollExtent: childScrollOffset(sliverChild!) +
            sliverChildLayoutGeometry.scrollExtent,
        paintExtent: paintExtent,
        layoutExtent: math.min(
          headerAndOverlapPaintExtent + sliverChildLayoutGeometry.layoutExtent,
          paintExtent,
        ),
        cacheExtent: math.min(
          headerAndOverlapCacheExtent + sliverChildLayoutGeometry.cacheExtent,
          constraints.remainingCacheExtent,
        ),
        maxPaintExtent: childScrollOffset(sliverChild!) +
            sliverChildLayoutGeometry.maxPaintExtent,
        hitTestExtent: math.max(
          headerAndOverlapPaintExtent + sliverChildLayoutGeometry.paintExtent,
          headerAndOverlapPaintExtent + sliverChildLayoutGeometry.hitTestExtent,
        ),
        hasVisualOverflow: sliverChildLayoutGeometry.hasVisualOverflow,
      );
      final childParentData =
          sliverChild!.parentData as SliverPhysicalParentData;
      switch (axisDirection) {
        case AxisDirection.up:
        case AxisDirection.left:
          childParentData.paintOffset = Offset.zero;
          break;
        case AxisDirection.right:
          childParentData.paintOffset = Offset(
            calculatePaintOffset(
              constraints,
              from: 0,
              to: childScrollOffset(
                sliverChild!,
              ),
            ),
            0,
          );
          break;
        case AxisDirection.down:
          childParentData.paintOffset = Offset(
            0,
            calculatePaintOffset(
              constraints,
              from: 0,
              to: childScrollOffset(sliverChild!),
            ),
          );
          break;
      }
    }
    if (headerChild != null) {
      updateIsPinned();
      final headerPosition = childMainAxisPosition(headerChild);
      double headerScrollRatio =
          ((headerPosition - constraints.overlap).abs() / _headerExtent);
      //calibration scrollRation
      if (nearZero(headerScrollRatio, Tolerance.defaultTolerance.distance)) {
        headerScrollRatio = 0;
      } else if (nearEqual(
          1.0, headerScrollRatio, Tolerance.defaultTolerance.distance)) {
        headerScrollRatio = 1.0;
      }
      if (_isPinned && headerScrollRatio <= 1) {
        _controller.precedingScrollExtent = constraints.precedingScrollExtent;
      }
      if (headerChild is RenderConstrainedLayoutBuilder<
          BoxValueConstraints<SliverStickyCollapsablePanelStatus>, RenderBox>) {
        final double headerScrollRatioClamped = headerScrollRatio.clamp(0, 1.0);
        final status = SliverStickyCollapsablePanelStatus(
            headerScrollRatioClamped, _isPinned, _isExpanded);
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
          hitTestExtent: geometry!.hitTestExtent + headerAndOverLapExtent,
          visible: geometry!.visible,
          hasVisualOverflow: geometry!.hasVisualOverflow,
          scrollOffsetCorrection: geometry!.scrollOffsetCorrection,
          cacheExtent: geometry!.cacheExtent,
        );
      }
      final headerParentData =
          headerChild!.parentData as SliverPhysicalParentData;
      switch (axisDirection) {
        case AxisDirection.up:
          headerParentData.paintOffset = Offset(
            0,
            geometry!.paintExtent - headerPosition - _headerExtent,
          );
          break;
        case AxisDirection.down:
          headerParentData.paintOffset = Offset(0, headerPosition);
          break;
        case AxisDirection.left:
          headerParentData.paintOffset = Offset(
            geometry!.paintExtent - headerPosition - _headerExtent,
            0,
          );
          break;
        case AxisDirection.right:
          headerParentData.paintOffset = Offset(headerPosition, 0);
          break;
      }
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0);

    bool tryHitTestSliverChild() {
      if (sliverChild != null && sliverChild!.geometry!.hitTestExtent > 0) {
        return sliverChild!.hitTest(
          result,
          mainAxisPosition:
              mainAxisPosition - childMainAxisPosition(sliverChild),
          crossAxisPosition: crossAxisPosition,
        );
      }
      return false;
    }

    double headerPosition = childMainAxisPosition(headerChild);
    if (headerChild != null &&
        (mainAxisPosition - headerPosition) <= _headerExtent) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        headerChild!,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
      if (didHitHeader) {
        return didHitHeader;
      } else if (_overlapsContent) {
        return tryHitTestSliverChild();
      } else {
        return didHitHeader;
      }
    } else {
      return tryHitTestSliverChild();
    }
  }

  @override
  double childMainAxisPosition(RenderObject? child) {
    if (child == headerChild) {
      final double sliverChildScrollExtent =
          sliverChild!.geometry!.scrollExtent;
      final double headerPosition = _iOSStyleSticky
          ? (_isPinned ? 0 : -(constraints.scrollOffset - constraints.overlap))
          : (_isPinned
              ? math.min(
                  0,
                  sliverChildScrollExtent -
                      constraints.scrollOffset -
                      (_overlapsContent ? _headerExtent : 0))
              : -(constraints.scrollOffset - constraints.overlap));
      return headerPosition;
    }
    if (child == sliverChild) {
      return calculatePaintOffset(
        constraints,
        from: 0,
        to: childScrollOffset(sliverChild!) + constraints.overlap,
      );
    }
    return 0;
  }

  @override
  double childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    if (child == headerChild) {
      return constraints.overlap;
    } else {
      return _overlapsContent ? constraints.overlap : headerAndOverLapExtent;
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
      if (sliverChild!.geometry!.visible) {
        final childParentData =
            sliverChild!.parentData as SliverPhysicalParentData;
        context.paintChild(sliverChild!, offset + childParentData.paintOffset);
      }
      if (headerChild != null) {
        final headerParentData =
            headerChild!.parentData as SliverPhysicalParentData;
        context.paintChild(headerChild!, offset + headerParentData.paintOffset);
      }
    }
  }
}
