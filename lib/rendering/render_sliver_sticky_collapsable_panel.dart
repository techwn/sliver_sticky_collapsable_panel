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
  })  : _overlapsContent = overlapsContent,
        _sticky = sticky,
        _controller = controller {
    this.headerChild = headerChild;
    this.sliverChild = sliverChild;
  }

  SliverStickyCollapsablePanelStatus? _oldStatus;
  double _headerExtent = 0;
  late bool _isPinned;

  bool _overlapsContent;

  bool get overlapsContent => _overlapsContent;

  set overlapsContent(bool value) {
    if (_overlapsContent == value) return;
    _overlapsContent = value;
    markNeedsLayout();
  }

  bool _sticky;

  bool get sticky => _sticky;

  set sticky(bool value) {
    if (_sticky == value) return;
    _sticky = value;
    markNeedsLayout();
  }

  StickyCollapsablePanelController? _controller;

  StickyCollapsablePanelController? get controller => _controller;

  set controller(StickyCollapsablePanelController? value) {
    if (_controller == value) return;
    if (_controller != null && value != null) {
      // We copy the status of the old controller.
      value.stickyCollapsablePanelScrollOffset = _controller!.stickyCollapsablePanelScrollOffset;
    }
    _controller = value;
  }

  RenderBox? _header;

  /// The render object's header
  RenderBox? get headerChild => _header;

  set headerChild(RenderBox? value) {
    if (_header != null) dropChild(_header!);
    _header = value;
    if (_header != null) adoptChild(_header!);
  }

  RenderSliver? _sliver;

  /// The render object's unique child
  RenderSliver? get sliverChild => _sliver;

  set sliverChild(RenderSliver? value) {
    if (_sliver != null) dropChild(_sliver!);
    _sliver = value;
    if (_sliver != null) adoptChild(_sliver!);
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
    if (_header != null) _header!.attach(owner);
    if (_sliver != null) _sliver!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (_header != null) _header!.detach();
    if (_sliver != null) _sliver!.detach();
  }

  @override
  void redepthChildren() {
    if (_header != null) redepthChild(_header!);
    if (_sliver != null) redepthChild(_sliver!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_sliver != null) visitor(_sliver!);
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

  double get headerLogicalExtent => overlapsContent ? 0 : _headerExtent;

  //为什么我们不担心会调用performResize，因为RenderSliver类，均不允许sizedByParent
  //想想也是，Sliver都是放在某个纬度无限的Parent里面的，自然不能约束Sliver
  // @override
  // void performResize() {
  //   super.performResize();
  // }

  @override
  void performLayout() {
    if (headerChild == null && sliverChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    // One of them is not null.
    AxisDirection axisDirection =
        applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);

    if (headerChild != null) {
      // 这里先使用_oldStatus来layout，后续会再重试的
      // 这里只是利用RenderBox和constraints来获取header的extent（宽或者高）
      headerChild!.layout(
        BoxValueConstraints<SliverStickyCollapsablePanelStatus>(
          value: _oldStatus ?? const SliverStickyCollapsablePanelStatus(0, false, true),
          constraints: constraints.asBoxConstraints(),
        ),
        parentUsesSize: true,
      );
      _headerExtent = computeHeaderExtent();
    }

    // Compute the header extent only one time.
    // 我们假设header高度50，sliverChild高度100，view port 500，scroll offset 50
    // 我们可以计算出headerPaintExtent是0
    // 我们可以计算出headerCacheExtent是50，
    // 再次假设我们scr0ll offset 是300
    //  那么因为remainingPaintExtent是500，所以计算出的headerPaintExtent是0
    //  那么因为cacheOrigin是-250，remainingCacheExtent是1000，所以计算出的headerCacheExtent是0
    // 再次假设我们scr0ll offset 是400
    //  那么因为remainingPaintExtent是500，所以计算出的headerPaintExtent是0
    //  那么因为cacheOrigin是-250，remainingCacheExtent是1000，所以计算出的headerCacheExtent是0
    double headerExtent = headerLogicalExtent;
    final double headerPaintExtent = calculatePaintOffset(constraints, from: 0, to: headerExtent);
    final double headerCacheExtent = calculateCacheOffset(constraints, from: 0, to: headerExtent);

    if (sliverChild == null) {
      // 这里虽然没有传递所有的参数，但是满足了所有的基本需求
      geometry = SliverGeometry(
          scrollExtent: headerExtent,
          maxPaintExtent: headerExtent,
          paintExtent: headerPaintExtent,
          cacheExtent: headerCacheExtent,
          hitTestExtent: headerPaintExtent,
          hasVisualOverflow: headerExtent > headerPaintExtent);
      //我认为hasVisualOverflow这样写，更准确，可以减少clip操作
      // hasVisualOverflow: headerExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0);
    } else {
      sliverChild!.layout(
        //这里五个参数，是必须的，其他的约束默认使用parent的约束，这里模拟的是一个去掉顶部高度的viewport约束
        constraints.copyWith(
          scrollOffset: math.max(0, constraints.scrollOffset - headerExtent),
          cacheOrigin: math.min(0, constraints.cacheOrigin + headerExtent),
          //为什么重叠不是一个固定的值？
          //因为headerExtent不为0的情况下，存在一个滚动后重叠的情况
          //headerExtent为0的情况下，重叠一直是0
          //为什么+一个值：这个我也没搞明白，我觉得第二行我写的是对的，为啥还有区分sticky，有点不懂
          //  这个我暂时没法验证，除非我能构造一个上一个sliver突出到下一个sliver的case😂
          overlap: math.min(headerExtent, constraints.scrollOffset) + (sticky ? constraints.overlap : 0),
          // overlap: math.min(headerExtent, constraints.scrollOffset) + constraints.overlap),
          remainingPaintExtent: constraints.remainingPaintExtent - headerPaintExtent,
          remainingCacheExtent: constraints.remainingCacheExtent - headerCacheExtent,
        ),
        parentUsesSize: true,
      );
      final SliverGeometry sliverChildLayoutGeometry = sliverChild!.geometry!;
      if (sliverChildLayoutGeometry.scrollOffsetCorrection != null) {
        //这个scrollOffsetCorrection属性注释说的非常明白了，只要这个值不为0，会要求重新layout的，所以赋值后直接return
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
        maxScrollObstructionExtent: sticky ? headerPaintExtent : 0,
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

    //根据前面的scrollOffset校正，再次尝试矫正header的滚动距离
    if (headerChild != null) {
      final SliverPhysicalParentData? headerParentData = headerChild!.parentData as SliverPhysicalParentData?;
      final double sliverChildScrollExtent = sliverChild?.geometry?.scrollExtent ?? 0;

      //这里之所以不允许constraints.scrollOffset + constraints.overlap) = 0的情况,是因为所有尚未滚动到顶部的sliver，一般情况下都是0
      //这会导致所有header都想pin到viewport顶部，比如我们折叠的时候，会根据这个对列表执行jumpTo操作，就会受到干扰
      //如果overlap > 0,那么第二个判断会一直为真，即便没有滚动到viewport顶部，
      //只有title在顶部的时候，哪怕被推出去一部分，也算是pin，那么琢磨下这段代码：
      //remainingPaintExtent代表剩余的extent，因为paintExtent可能大于layoutExtent，所以绘制可能到了外面。
      // _isPinned = sticky &&
      //     ((constraints.scrollOffset + constraints.overlap) > 0 ||
      //         constraints.remainingPaintExtent == constraints.viewportMainAxisExtent);
      // 我认为，只有sliver真正的开始滚动，并且还在viewport可见的情况下,pin才应该生效,
      // 而且提前了这个计算，让下面的headerPosition计算使用这个flag
      _isPinned = sticky && ((constraints.scrollOffset + constraints.overlap) > 0 && geometry!.visible);

      //为啥作者这里的计算是正确的，
      //作者设计的效果是：当header不足一个高度时，header逐渐被推出屏幕
      //对于overlapsContent=false的情况，滚动过整个childScrollExtent的时候，高度正好是0，然后就是负数了
      //对于overlapsContent=true的情况，滚动过childScrollExtent - headerExtent的的时候，正好是0，然后就是负数了
      //这里的position，是sliver体系的坐标, 从使用sticky改为使用_isPinned
      final double headerPosition = _isPinned
          ? math.min(constraints.overlap,
              sliverChildScrollExtent - constraints.scrollOffset - (overlapsContent ? _headerExtent : 0))
          : -constraints.scrollOffset;

      //     sticky ? math.min(constraints.overlap, scrollExtent - constraints.scrollOffset) : -constraints.scrollOffset;

      final double headerScrollRatio = ((headerPosition - constraints.overlap).abs() / _headerExtent);
      if (_isPinned && headerScrollRatio <= 1) {
        controller?.stickyCollapsablePanelScrollOffset = constraints.precedingScrollExtent;
      }
      // second layout if scroll percentage changed and header is a RenderStickyCollapsablePanelLayoutBuilder.
      if (headerChild
          is RenderConstrainedLayoutBuilder<BoxValueConstraints<SliverStickyCollapsablePanelStatus>, RenderBox>) {
        double headerScrollRatioClamped = headerScrollRatio.clamp(0, 1.0);

        SliverStickyCollapsablePanelStatus status =
            SliverStickyCollapsablePanelStatus(headerScrollRatioClamped, _isPinned, sliverChild != null);
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

    _isPinned = sticky && ((constraints.scrollOffset + constraints.overlap) > 0 && geometry!.visible);
    final double sliverChildScrollExtent = sliverChild?.geometry?.scrollExtent ?? 0;
    final double headerPosition = _isPinned
        ? math.min(constraints.overlap,
            sliverChildScrollExtent - constraints.scrollOffset - (overlapsContent ? _headerExtent : 0))
        : -constraints.scrollOffset;

    if (headerChild != null && (mainAxisPosition - headerPosition) <= _headerExtent) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(SliverHitTestResult.wrap(result)),
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

  /// 主轴方向，相对ViewPort的leading edge的决定偏移量
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

  /// 滚动偏移量，指的是需要滚动特定组件顶部所需要的距离
  /// 比如header，就是0， sliver就是_headerExtent（当漂浮在item顶部的时候为0，否则为header的高度）
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

      // The header must be drawn over the sliver, so draw it at last.
      if (headerChild != null) {
        final SliverPhysicalParentData headerParentData = headerChild!.parentData as SliverPhysicalParentData;
        context.paintChild(headerChild!, offset + headerParentData.paintOffset);
      }
    }
  }
}
