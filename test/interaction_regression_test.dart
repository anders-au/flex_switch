import 'dart:ui' as ui;

import 'package:flex_switch/flex_switch.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _options = [
  SwitchOption(value: 0, label: 'Zero'),
  SwitchOption(value: 1, label: 'One', enabled: false),
  SwitchOption(value: 2, label: 'Two'),
  SwitchOption(value: 3, label: 'Three', enabled: false),
];

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(child: SizedBox(width: 320, child: child)),
        ),
      ),
    );

Future<void> _focus(WidgetTester tester) async {
  final detector = tester.widget<FocusableActionDetector>(
    find
        .descendant(
          of: find.byType(FlexSwitch<int>),
          matching: find.byType(FocusableActionDetector),
        )
        .first,
  );
  detector.focusNode!.requestFocus();
  await tester.pump();
}

Future<({int width, List<int> rgba})> _renderedPixels(
  WidgetTester tester,
  GlobalKey key,
) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return (width: image.width, rgba: data!.buffer.asUint8List().toList());
    } finally {
      image.dispose();
    }
  }))!;
}

List<int> _pixel(({int width, List<int> rgba}) image, int x, int y) {
  final offset = (y * image.width + x) * 4;
  return image.rgba.sublist(offset, offset + 4);
}

void main() {
  testWidgets(
    'keyboard skips disabled options for arrows, endpoints and cycling',
    (tester) async {
      var selected = 0;
      final changes = <int>[];
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _app(
              FlexSwitch<int>(
                options: _options,
                selectedValue: selected,
                hapticFeedback: false,
                onChanged: (value) {
                  changes.add(value);
                  setState(() => selected = value);
                },
              ),
            );
          },
        ),
      );
      await _focus(tester);
      for (final key in [
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.end,
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.home,
      ]) {
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
      }
      expect(changes, [2, 0, 2, 0]);
    },
  );

  testWidgets('semantic next follows logical order in RTL and skips disabled', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      var selected = 0;
      final changes = <int>[];
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _app(
              FlexSwitch<int>(
                options: _options,
                selectedValue: selected,
                hapticFeedback: false,
                semanticsLabel: 'Mode',
                onChanged: (value) {
                  changes.add(value);
                  setState(() => selected = value);
                },
              ),
              direction: TextDirection.rtl,
            );
          },
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Mode'));
      expect(node.getSemanticsData().increasedValue, 'Two');
      expect(
        node.getSemanticsData().hasAction(ui.SemanticsAction.decrease),
        isFalse,
      );
      node.owner!.performAction(node.id, ui.SemanticsAction.increase);
      await tester.pumpAndSettle();
      expect(changes, [2]);
      final updated = tester.getSemantics(find.bySemanticsLabel('Mode'));
      expect(
        updated.getSemanticsData().hasAction(ui.SemanticsAction.increase),
        isFalse,
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets('cancelled pointer does not commit a drag preview', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(
      _app(
        FlexSwitch<int>(
          options: _options,
          selectedValue: 0,
          hapticFeedback: false,
          dragCommitBehavior: DragCommitBehavior.onRelease,
          onChanged: changes.add,
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Zero')),
    );
    await gesture.moveTo(tester.getCenter(find.text('Two')));
    await tester.pump();
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump();
    expect(changes, isEmpty);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets('options changing during preview cancels the obsolete drag', (
    tester,
  ) async {
    var options = _options;
    late StateSetter rebuild;
    final changes = <int>[];
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return _app(
            FlexSwitch<int>(
              options: options,
              selectedValue: 0,
              hapticFeedback: false,
              dragCommitBehavior: DragCommitBehavior.onRelease,
              onChanged: changes.add,
            ),
          );
        },
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Zero')),
    );
    await gesture.moveTo(tester.getCenter(find.text('Two')));
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump();
    rebuild(
      () => options = const [
        SwitchOption(value: 0, label: 'Zero'),
        SwitchOption(value: 4, label: 'Four'),
      ],
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets('all-disabled options cannot be selected by drag or keyboard', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(
      _app(
        FlexSwitch<int>(
          options: const [
            SwitchOption(value: 0, label: 'Zero', enabled: false),
            SwitchOption(value: 1, label: 'One', enabled: false),
          ],
          selectedValue: 0,
          hapticFeedback: false,
          onChanged: changes.add,
        ),
      ),
    );
    await _focus(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.drag(find.byType(FlexSwitch<int>), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });
  testWidgets('one tab stop belongs to the control, not each segment', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlexSwitch<int>(
              options: _options,
              selectedValue: 0,
              onChanged: (_) {},
              hapticFeedback: false,
            ),
            TextButton(onPressed: () {}, child: const Text('After')),
          ],
        ),
      ),
    );
    await _focus(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      Focus.of(tester.element(find.text('After'))).hasPrimaryFocus,
      isTrue,
    );
  });

  testWidgets(
    'proportional options without visual content share available width',
    (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        _app(
          FlexSwitch<int>(
            options: const [
              SwitchOption(value: 0, semanticsLabel: 'First'),
              SwitchOption(value: 1, semanticsLabel: 'Second'),
            ],
            selectedValue: 0,
            onChanged: changes.add,
            hapticFeedback: false,
            layout: FlexSwitchLayout.proportional,
            style: const FlexSwitchStyle(itemPadding: EdgeInsets.zero),
          ),
        ),
      );
      expect(
        tester
            .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
            .width,
        greaterThan(100),
      );
      final rect = tester.getRect(find.byType(FlexSwitch<int>));
      await tester.tapAt(Offset(rect.left + rect.width * .75, rect.center.dy));
      await tester.pumpAndSettle();
      expect(changes, [1]);
    },
  );

  testWidgets('drag over a zero-width inner track does not throw or select', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(
      _app(
        UnconstrainedBox(
          child: SizedBox(
            width: 10,
            child: FlexSwitch<int>(
              options: _options,
              selectedValue: 0,
              onChanged: changes.add,
              hapticFeedback: false,
            ),
          ),
        ),
      ),
    );
    await tester.drag(find.byType(FlexSwitch<int>), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(changes, isEmpty);
  });

  testWidgets('controlled selection supersedes an active release preview', (
    tester,
  ) async {
    var selected = 0;
    late StateSetter rebuild;
    final changes = <int>[];
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return _app(
            FlexSwitch<int>(
              options: _options,
              selectedValue: selected,
              hapticFeedback: false,
              dragCommitBehavior: DragCommitBehavior.onRelease,
              onChanged: changes.add,
            ),
          );
        },
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Zero')),
    );
    await gesture.moveTo(tester.getCenter(find.text('Two')));
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump();
    rebuild(() => selected = 1);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('resolved option colors retain alpha when enabled and disabled', (
    tester,
  ) async {
    const color = Color.from(alpha: .25, red: .1, green: .4, blue: .7);
    for (final selected in [0, 1]) {
      await tester.pumpWidget(
        _app(
          FlexSwitch<int>(
            options: const [
              SwitchOption(
                value: 0,
                label: 'Enabled',
                icon: Icons.check,
                activeColor: color,
                inactiveColor: color,
              ),
              SwitchOption(
                value: 1,
                label: 'Disabled',
                icon: Icons.close,
                activeColor: color,
                inactiveColor: color,
                enabled: false,
              ),
            ],
            selectedValue: selected,
            onChanged: (_) {},
            hapticFeedback: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final (label, icon, expectedAlpha) in [
        ('Enabled', Icons.check, .25),
        ('Disabled', Icons.close, .1),
      ]) {
        final text = tester.renderObject<RenderParagraph>(find.text(label));
        expect(
          (text.text as TextSpan).style!.color!.a,
          closeTo(expectedAlpha, 1e-9),
          reason: '$label text alpha',
        );
        expect(
          tester.widget<Icon>(find.byIcon(icon)).color!.a,
          closeTo(expectedAlpha, 1e-9),
          reason: '$label icon alpha',
        );
      }
    }
  });

  for (final width in [0.0, 3.0]) {
    testWidgets('focus ring paints only the perimeter with width $width', (
      tester,
    ) async {
      final key = GlobalKey();
      final previousStrategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
                  .copyWith(primary: Colors.blue),
            ),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox(
                    width: 320,
                    child: FlexSwitch<int>(
                      options: const [
                        SwitchOption(value: 0),
                        SwitchOption(value: 1),
                      ],
                      selectedValue: 0,
                      onChanged: (_) {},
                      height: 48,
                      hapticFeedback: false,
                      style: FlexSwitchStyle(
                        backgroundColor: Colors.white,
                        thumbColor: Colors.white,
                        shadow: const [],
                        padding: 0,
                        borderRadius: 0,
                        thumbRadius: 0,
                        focusRingWidth: width,
                        enableTrackHoverOverlay: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final before = await _renderedPixels(tester, key);
        await _focus(tester);
        await tester.pumpAndSettle();
        final after = await _renderedPixels(tester, key);
        expect(
          _pixel(after, 240, 24),
          _pixel(before, 240, 24),
          reason: 'Focus must not tint the track interior',
        );
        expect(
          _pixel(after, 4, 24),
          _pixel(before, 4, 24),
          reason: 'Focus must not tint beyond the specified perimeter width',
        );
        if (width == 0) {
          expect(
            after.rgba,
            before.rgba,
            reason: 'Zero width disables the ring',
          );
        } else {
          expect(
            _pixel(after, 0, 24),
            isNot(_pixel(before, 0, 24)),
            reason: 'Ring stays visible over a zero-padding selected thumb',
          );
          expect(
            _pixel(after, 319, 24),
            isNot(_pixel(before, 319, 24)),
            reason: 'Ring stays visible at the other track edge',
          );
        }
      } finally {
        FocusManager.instance.highlightStrategy = previousStrategy;
      }
    });
  }

  testWidgets('segment semantics use one label and retain tap actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      final changes = <int>[];
      await tester.pumpWidget(
        _app(
          FlexSwitch<int>(
            options: const [
              SwitchOption(value: 0, label: 'Zero', enabled: false),
              SwitchOption(
                value: 1,
                label: 'One',
                semanticsLabel: 'Custom one',
              ),
            ],
            selectedValue: 0,
            semanticsLabel: 'Mode',
            onChanged: changes.add,
            hapticFeedback: false,
          ),
        ),
      );
      final zero = tester.getSemantics(find.bySemanticsLabel(RegExp(r'Zero')));
      expect(zero.getSemanticsData().label, 'Zero');
      expect(
        zero.getSemanticsData().hasAction(ui.SemanticsAction.tap),
        isFalse,
      );
      final one = tester.getSemantics(
        find.bySemanticsLabel(RegExp(r'Custom one')),
      );
      expect(one.getSemanticsData().label, 'Custom one');
      expect(one.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
      one.owner!.performAction(one.id, ui.SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(changes, [1]);
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
    'directional navigation cannot focus or activate segment descendants',
    (tester) async {
      var selected = 0;
      final changes = <int>[];
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _app(
              MediaQuery(
                data: const MediaQueryData(
                  navigationMode: NavigationMode.directional,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlexSwitch<int>(
                      options: _options,
                      selectedValue: selected,
                      onChanged: (value) {
                        changes.add(value);
                        setState(() => selected = value);
                      },
                      hapticFeedback: false,
                    ),
                    TextButton(onPressed: () {}, child: const Text('After')),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await _focus(tester);
      final detector = tester.widget<FocusableActionDetector>(
        find
            .descendant(
              of: find.byType(FlexSwitch<int>),
              matching: find.byType(FocusableActionDetector),
            )
            .first,
      );
      final rootFocus = detector.focusNode!;
      final disabledFocus = Focus.of(tester.element(find.text('One')));
      disabledFocus.requestFocus();
      await tester.pump();
      expect(
        rootFocus.hasPrimaryFocus,
        isTrue,
        reason: 'Disabled segment cannot capture primary focus',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, [2, 0]);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        Focus.of(tester.element(find.text('After'))).hasPrimaryFocus,
        isTrue,
      );
    },
  );

  testWidgets('in-place option-list changes cancel the obsolete preview', (
    tester,
  ) async {
    final options = [..._options];
    late StateSetter rebuild;
    final changes = <int>[];
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return _app(
            FlexSwitch<int>(
              options: options,
              selectedValue: 0,
              hapticFeedback: false,
              dragCommitBehavior: DragCommitBehavior.onRelease,
              onChanged: changes.add,
            ),
          );
        },
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Zero')),
    );
    await gesture.moveTo(tester.getCenter(find.text('Two')));
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump();
    rebuild(() => options.removeRange(2, 4));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });
  for (final wholeControl in [false, true]) {
    for (final allowDrag in [false, true]) {
      testWidgets(
        'disabling a held segment is safe whole=$wholeControl drag=$allowDrag',
        (tester) async {
          var disabled = false;
          late StateSetter rebuild;
          final changes = <int>[];
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return _app(
                  FlexSwitch<int>(
                    options: [
                      const SwitchOption(value: 0, label: 'Zero'),
                      SwitchOption(
                        value: 1,
                        label: 'One',
                        enabled: wholeControl || !disabled,
                      ),
                    ],
                    disabled: wholeControl && disabled,
                    selectedValue: 0,
                    allowDrag: allowDrag,
                    hapticFeedback: false,
                    onChanged: changes.add,
                  ),
                );
              },
            ),
          );
          final gesture = await tester.startGesture(
            tester.getCenter(find.text('One')),
          );
          // Hold beyond the tap recognizer's press timeout to exercise active ink.
          await tester.pump(const Duration(milliseconds: 200));
          expect(
            tester
                .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
                .any((opacity) => opacity.opacity == .2),
            isTrue,
          );
          rebuild(() => disabled = true);
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Disabling held ink must not setState during build',
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(changes, isEmpty);
          rebuild(() => disabled = false);
          await tester.pumpAndSettle();
          expect(
            tester
                .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
                .any((opacity) => opacity.opacity == .2),
            isFalse,
          );
          await tester.tap(find.text('One'));
          await tester.pumpAndSettle();
          expect(changes, [1], reason: 'Re-enabled interaction remains usable');
        },
      );
    }
  }

  for (final commit in DragCommitBehavior.values) {
    testWidgets(
      'diagonal drag starts outside vertical limit without committing $commit',
      (tester) async {
        final changes = <int>[];
        await tester.pumpWidget(
          _app(
            FlexSwitch<int>(
              options: const [
                SwitchOption(value: 0, label: 'Zero'),
                SwitchOption(value: 1, label: 'One'),
              ],
              selectedValue: 0,
              dragCommitBehavior: commit,
              hapticFeedback: false,
              onChanged: changes.add,
            ),
          ),
        );
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Zero')),
        );
        await gesture.moveTo(
          tester.getCenter(find.text('One')) + const Offset(0, 100),
        );
        await tester.pump();
        expect(
          changes,
          isEmpty,
          reason: 'An out-of-band drag cannot commit on start',
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(
          changes,
          isEmpty,
          reason: 'An out-of-band drag cannot commit on release',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final commit in DragCommitBehavior.values) {
    testWidgets('diagonal drag can re-enter the vertical limit $commit', (
      tester,
    ) async {
      final changes = <int>[];
      await tester.pumpWidget(
        _app(
          FlexSwitch<int>(
            options: const [
              SwitchOption(value: 0, label: 'Zero'),
              SwitchOption(value: 1, label: 'One'),
            ],
            selectedValue: 0,
            dragCommitBehavior: commit,
            hapticFeedback: false,
            onChanged: changes.add,
          ),
        ),
      );
      final end = tester.getCenter(find.text('One'));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Zero')),
      );
      await gesture.moveTo(end + const Offset(0, 100));
      await tester.pump();
      expect(changes, isEmpty);
      await gesture.moveTo(end);
      await tester.pump();
      expect(changes, commit == DragCommitBehavior.immediate ? [1] : <int>[]);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(changes, [1]);
      expect(tester.takeException(), isNull);
    });
  }
  for (final themeDriven in [false, true]) {
    testWidgets(
      'drag policy round-trip drops stale preview themeDriven=$themeDriven',
      (tester) async {
        var policy = DragCommitBehavior.onRelease;
        late StateSetter rebuild;
        final changes = <int>[];
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return MaterialApp(
                theme: ThemeData(
                  extensions: [
                    if (themeDriven)
                      FlexSwitchTheme(dragCommitBehavior: policy),
                  ],
                ),
                home: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 320,
                      child: FlexSwitch<int>(
                        options: const [
                          SwitchOption(value: 0, label: 'Zero'),
                          SwitchOption(value: 1, label: 'One'),
                        ],
                        selectedValue: 0,
                        onChanged: changes.add,
                        hapticFeedback: false,
                        style: themeDriven
                            ? null
                            : FlexSwitchStyle(dragCommitBehavior: policy),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        final thumb = find.byType(TweenAnimationBuilder<double>);
        final selectedOrigin = tester.getTopLeft(thumb);
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Zero')),
        );
        await gesture.moveTo(tester.getCenter(find.text('One')));
        await gesture.moveBy(const Offset(1, 0));
        await tester.pumpAndSettle();
        expect(changes, isEmpty);
        expect(
          tester.getTopLeft(thumb).dx,
          greaterThan(selectedOrigin.dx + 100),
        );
        rebuild(() => policy = DragCommitBehavior.immediate);
        await tester.pumpAndSettle();
        await gesture.up();
        await tester.pumpAndSettle();
        expect(changes, isEmpty);
        rebuild(() => policy = DragCommitBehavior.onRelease);
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(thumb),
          selectedOrigin,
          reason: 'Without a gesture, the thumb must reflect controlled selectedValue',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
