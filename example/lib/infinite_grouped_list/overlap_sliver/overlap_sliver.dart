import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OverlapSliver extends SingleChildRenderObjectWidget {
  const OverlapSliver({
    super.key,
    super.child = const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.red,
        border: BorderDirectional(bottom: BorderSide()),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: Center(child: Text('Hello World')),
      ),
    ),
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOverlapSliver();
  }
}

class RenderOverlapSliver extends RenderSliver with RenderObjectWithChildMixin<RenderBox>, RenderSliverHelpers {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @protected
  void setChildParentData(RenderObject child, SliverConstraints constraints, SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.paintOffset = switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      AxisDirection.up => Offset(0.0, -(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset))),
      AxisDirection.right => Offset(-constraints.scrollOffset, 0.0),
      AxisDirection.down => Offset(0.0, -constraints.scrollOffset),
      AxisDirection.left => Offset(-(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)), 0.0),
    };
  }

  @override
  double childMainAxisPosition(RenderObject? child) {
    return -constraints.scrollOffset;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null) {
      return hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child!,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void performLayout() {
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: false);
    const maxPaintExtent = 300.0;
    const childExtent = 200.0;
    final paintExtent = calculatePaintOffset(constraints, from: 0, to: maxPaintExtent);
    final layoutExtent = clampDouble(paintExtent - 100, 0, childExtent);
    final cacheExtent = calculateCacheOffset(constraints, from: 0, to: childExtent);
    geometry = SliverGeometry(
      scrollExtent: layoutExtent,
      paintExtent: paintExtent,
      layoutExtent: layoutExtent,
      maxPaintExtent: maxPaintExtent,
      cacheExtent: cacheExtent,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent,
    );
    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      final SliverPhysicalParentData childParentData = child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }
}
