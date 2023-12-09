import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import '../utils/utils.dart';

/// A sliver with a [RenderBox] as header and a [RenderSliver] as child.
///
/// The [headerChild] stays pinned when it hits the start of the viewport until
/// the [sliverChild] scrolls off the viewport.
class RenderSliverStickyCollapsablePanel extends RenderSliver with RenderSliverHelpers {
  RenderSliverStickyCollapsablePanel({
    RenderBox? headerChild,
    RenderSliver? sliverChild,
    bool overlapsContent = false,
    bool sticky = true,
    StickyCollapsablePanelController? controller,
    bool isExpanded = true,
    bool iOSStyleSticky = false,
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

  StickyCollapsablePanelController? _controller;

  set controller(StickyCollapsablePanelController? value) {
    if (_controller == value) return;
    if (_controller != null && value != null) {
      // We copy the status of the old controller.
      value.stickyCollapsablePanelScrollOffset = _controller!.stickyCollapsablePanelScrollOffset;
    }
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
      result.add(headerChild!.toDiagnosticsNode(name: 'header'));
    }
    if (sliverChild != null) {
      result.add(sliverChild!.toDiagnosticsNode(name: 'child'));
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

  double get headerLogicalExtent => _overlapsContent ? 0 : _headerExtent;

  double computeHeaderPosition() {
    final double scrollExtent = geometry!.scrollExtent;
    final double sliverChildScrollExtent = sliverChild?.geometry?.scrollExtent ?? 0;
    final double headerPosition = _iOSStyleSticky
        ? (_isPinned
            ? math.min(constraints.overlap, scrollExtent - constraints.scrollOffset)
            : -constraints.scrollOffset)
        : (_isPinned
            ? math.min(constraints.overlap,
                sliverChildScrollExtent - constraints.scrollOffset - (_overlapsContent ? _headerExtent : 0))
            : -constraints.scrollOffset);
    return headerPosition;
  }

  @override
  void performLayout() {
    if (headerChild == null && sliverChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    AxisDirection axisDirection =
        applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);

    if (headerChild != null) {
      headerChild!.layout(
        BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
          value: _oldStatus ?? SliverStickyCollapsablePanelStatus(0, false, _isExpanded),
          constraints: constraints.asBoxConstraints(),
        ),
        parentUsesSize: true,
      );
    }
    _headerExtent = computeHeaderExtent();

    double headerExtent = headerLogicalExtent;
    final double headerPaintExtent = calculatePaintOffset(constraints, from: 0, to: headerExtent);
    final double headerCacheExtent = calculateCacheOffset(constraints, from: 0, to: headerExtent);

    if (sliverChild == null) {
      geometry = SliverGeometry(
          scrollExtent: headerExtent,
          maxPaintExtent: headerExtent,
          paintExtent: headerPaintExtent,
          cacheExtent: headerCacheExtent,
          hitTestExtent: headerPaintExtent,
          hasVisualOverflow: headerExtent > headerPaintExtent);
    } else {
      sliverChild!.layout(
        constraints.copyWith(
          scrollOffset: math.max(0, constraints.scrollOffset - headerExtent),
          cacheOrigin: math.min(0, constraints.cacheOrigin + headerExtent),
          overlap: math.min(headerExtent, constraints.scrollOffset) + (_sticky ? constraints.overlap : 0),
          // overlap: math.min(headerExtent, constraints.scrollOffset) + constraints.overlap),
          remainingPaintExtent: constraints.remainingPaintExtent - headerPaintExtent,
          remainingCacheExtent: constraints.remainingCacheExtent - headerCacheExtent,
        ),
        parentUsesSize: true,
      );
      final SliverGeometry sliverChildLayoutGeometry = sliverChild!.geometry!;
      if (sliverChildLayoutGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: sliverChildLayoutGeometry.scrollOffsetCorrection,
        );
        return;
      }

      final double paintExtent = math.min(
        headerPaintExtent + math.max(sliverChildLayoutGeometry.paintExtent, sliverChildLayoutGeometry.layoutExtent),
        constraints.remainingPaintExtent,
      );

      geometry = SliverGeometry(
        scrollExtent: headerExtent + sliverChildLayoutGeometry.scrollExtent,
        maxScrollObstructionExtent: _sticky ? headerPaintExtent : 0,
        paintExtent: paintExtent,
        layoutExtent: math.min(headerPaintExtent + sliverChildLayoutGeometry.layoutExtent, paintExtent),
        cacheExtent:
            math.min(headerCacheExtent + sliverChildLayoutGeometry.cacheExtent, constraints.remainingCacheExtent),
        maxPaintExtent: headerExtent + sliverChildLayoutGeometry.maxPaintExtent,
        hitTestExtent: math.max(headerPaintExtent + sliverChildLayoutGeometry.paintExtent,
            headerPaintExtent + sliverChildLayoutGeometry.hitTestExtent),
        hasVisualOverflow: sliverChildLayoutGeometry.hasVisualOverflow,
      );

      final SliverPhysicalParentData? childParentData = sliverChild!.parentData as SliverPhysicalParentData?;
      switch (axisDirection) {
        case AxisDirection.up:
        case AxisDirection.left:
          childParentData!.paintOffset = Offset.zero;
          break;
        case AxisDirection.right:
          childParentData!.paintOffset = Offset(calculatePaintOffset(constraints, from: 0, to: headerExtent), 0);
          break;
        case AxisDirection.down:
          childParentData!.paintOffset = Offset(0, calculatePaintOffset(constraints, from: 0, to: headerExtent));
          break;
      }
    }

    if (headerChild != null) {
      final SliverPhysicalParentData? headerParentData = headerChild!.parentData as SliverPhysicalParentData?;

      _isPinned = _sticky && ((constraints.scrollOffset + constraints.overlap) > 0 && geometry!.visible);

      double headerPosition = computeHeaderPosition();

      final double headerScrollRatio = ((headerPosition - constraints.overlap).abs() / _headerExtent);
      if (_isPinned && headerScrollRatio <= 1) {
        _controller?.stickyCollapsablePanelScrollOffset = constraints.precedingScrollExtent;
      }
      if (headerChild
          is RenderConstrainedLayoutBuilder<BoxValueConstraints<SliverStickyCollapsablePanelStatus>, RenderBox>) {
        double headerScrollRatioClamped = headerScrollRatio.clamp(0, 1.0);

        SliverStickyCollapsablePanelStatus status =
            SliverStickyCollapsablePanelStatus(headerScrollRatioClamped, _isPinned, _isExpanded);
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
          hitTestExtent: geometry!.hitTestExtent + headerExtent,
          visible: geometry!.visible,
          hasVisualOverflow: geometry!.hasVisualOverflow,
          scrollOffsetCorrection: geometry!.scrollOffsetCorrection,
          cacheExtent: geometry!.cacheExtent,
        );
      }

      switch (axisDirection) {
        case AxisDirection.up:
          headerParentData!.paintOffset = Offset(0, geometry!.paintExtent - headerPosition - _headerExtent);
          break;
        case AxisDirection.down:
          headerParentData!.paintOffset = Offset(0, headerPosition);
          break;
        case AxisDirection.left:
          headerParentData!.paintOffset = Offset(geometry!.paintExtent - headerPosition - _headerExtent, 0);
          break;
        case AxisDirection.right:
          headerParentData!.paintOffset = Offset(headerPosition, 0);
          break;
      }
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0);

    _isPinned = _sticky && ((constraints.scrollOffset + constraints.overlap) > 0 && geometry!.visible);
    double headerPosition = computeHeaderPosition();

    if (headerChild != null && (mainAxisPosition - headerPosition) <= _headerExtent) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        headerChild!,
        mainAxisPosition: mainAxisPosition - childMainAxisPosition(headerChild) - headerPosition,
        crossAxisPosition: crossAxisPosition,
      );

      return didHitHeader ||
          (_overlapsContent &&
              sliverChild != null &&
              sliverChild!.geometry!.hitTestExtent > 0 &&
              sliverChild!.hitTest(result,
                  mainAxisPosition: mainAxisPosition - childMainAxisPosition(sliverChild),
                  crossAxisPosition: crossAxisPosition));
    } else if (sliverChild != null && sliverChild!.geometry!.hitTestExtent > 0) {
      return sliverChild!.hitTest(result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(sliverChild),
          crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderObject? child) {
    if (child == headerChild) {
      return _isPinned ? 0 : -(constraints.scrollOffset + constraints.overlap);
    }
    if (child == sliverChild) {
      return calculatePaintOffset(constraints, from: 0, to: headerLogicalExtent);
    }
    return 0;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    if (child == headerChild) {
      return super.childScrollOffset(child);
    } else {
      return _headerExtent;
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final SliverPhysicalParentData childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry?.visible == true) {
      if (sliverChild?.geometry?.visible == true) {
        final SliverPhysicalParentData childParentData = sliverChild!.parentData as SliverPhysicalParentData;
        context.paintChild(sliverChild!, offset + childParentData.paintOffset);
      }

      if (headerChild != null) {
        final SliverPhysicalParentData headerParentData = headerChild!.parentData as SliverPhysicalParentData;
        context.paintChild(headerChild!, offset + headerParentData.paintOffset);
      }
    }
  }
}
