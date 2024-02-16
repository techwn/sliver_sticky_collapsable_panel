import 'package:flutter/widgets.dart';

/// Status describing how a sticky header is rendered.
@immutable
class SliverStickyCollapsablePanelStatus {
  const SliverStickyCollapsablePanelStatus(
    this.scrollPercentage,
    this.isPinned,
    this.isExpanded,
  );

  final double scrollPercentage;

  final bool isPinned;

  final bool isExpanded;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SliverStickyCollapsablePanelStatus) return false;
    return scrollPercentage == other.scrollPercentage && isPinned == other.isPinned && isExpanded == other.isExpanded;
  }

  @override
  int get hashCode {
    return Object.hash(scrollPercentage, isPinned, isExpanded);
  }
}
