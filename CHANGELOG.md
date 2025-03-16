## 2.1.0
* [feature] - added `toggleExpanded` in the Sticker Header component
* [feature] - added `isExpanded`,`isPinned`,`isDisabled` in the Sticker Header component to set and get these properties

## 2.0.7
* [chore] - regenerate example with Flutter 3.24 for Android Studio Ladybug compatible

## 2.0.6
* [chore] - update readme for demo of `headerSize` configuration

## 2.0.5
* [performance] add optional parameter `headerSize` to speed up the layout process

## 2.0.4
* [fix] - more accurate configuration for layoutExtent of sliver geometry

## 2.0.3
* [chore] - non-null type constraints child for render layer
* [chore] - performance optimization for too frequently access constraints property

## 2.0.2
* [chore] - regenerate example with flutter 3.13
* [chore] - verify compatibility with flutter 3.19
* [chore] - simplify source code with latest switch syntax in dart 3

## 2.0.1
* [chore] - use geometry.copyWith to simplify source code

## 2.0.0
* [framework consistency] - use framework's SlottedMultiChildRenderObjectWidget to maintain tree structure, this will benefit us from leverage framework upgrade
* [break change] - bump min flutter 3.13, min dart 3.1 which is required by SlottedMultiChildRenderObjectWidget
* [chore] - remove deprecated named constructor: SliverStickyCollapsablePanel.builder

## 1.1.15
* [chore] - update topics for hint iOS style sticky

## 1.1.14
* [chore] - enable/test impeller for iOS example, it works even better on render precise, this will optimize default sticky effects between headers
* [suggest] - since impeller for iOS stable from flutter 3.10, we suggest you upgrade and use it
* [suggest] - since impeller for android not stable with latest flutter 3.16, we suggest wait for the stable version

## 1.1.13
* [chore] - enable/test Impeller preview for android example , it works even better on render precise

## 1.1.12
* [framework consistency] - according to scroll physics, use more reasonable tolerance for calibration

## 1.1.11
* [chore] - update README for better readability

## 1.1.10
* [api deprecation] - deprecated named constructor: SliverStickyCollapsablePanel.builder 
* [chore] - provide simper SliverStickyCollapsablePanel constructor as replacement
* [chore] - rename some parameter for better readability

## 1.1.9
* [chore] - more strict assert for non-null child for render layer

## 1.1.8

* [framework consistency] - totally rewrite of render layer according to flutter frameworks component
* [fix] - more accurate hitTest for click on header

## 1.1.7

* [chore] - update render layer according to framework's RenderSliverPadding

## 1.1.6

* [chore] - update render layer according to framework's RenderSliverPadding

## 1.1.5

* [chore] - more strict non-null/required/final type constraint
* [chore] - project structure adjustment for better readability
* [fix] - remove careless import of cupertino package

## 1.1.4

* [chore] - update gif source in readme for easier access

## 1.1.3

* [framework consistency] - update ValueLayoutBuilder according to framework's LayoutBuilder

## 1.1.2

* [chore] - fix pub score issue
* [chore] - update readme for simple arrow hint for header

## 1.1.1

* [chore] - more strict field access for render layer

## 1.1.0

* [feature] - support add padding for sliver child (with `paddingBeforeCollapse` parameter)
* [feature] - support add padding after the header even the panel collapsed (with `paddingAfterCollapse` parameter)
* [break change] - upgrade min flutter 3.3.0 since padding works wrong with lower flutter, we don't use version 2.0.1
  since api is compatible and its not convenient for users who are using newer flutter, users who use older flutter just
  lock your version in yaml
* [chore] - update readme for more gif effects and better readability
* [fix] - when disableCollapsable is true, always make sure panel is expanded

## 1.0.8

* [fix] - remove careless use of new api in flutter 3.13 since flutter source code has no hint for new api
* [chore] - run example with flutter 2.15 to flutter 3.16 to make sure compatibility

## 1.0.7

* [fix] - when expand pined header, calibration position more accurately

## 1.0.6

* [feature] - add iOS style sticky header, just like what ios contact app use

## 1.0.5

* [chore] - adjust parameter order to highlight required parameters

## 1.0.4

* [chore] - regenerate example with latest stable flutter chanel

## 1.0.3

* [chore] - update README for simplest demo

## 1.0.2

* [chore] - fix spelling errors
* [chore] - code clean

## 1.0.1

* [chore] - use default dart format configuration

## 1.0.0

* [feature] - implementation of sliver_sticky_collapsable_panel
* [feature] - relying solely on the Flutter framework itself
* [feature] - null-safety ready
* [feature] - dart 3 ready
