import 'package:flutter/widgets.dart';

export 'value_layout_builder/sliver_value_layout_builder.dart';
export 'value_layout_builder/value_layout_builder.dart';

/// Signature used by [SliverStickyCollapsablePanel.builder] to build the header
/// when the sticky header status has changed.
typedef HeaderBuilder = Widget Function(
  BuildContext context,
  SliverStickyCollapsablePanelStatus status,
);

/// Controller to manage Sticker Header
/// For example: offset of header
class StickyCollapsablePanelController with ChangeNotifier {
  StickyCollapsablePanelController({this.key = 'default'});

  final String key;

  /// The offset to use in order to jump to the first item
  /// of current the sticky header.
  ///
  /// If there is no sticky headers, this is 0.
  double _stickyCollapsablePanelScrollOffset = 0;

  double get stickyCollapsablePanelScrollOffset =>
      _stickyCollapsablePanelScrollOffset;

  /// This setter should only be used by flutter_RenderBox package.
  set stickyCollapsablePanelScrollOffset(double value) {
    if (_stickyCollapsablePanelScrollOffset != value) {
      _stickyCollapsablePanelScrollOffset = value;
      notifyListeners();
    }
  }
}

/// The [StickyCollapsablePanelController] for descendant widgets that don't specify one
/// explicitly.
///
/// [DefaultStickyCollapsablePanelController] is an inherited widget that is used to share a
/// [StickyCollapsablePanelController] with [SliverStickyCollapsablePanel]s. It's used when sharing an
/// explicitly created [StickyCollapsablePanelController] isn't convenient because the sticky
/// headers are created by a stateless parent widget or by different parent
/// widgets.
class DefaultStickyCollapsablePanelController extends StatefulWidget {
  const DefaultStickyCollapsablePanelController({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Scaffold] whose [AppBar] includes a [TabBar].
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The closest instance of this class that encloses the given context.
  ///
  /// Typical usage:
  ///
  /// ```dart
  /// StickyCollapsablePanelController controller = DefaultStickyCollapsablePanelController.of(context);
  /// ```
  static StickyCollapsablePanelController? of(BuildContext context) {
    final _StickyCollapsablePanelControllerScope? scope =
        context.dependOnInheritedWidgetOfExactType<
            _StickyCollapsablePanelControllerScope>();
    return scope?.controller;
  }

  @override
  DefaultStickyCollapsablePanelControllerState createState() =>
      DefaultStickyCollapsablePanelControllerState();
}

class DefaultStickyCollapsablePanelControllerState
    extends State<DefaultStickyCollapsablePanelController> {
  StickyCollapsablePanelController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = StickyCollapsablePanelController();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StickyCollapsablePanelControllerScope(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _StickyCollapsablePanelControllerScope extends InheritedWidget {
  const _StickyCollapsablePanelControllerScope({
    Key? key,
    this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final StickyCollapsablePanelController? controller;

  @override
  bool updateShouldNotify(_StickyCollapsablePanelControllerScope old) {
    return controller != old.controller;
  }
}

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
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! SliverStickyCollapsablePanelStatus) return false;
    return scrollPercentage == other.scrollPercentage &&
        isPinned == other.isPinned &&
        isExpanded == other.isExpanded;
  }

  @override
  int get hashCode {
    return Object.hash(scrollPercentage, isPinned, isExpanded);
  }
}
