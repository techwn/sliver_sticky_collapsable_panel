import 'package:flutter/foundation.dart';

/// Controller to manage Sticker Header
class StickyCollapsablePanelController with ChangeNotifier {
  StickyCollapsablePanelController({this.key = 'default'});

  final String key;

  /// The offset used as calibration when collapse/expand the panel
  double _precedingScrollExtent = 0;

  double get precedingScrollExtent => _precedingScrollExtent;

  set precedingScrollExtent(double value) {
    if (_precedingScrollExtent != value) {
      _precedingScrollExtent = value;
      notifyListeners();
    }
  }
}
