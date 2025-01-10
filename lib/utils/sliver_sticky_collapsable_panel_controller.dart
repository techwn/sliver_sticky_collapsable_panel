import 'package:flutter/foundation.dart';

/// Controller to manage Sticker Header
class StickyCollapsablePanelController with ChangeNotifier {
  final String key;

  StickyCollapsablePanelController({this.key = 'default'});

  /// The offset used as calibration when collapse/expand the panel
  double _precedingScrollExtent = 0;

  /// Whether the panel is expanded or collapsed
  bool _isExpanded = false;

  /// Whether the panel is disabled (non-interactive)
  bool _isDisabled = false;

  /// Whether the panel is pinned to its position
  bool _isPinned = false;

  double get precedingScrollExtent => _precedingScrollExtent;

  set precedingScrollExtent(double value) {
    if (_precedingScrollExtent != value) {
      _precedingScrollExtent = value;
      notifyListeners();
    }
  }

  bool get isExpanded => _isExpanded;

  set isExpanded(bool value) {
    if (_isExpanded != value) {
      _isExpanded = value;
      notifyListeners();
    }
  }

  void toggleExpanded() {
    isExpanded = !isExpanded;
  }

  bool get isDisabled => _isDisabled;

  set isDisabled(bool value) {
        if (_isDisabled != value) {
      _isDisabled = value;
      notifyListeners();
    }
  }

    bool get isPinned => _isPinned;
  set isPinned(bool value) {
    if (_isPinned != value) {
      _isPinned = value;
      notifyListeners();
    }
  }
}
