// File: test/flex_switch_test.dart
//
// Run with: flutter test
//
// Make sure the import below points to where the code under test lives.

import 'dart:ui' as ui show SemanticsAction;

import 'package:flex_switch/flex_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Mode { day, night, system }

/// Simple host that keeps [selected] in sync with onChanged so the widget
/// reflects state changes during interactions (drag, tap, etc).
class _Host<T> extends StatefulWidget {
  const _Host({
    required this.options,
    required this.initial,
    required this.onChanged,
    this.style = const FlexSwitchStyle(),
    this.height,
    this.disabled = false,
    this.hapticFeedback = false, // disabled in tests
    this.layout = FlexSwitchLayout.equal,
    this.allowDrag = true,
    this.dragCommitBehavior,
    this.thumbDragOnly = false,
    this.textDirection = TextDirection.ltr,
    this.semanticsLabel,
    this.semanticValueBuilder,
    this.width = 300,
    this.controller,
    super.key,
  });

  final List<SwitchOption<T>> options;
  final T initial;
  final ValueChanged<T> onChanged;
  final FlexSwitchStyle style;
  final double? height;
  final bool disabled;
  final bool hapticFeedback;
  final FlexSwitchLayout layout;
  final bool allowDrag;
  final DragCommitBehavior? dragCommitBehavior;
  final bool thumbDragOnly;
  final TextDirection textDirection;
  final String? semanticsLabel;
  final String Function(T value)? semanticValueBuilder;
  final double width;
  final FlexSwitchController? controller;

  @override
  State<_Host<T>> createState() => _HostState<T>();
}

class _HostState<T> extends State<_Host<T>> {
  late T _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Directionality(
        textDirection: widget.textDirection,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: widget.width,
              child: FlexSwitch<T>(
                options: widget.options,
                selectedValue: _selected,
                onChanged: (v) {
                  setState(() => _selected = v);
                  widget.onChanged(v);
                },
                style: widget.style,
                height: widget.height,
                disabled: widget.disabled,
                hapticFeedback: widget.hapticFeedback,
                layout: widget.layout,
                allowDrag: widget.allowDrag,
                dragCommitBehavior: widget.dragCommitBehavior,
                thumbDragOnly: widget.thumbDragOnly,
                semanticsLabel: widget.semanticsLabel,
                semanticValueBuilder: widget.semanticValueBuilder,
                controller: widget.controller,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SwitchOption equality', () {
    test('Equality is based only on value', () {
      const a1 = SwitchOption<int>(value: 1, label: 'One');
      const a2 = SwitchOption<int>(
        value: 1,
        label: 'Different',
        enabled: false,
      );
      const b = SwitchOption<int>(value: 2, label: 'Two');

      expect(a1, equals(a2));
      expect(a1 == b, isFalse);

      // Equatable + Set uniqueness by value
      final set = {a1, a2, b};
      expect(set.length, 2);
    });
  });

  group('Constructors', () {
    testWidgets('FlexSwitch.boolean toggles on tap', (tester) async {
      bool? changed;
      bool value = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData(useMaterial3: true),
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 300,
                    child: FlexSwitch.boolean(
                      value: value,
                      onChanged: (v) {
                        setState(() => value = v);
                        changed = v;
                      },
                      trueLabel: 'On',
                      falseLabel: 'Off',
                      hapticFeedback: false,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Off'), findsOneWidget);
      expect(find.text('On'), findsOneWidget);

      await tester.tap(find.text('On'));
      await tester.pumpAndSettle();
      expect(changed, isTrue);
    });

    testWidgets('FlexSwitch.fromEnum builds labels and taps change selection', (
      tester,
    ) async {
      _Mode? changed;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: FlexSwitch.fromEnum<_Mode>(
                  selectedValue: _Mode.day,
                  onChanged: (v) => changed = v,
                  values: const [_Mode.day, _Mode.night, _Mode.system],
                  labelBuilder: (m) => switch (m) {
                    _Mode.day => 'Day',
                    _Mode.night => 'Night',
                    _Mode.system => 'Auto',
                  },
                  hapticFeedback: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Night'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);

      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();
      expect(changed, _Mode.night);
    });

    testWidgets('FlexSwitch.fromValues maps arbitrary values', (tester) async {
      String? changed;
      final values = ['A', 'BB', 'CCC'];
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: FlexSwitch.fromValues<String>(
                  values: values,
                  selectedValue: 'A',
                  onChanged: (v) => changed = v,
                  label: (v) => v,
                  hapticFeedback: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BB'), findsOneWidget);
      await tester.tap(find.text('CCC'));
      await tester.pumpAndSettle();
      expect(changed, 'CCC');
    });
  });

  group('Tap & disabled behavior', () {
    testWidgets('Tap changes selection when enabled', (tester) async {
      int? changed;
      final options = [
        const SwitchOption<int>(value: 0, label: 'Zero'),
        const SwitchOption<int>(value: 1, label: 'One'),
        const SwitchOption<int>(value: 2, label: 'Two'),
      ];
      await tester.pumpWidget(
        _Host<int>(options: options, initial: 0, onChanged: (v) => changed = v),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(changed, 2);
    });

    testWidgets('Whole control disabled prevents changes and dims', (
      tester,
    ) async {
      int callCount = 0;
      final options = [
        const SwitchOption<int>(value: 0, label: 'Zero'),
        const SwitchOption<int>(value: 1, label: 'One'),
      ];
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 0,
          disabled: true,
          onChanged: (_) => callCount++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(callCount, 0);

      // Look for the top-level Opacity 0.6 applied when disabled.
      final dimmedOpacityFinder = find.byWidgetPredicate(
        (w) => w is Opacity && (w.opacity - 0.6).abs() < 0.001,
      );
      expect(dimmedOpacityFinder, findsOneWidget);
    });

    testWidgets(
      'Disabled option cannot be tapped; drag selects nearest enabled',
      (tester) async {
        final changes = <int>[];
        final options = [
          const SwitchOption<int>(value: 0, label: 'Zero'),
          const SwitchOption<int>(value: 1, label: 'One', enabled: false),
          const SwitchOption<int>(value: 2, label: 'Two'),
        ];
        await tester.pumpWidget(
          _Host<int>(options: options, initial: 0, onChanged: changes.add),
        );
        await tester.pumpAndSettle();

        // Tap the disabled middle option; no change expected.
        await tester.tap(find.text('One'));
        await tester.pumpAndSettle();
        expect(changes, isEmpty);

        // Drag over the disabled segment; nearest enabled is index 2 ("Two").
        final centerOfDisabled = tester.getCenter(find.text('One'));

        final gesture = await tester.startGesture(centerOfDisabled);
        await tester.pump(const Duration(milliseconds: 30));
        await gesture.moveBy(const Offset(40, 0)); // slight horizontal drag
        await tester.pump(const Duration(milliseconds: 30));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(changes.isNotEmpty, isTrue);
        expect(changes.last, 2);
      },
    );
  });

  group('Drag interactions', () {
    testWidgets('Immediate commit: selection updates while dragging', (
      tester,
    ) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'A'),
        const SwitchOption<int>(value: 1, label: 'B'),
        const SwitchOption<int>(value: 2, label: 'C'),
      ];
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 0,
          onChanged: changes.add,
          layout: FlexSwitchLayout.equal,
          dragCommitBehavior: DragCommitBehavior.immediate,
        ),
      );
      await tester.pumpAndSettle();

      final boxFinder = find.byType(FlexSwitch<int>);
      final topLeft = tester.getTopLeft(boxFinder);
      final size = tester.getSize(boxFinder);

      // Drag from left third to rightmost edge.
      final start = topLeft + Offset(size.width * 0.15, size.height * 0.5);
      final end = topLeft + Offset(size.width * 0.95, size.height * 0.5);

      final g = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 16));
      await g.moveTo(end);
      await tester.pump(const Duration(milliseconds: 16));
      await g.up();
      await tester.pumpAndSettle();

      expect(changes, isNotEmpty);
      expect(changes.last, 2);
    });

    testWidgets('Commit on release: no change until finger lifts', (
      tester,
    ) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'A'),
        const SwitchOption<int>(value: 1, label: 'B'),
        const SwitchOption<int>(value: 2, label: 'C'),
      ];
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 0,
          onChanged: changes.add,
          dragCommitBehavior: DragCommitBehavior.onRelease,
        ),
      );
      await tester.pumpAndSettle();

      final box = find.byType(FlexSwitch<int>);
      final tl = tester.getTopLeft(box);
      final size = tester.getSize(box);

      final start = tl + Offset(size.width * 0.10, size.height * 0.5);
      final mid = tl + Offset(size.width * 0.75, size.height * 0.5);

      final g = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 10));
      await g.moveTo(mid);
      await tester.pump(const Duration(milliseconds: 10));

      // Still no changes while dragging.
      expect(changes, isEmpty);

      await g.up();
      await tester.pumpAndSettle();

      expect(changes, equals([2]));
    });

    testWidgets('thumbDragOnly: drags must start on selected segment', (
      tester,
    ) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'Left'),
        const SwitchOption<int>(value: 1, label: 'Right'),
      ];
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 0, // left selected
          onChanged: changes.add,
          thumbDragOnly: true, // implies onRelease by default
        ),
      );
      await tester.pumpAndSettle();

      final box = find.byType(FlexSwitch<int>);
      final tl = tester.getTopLeft(box);
      final size = tester.getSize(box);

      // Start NOT on the selected (start on right half) -> ignored.
      final startWrong = tl + Offset(size.width * 0.75, size.height * 0.5);
      var g = await tester.startGesture(startWrong);
      await tester.pump(const Duration(milliseconds: 10));
      await g.moveBy(const Offset(-50, 0));
      await g.up();
      await tester.pumpAndSettle();
      expect(changes, isEmpty);

      // Start ON the selected (left half) -> accepted and committed on release.
      final startCorrect = tl + Offset(size.width * 0.25, size.height * 0.5);
      g = await tester.startGesture(startCorrect);
      await tester.pump(const Duration(milliseconds: 10));
      await g.moveTo(tl + Offset(size.width * 0.85, size.height * 0.5));
      await g.up();
      await tester.pumpAndSettle();

      expect(changes, equals([1]));
    });

    testWidgets('allowDrag=false ignores drags but taps still work', (
      tester,
    ) async {
      int? changed;
      final options = [
        const SwitchOption<int>(value: 0, label: 'A'),
        const SwitchOption<int>(value: 1, label: 'B'),
      ];
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 0,
          onChanged: (v) => changed = v,
          allowDrag: false,
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(FlexSwitch<int>);
      final topLeft = tester.getTopLeft(switchFinder);
      final size = tester.getSize(switchFinder);

      final start = topLeft + Offset(size.width * 0.2, size.height * 0.5);
      final gesture = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveBy(Offset(size.width * 0.6, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(changed, isNull, reason: 'drags should be ignored');

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(changed, 1, reason: 'taps remain functional');
    });

    testWidgets('Commit-on-release cancels when pointer leaves vertical slop', (
      tester,
    ) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'A'),
        const SwitchOption<int>(value: 1, label: 'B'),
        const SwitchOption<int>(value: 2, label: 'C'),
      ];

      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 0,
          onChanged: changes.add,
          dragCommitBehavior: DragCommitBehavior.onRelease,
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(FlexSwitch<int>);
      final topLeft = tester.getTopLeft(switchFinder);
      final size = tester.getSize(switchFinder);

      final start = topLeft + Offset(size.width * 0.1, size.height * 0.5);
      final towardsRight =
          topLeft + Offset(size.width * 0.85, size.height * 0.5);

      final gesture = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveTo(towardsRight);
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        changes,
        isEmpty,
        reason: 'drag should cancel when exiting vertically',
      );
    });
  });

  group('Dividers', () {
    testWidgets('Dividers render and fade adjacent to selected thumb', (
      tester,
    ) async {
      final options = [
        const SwitchOption<int>(value: 0, label: 'A'),
        const SwitchOption<int>(value: 1, label: 'B'),
        const SwitchOption<int>(value: 2, label: 'C'),
      ];
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 1, // middle selected
          onChanged: (_) {},
          style: const FlexSwitchStyle(
            showDividers: true,
            hideDividersAdjacentToThumb: true,
            dividerThickness: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // For 3 segments, there are 2 dividers: keys divider_0 and divider_1.
      final d0 = find.byKey(const ValueKey('divider_0'));
      final d1 = find.byKey(const ValueKey('divider_1'));

      expect(d0, findsOneWidget);
      expect(d1, findsOneWidget);

      // Both dividers touch the middle segment; opacity should be 0.0.
      final op0 = tester.widget<AnimatedOpacity>(d0).opacity;
      final op1 = tester.widget<AnimatedOpacity>(d1).opacity;
      expect(op0, 0.0);
      expect(op1, 0.0);

      // If we rebuild with hideDividersAdjacentToThumb = false, both visible.
      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 1,
          onChanged: (_) {},
          style: const FlexSwitchStyle(
            showDividers: true,
            hideDividersAdjacentToThumb: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<AnimatedOpacity>(d0).opacity, 1.0);
      expect(tester.widget<AnimatedOpacity>(d1).opacity, 1.0);
    });
  });

  group('Semantics', () {
    testWidgets('Semantics label and value provided', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final options = [
          const SwitchOption<int>(value: 0, label: 'Off'),
          const SwitchOption<int>(value: 1, label: 'On'),
        ];

        await tester.pumpWidget(
          _Host<int>(
            options: options,
            initial: 1,
            onChanged: (_) {},
            semanticsLabel: 'Power',
            semanticValueBuilder: (v) => v == 1 ? 'Enabled' : 'Disabled',
          ),
        );
        await tester.pumpAndSettle();

        final node = tester.getSemantics(find.bySemanticsLabel('Power'));
        final data = node.getSemanticsData();
        expect(data.value, 'Enabled');
      } finally {
        handle.dispose();
      }
    });

    testWidgets('Semantics increase/decrease move selection', (tester) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'Off'),
        const SwitchOption<int>(value: 1, label: 'On'),
      ];

      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _Host<int>(
            options: options,
            initial: 0,
            onChanged: changes.add,
            semanticsLabel: 'Power',
          ),
        );
        await tester.pumpAndSettle();

        final node = tester.getSemantics(find.bySemanticsLabel('Power'));
        final SemanticsOwner owner = node.owner!;

        owner.performAction(node.id, ui.SemanticsAction.increase);
        await tester.pumpAndSettle();
        expect(changes.last, 1);

        owner.performAction(node.id, ui.SemanticsAction.decrease);
        await tester.pumpAndSettle();
        expect(changes.last, 0);
      } finally {
        handle.dispose();
      }
    });
  });

  group('Keyboard navigation', () {
    Future<void> focusFlexSwitch(WidgetTester tester) async {
      final focusFinder = find
          .descendant(
            of: find.byType(FlexSwitch<int>),
            matching: find.byType(FocusableActionDetector),
          )
          .first;
      final detector = tester.widget<FocusableActionDetector>(focusFinder);
      detector.focusNode!.requestFocus();
      await tester.pump();
    }

    testWidgets('LTR: arrow, home/end, and activation keys update selection', (
      tester,
    ) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'One'),
        const SwitchOption<int>(value: 1, label: 'Two'),
        const SwitchOption<int>(value: 2, label: 'Three'),
      ];

      await tester.pumpWidget(
        _Host<int>(options: options, initial: 1, onChanged: changes.add),
      );
      await tester.pumpAndSettle();

      await focusFlexSwitch(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(changes.last, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(changes.last, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(changes.last, 0);

      final beforeClamp = changes.length;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(
        changes.length,
        beforeClamp,
        reason: 'clamped at first index in LTR',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(changes.last, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(changes.last, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(
        changes.last,
        1,
        reason: 'Space triggers ActivateIntent cycling to next',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(
        changes.last,
        2,
        reason: 'Enter triggers ActivateIntent and cycles again',
      );
    });

    testWidgets('RTL: arrow keys reverse direction', (tester) async {
      final changes = <int>[];
      final options = [
        const SwitchOption<int>(value: 0, label: 'One'),
        const SwitchOption<int>(value: 1, label: 'Two'),
        const SwitchOption<int>(value: 2, label: 'Three'),
      ];

      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 1,
          onChanged: changes.add,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      await focusFlexSwitch(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(
        changes.last,
        2,
        reason: 'In RTL, ArrowLeft moves to higher logical index',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(
        changes.last,
        1,
        reason: 'ArrowRight should move back toward lower index in RTL',
      );
    });
  });

  group('Layout & hit-testing', () {
    testWidgets('controller drives fractional visual position', (tester) async {
      final controller = FlexSwitchController(initialPosition: 0);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _Host<int>(
          options: const [
            SwitchOption<int>(value: 0, label: 'A'),
            SwitchOption<int>(value: 1, label: 'B'),
            SwitchOption<int>(value: 2, label: 'C'),
          ],
          initial: 0,
          controller: controller,
          onChanged: (_) {},
          style: const FlexSwitchStyle(duration: Duration.zero),
        ),
      );

      double thumbLeft() => tester
          .widget<AnimatedPositioned>(find.byType(AnimatedPositioned).first)
          .left!;

      final start = thumbLeft();
      controller.position = 1;
      await tester.pump();
      final end = thumbLeft();
      controller.position = 0.5;
      await tester.pump();

      expect(thumbLeft(), closeTo((start + end) / 2, 0.001));
    });

    testWidgets('controller synchronizes directly with an animation', (
      tester,
    ) async {
      final animation = AnimationController(
        vsync: tester,
        upperBound: 2,
      );
      final controller = FlexSwitchController()..syncWith(animation);
      addTearDown(animation.dispose);
      addTearDown(controller.dispose);

      animation.value = 0.75;

      expect(controller.position, 0.75);
    });

    testWidgets(
      'Proportional layout: long second segment gets most width (hit @25% selects #2)',
      (tester) async {
        // Make the second label dramatically longer than the first.
        final options = [
          const SwitchOption<int>(value: 0, label: 'A'),
          const SwitchOption<int>(
            value: 1,
            label: 'This is a very very very long label',
          ),
        ];

        int? changed;
        await tester.pumpWidget(
          _Host<int>(
            options: options,
            initial: 0,
            layout: FlexSwitchLayout.proportional,
            onChanged: (v) => changed = v,
            width: 300, // default in widget is ~300; we make it explicit
          ),
        );
        await tester.pumpAndSettle();

        // With proportional layout, the first segment should be quite small.
        // A tap/drag around 25% of the width should land in the (wider) second segment.
        final switchFinder = find.byType(FlexSwitch<int>);
        final topLeft = tester.getTopLeft(switchFinder);
        final size = tester.getSize(switchFinder);

        final point = topLeft + Offset(size.width * 0.25, size.height * 0.5);
        await tester.tapAt(point);
        await tester.pumpAndSettle();

        expect(changed, 1);
      },
    );

    testWidgets('RTL: leftmost physical area maps to last logical index', (
      tester,
    ) async {
      final options = [
        const SwitchOption<int>(value: 0, label: 'First'),
        const SwitchOption<int>(value: 1, label: 'Second'),
        const SwitchOption<int>(value: 2, label: 'Third'), // last logical
      ];
      int? changed;

      await tester.pumpWidget(
        _Host<int>(
          options: options,
          initial: 1,
          onChanged: (v) => changed = v,
          textDirection: TextDirection.rtl,
          dragCommitBehavior: DragCommitBehavior.immediate,
        ),
      );
      await tester.pumpAndSettle();

      final box = find.byType(FlexSwitch<int>);
      final tl = tester.getTopLeft(box);
      final size = tester.getSize(box);

      // Drag starting near the far-left (physical) should target the *last* logical index in RTL.
      final start = tl + Offset(size.width * 0.05, size.height * 0.5);
      final g = await tester.startGesture(start);
      await g.moveBy(const Offset(1, 0));
      await g.up();
      await tester.pumpAndSettle();

      expect(changed, 2);
    });

    testWidgets('Default height respects kMinInteractiveDimension', (
      tester,
    ) async {
      await tester.pumpWidget(
        _Host<int>(
          options: const [
            SwitchOption<int>(value: 0, label: 'Left'),
            SwitchOption<int>(value: 1, label: 'Right'),
          ],
          initial: 0,
          onChanged: (_) {},
          height: null,
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(FlexSwitch<int>));
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    });
  });
}
