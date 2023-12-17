## 1.1.5

* [chore] - more strict non-null/required/final type constraint
* [chore] - project structure adjustment for better readability
* [fix] - remove careless import of cupertino package

## 1.1.4

* [chore] - update gif source in readme for easier access

## 1.1.3

* [feature] - update ValueLayoutBuilder according to framework's LayoutBuilder

## 1.1.2

* [chore] - fix pub score issue
* [chore] - update readme for simple arrow hint for header

## 1.1.1

* [chore] - more strict field access for render layer

## 1.1.0

* [feature] - support add padding for sliver child (with `paddingBeforeCollapse` parameter)
* [feature] - support add padding after the header even the panel collapsed (with `paddingAfterCollapse` parameter)
* [break change] - upgrade min flutter 3.3.0 since padding works wrong with lower flutter, we don't use version 2.0.0
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
