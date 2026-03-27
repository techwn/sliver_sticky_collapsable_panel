part of '../widgets/sliver_sticky_collapsable_panel.dart';

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

  /// Layout-time update that avoids notification storms during scrolling.
  set precedingScrollExtent(double value) {
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
