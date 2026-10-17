import 'dart:ui' show SemanticsAction;

import 'package:flex_switch/flex_switch.dart';
import 'package:flex_switch_example/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

Finder _control(String key) => find.byKey(ValueKey(key));

// A hovered tooltip uses rich Text with the same label as its segment.
Finder _label(String key, String label) => find.descendant(
  of: _control(key),
  matching: find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == label,
  ),
);

FlexSwitch<T> _switch<T>(WidgetTester tester, String key) =>
    tester.widget<FlexSwitch<T>>(_control(key));

Future<void> _show(WidgetTester tester, Finder finder) async {
  // The showcase uses a lazy ListView. Start from the top so either an already
  // mounted item or one farther down is reached through the same scroll flow.
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(finder, 250, scrollable: scrollable);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

Future<void> _toggle(WidgetTester tester, String key) async {
  final control = _control(key);
  await _show(tester, control);
  await tester.tap(control);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _tap(WidgetTester tester, String key, String label) async {
  await _show(tester, _control(key));
  await tester.tap(_label(key, label));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<TestGesture> _drag(
  WidgetTester tester,
  String key,
  String from,
  String to,
) async {
  await _show(tester, _control(key));
  final start = tester.getCenter(_label(key, from));
  final target = tester.getCenter(_label(key, to));
  final gesture = await tester.startGesture(
    start,
    kind: PointerDeviceKind.mouse,
  );
  // Two moves cross the recognizer's drag slop and then reach the destination.
  await gesture.moveTo(Offset((start.dx + target.dx) / 2, start.dy));
  await tester.pump();
  await gesture.moveTo(target);
  await tester.pumpAndSettle();
  return gesture;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showcase factories, keyboard, RTL, disabled, drag and styles', (
    tester,
  ) async {
    await tester.pumpWidget(const FlexSwitchDemoApp());
    await tester.pumpAndSettle();
    expect(find.text('FlexSwitch Demo'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Factory selections update the controlled app and, for ThemeMode, its
    // actual Material theme. Rapid repeated taps preserve the selected value.
    await _tap(tester, 'boolean-switch', 'On');
    expect(_switch<bool>(tester, 'boolean-switch').selectedValue, isTrue);
    await tester.tap(_label('boolean-switch', 'Off'));
    await tester.pump();
    await tester.tap(_label('boolean-switch', 'On'));
    await tester.pumpAndSettle();
    expect(_switch<bool>(tester, 'boolean-switch').selectedValue, isTrue);
    await _tap(tester, 'theme-switch', 'Dark');
    expect(
      _switch<ThemeMode>(tester, 'theme-switch').selectedValue,
      ThemeMode.dark,
    );
    expect(
      Theme.of(tester.element(_control('theme-switch'))).brightness,
      Brightness.dark,
    );
    await _tap(tester, 'theme-switch', 'Light');
    expect(
      Theme.of(tester.element(_control('theme-switch'))).brightness,
      Brightness.light,
    );
    await _tap(tester, 'inbox-switch', 'Mentions and replies');
    expect(_switch<int>(tester, 'inbox-switch').selectedValue, 1);
    final labels = ['All', 'Mentions and replies', 'DMs'];
    final segments = labels.map((label) {
      return find
          .ancestor(
            of: _label('inbox-switch', label),
            matching: find.byWidgetPredicate((widget) => widget is InkResponse),
          )
          .first;
    }).toList();
    expect(
      tester.getSize(segments[1]).width,
      greaterThan(tester.getSize(segments[0]).width),
    );
    await _tap(tester, 'steps-switch', 'One');
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 1);
    await _key(tester, LogicalKeyboardKey.end);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 0);
    await _key(tester, LogicalKeyboardKey.space);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 1);
    await _key(tester, LogicalKeyboardKey.home);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 0);

    await _toggle(tester, 'rtl-control');
    await _tap(tester, 'steps-switch', 'One');
    expect(
      tester.getCenter(_label('steps-switch', 'One')).dx,
      greaterThan(tester.getCenter(_label('steps-switch', 'Four')).dx),
    );
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 1);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 0);
    await _toggle(tester, 'rtl-control');

    // An individually disabled segment rejects taps and is skipped by keys
    // and the assistive-technology increase action.
    await _toggle(tester, 'disable-middle-control');
    await _tap(tester, 'steps-switch', 'Two');
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 0);
    await _tap(tester, 'steps-switch', 'One');
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 2);
    await _key(tester, LogicalKeyboardKey.home);
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpAndSettle();
      final parent = find
          .descendant(
            of: _control('steps-switch'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.onIncrease != null,
            ),
          )
          .first;
      final node = tester.getSemantics(parent);
      expect(node.getSemanticsData().value, 'One');
      tester
          .renderObject(parent)
          .owner!
          .semanticsOwner!
          .performAction(node.id, SemanticsAction.increase);
      await tester.pumpAndSettle();
      expect(_switch<int>(tester, 'steps-switch').selectedValue, 2);
      expect(tester.getSemantics(parent).getSemanticsData().value, 'Three');
    } finally {
      semantics.dispose();
    }

    await _toggle(tester, 'disabled-control');
    await _tap(tester, 'steps-switch', 'Four');
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 2);
    await _key(tester, LogicalKeyboardKey.home);
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 2);
    await _toggle(tester, 'disabled-control');
    await _toggle(tester, 'disable-middle-control');

    // Immediate drag commits before pointer-up; release-only drag previews
    // without changing app state, commits on up, and discards on cancellation.
    await _tap(tester, 'steps-switch', 'One');
    var gesture = await _drag(tester, 'steps-switch', 'One', 'Four');
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);
    await gesture.up();
    await tester.pumpAndSettle();
    await _toggle(tester, 'release-control');
    await _tap(tester, 'steps-switch', 'One');
    gesture = await _drag(tester, 'steps-switch', 'One', 'Four');
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);
    gesture = await _drag(tester, 'steps-switch', 'Four', 'One');
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);

    await _toggle(tester, 'thumb-only-control');
    gesture = await _drag(tester, 'steps-switch', 'One', 'Three');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);
    gesture = await _drag(tester, 'steps-switch', 'Four', 'One');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 0);

    // Style knobs must remain live and preserve selection through rebuilds.
    await _toggle(tester, 'ripple-control');
    await _toggle(tester, 'ripple-tint-control');
    await _toggle(tester, 'dividers-control');
    await _toggle(tester, 'proportional-control');
    await _show(tester, _control('steps-switch'));
    final styled = _switch<int>(tester, 'steps-switch');
    expect(styled.selectedValue, 0);
    expect(styled.layout, FlexSwitchLayout.proportional);
    expect(styled.style!.enableRipple, isTrue);
    expect(styled.style!.showDividers, isFalse);
    expect(
      styled.style!.segmentOverlayColor!.resolve({WidgetState.pressed}),
      isNot(Colors.transparent),
    );
    await _tap(tester, 'steps-switch', 'Four');
    expect(_switch<int>(tester, 'steps-switch').selectedValue, 3);
    expect(tester.takeException(), isNull);
  });
}
