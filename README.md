# Flex Switch

<p align="center">
  <img src="https://github.com/omar-hanafy/flex_switch/blob/main/screenshots/1.gif?raw=true" alt="FlexSwitch Sample" width="90%">
</p>

Multi-option segmented control for Flutter. Keyboard accessible, RTL-aware, drag-to-select, themable, and fast.

- Zero boilerplate: boolean, enum, or custom values
- Keyboard: Arrow/Home/End; focus ring; semantics
- Drag-to-select across segments; full-width tap targets
- RTL-aware layout and key handling
- Highly themable via `FlexSwitchStyle` and `FlexSwitchTheme`
- Proportional widths option for content-sized segments
- Drag commit options (immediate vs on-release) and thumb-drag-only
- Disable individual options via `SwitchOption.enabled`

## Install

Requires Flutter **3.47.7+** and Dart **3.13.5+**.

```sh
flutter pub add flex_switch material_ui
```

### Upgrading from 1.x

Version 2 uses the extracted `material_ui` package. Add `material_ui: ^1.6.0`
to your dependencies and replace `package:flutter/material.dart` imports with
`package:material_ui/material_ui.dart` in code using FlexSwitch and its Material
theme or style types. This includes the `MaterialApp` and `ThemeData` that provide
the switch's theme. The legacy Flutter Material types have a different identity.
See Flutter's [Material UI migration guide](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui).


## Quick start
```dart
import 'package:flex_switch/flex_switch.dart';
import 'package:material_ui/material_ui.dart';

class Example extends StatefulWidget {
  const Example({super.key});
  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return FlexSwitch.boolean(
      value: enabled,
      onChanged: (v) => setState(() => enabled = v),
      trueLabel: 'On',
      falseLabel: 'Off',
      trueIcon: Icons.check,
      falseIcon: Icons.close,
    );
  }
}
```

## Enums

```dart
enum ThemeSegment { light, system, dark }

FlexSwitch.fromEnum<ThemeSegment>(
  values: ThemeSegment.values,
  selectedValue: themeSeg,
  onChanged: (v) => setState(() => themeSeg = v),
  labelBuilder: (v) => switch (v) {
    ThemeSegment.light => 'Light',
    ThemeSegment.system => 'System',
    ThemeSegment.dark => 'Dark',
  },
  iconBuilder: (v) => switch (v) {
    ThemeSegment.light => Icons.wb_sunny_outlined,
    ThemeSegment.system => Icons.auto_mode_outlined,
    ThemeSegment.dark => Icons.dark_mode_outlined,
  },
);
```

## Custom values

```dart
FlexSwitch.fromValues<String>(
  values: const ['XS', 'S', 'M', 'L', 'XL'],
  selectedValue: size,
  onChanged: (v) => setState(() => size = v),
  label: (v) => v,
  style: const FlexSwitchStyle(
    showDividers: true,
    enableRipple: true,
  ),
);
```

## Continuous position control

Use `FlexSwitchController` when another pageable control owns an in-progress
position. Fractional values move the thumb between options without changing the
committed `selectedValue` or its semantics.

```dart
final switchController = FlexSwitchController();

switchController.syncWith(tabController.animation);

FlexSwitch.fromEnum<MyTab>(
  values: MyTab.values,
  selectedValue: selectedTab,
  controller: switchController,
  onChanged: selectTab,
);
```

## Layouts & drag behavior
```dart
FlexSwitch<int>(
  options: const [
    SwitchOption(value: 0, label: 'All', icon: Icons.inbox_rounded),
    SwitchOption(value: 1, label: 'Mentions and replies', icon: Icons.alternate_email_rounded),
    SwitchOption(value: 2, label: 'DMs', icon: Icons.mail_rounded),
  ],
  selectedValue: tab,
  onChanged: (v) => setState(() => tab = v),
  // Size segments to their content.
  layout: FlexSwitchLayout.proportional,
  // Preview while dragging; commit when released.
  dragCommitBehavior: DragCommitBehavior.onRelease,
  // Only accept drags that start on the selected thumb.
  thumbDragOnly: true,
);

// Disable an option (dimmed and skipped by all selection inputs):
const SwitchOption(value: 1, label: 'Two', enabled: false);
```

An on-release preview is discarded when the pointer is canceled, option values
or enabled states change, or the parent supplies a new selection. Disabled options cannot trigger
`onChanged` through tapping, dragging, keyboard input, or accessibility actions.

## Styling

```dart
const style = FlexSwitchStyle(
  backgroundColor: Color(0x11000000),
  thumbColor: Colors.white,
  activeLabelColor: null,   // defaults to theme.primary
  inactiveLabelColor: null, // defaults to blend of onSurface
  borderRadius: 16,
  thumbRadius: 12,
  thumbPressScale: 0.95,     // scale thumb while pressed (1.0 to disable)
  padding: 5,
  itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  gap: 8,
  shadow: [BoxShadow(blurRadius: 12, color: Colors.black26)],
  duration: Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  border: null,
  labelTextStyle: null,
  iconSize: null,            // computed from height if null
  showDividers: false,
  dividerColor: null,
  dividerThickness: 1,
  hideDividersAdjacentToThumb: true, // fade dividers touching the thumb
  dividerFadeDuration: null,         // defaults to duration
  dividerFadeCurve: null,            // defaults to curve
  focusRingWidth: 2,
  enableRipple: false,
  segmentOverlayColor: null,
  splashFactory: null,
  enableTrackHoverOverlay: true,
  segmentGutter: 6,        // interior gap; outer edges keep the track padding
  layout: FlexSwitchLayout.equal, // default layout; can also come from FlexSwitchTheme
);
```

### Theme extensions

Register `FlexSwitchTheme` in `ThemeData.extensions` to supply app-wide defaults without passing a `style`:

```dart
final theme = ThemeData(
  colorSchemeSeed: Colors.teal,
  extensions: const [
    FlexSwitchTheme(
      backgroundColor: Color(0x11000000),
      layout: FlexSwitchLayout.proportional,
    ),
  ],
);
```

Widget-level `style` overrides still take priority over the theme extension.

## Accessibility
- Announces labels via Semantics; exposes selected state per segment
- One keyboard tab stop per switch; Left/Right follow the visual direction
- Home/End select the first/last enabled option; Enter/Space cycle enabled options
- Screen-reader increase/decrease follow option order and announce the target label
- Optional `semanticsLabel` and `tooltip` per option

## Example app
See `example/` for a runnable demo showing boolean, enum, and custom values with theming.

## License
MIT — see LICENSE.
