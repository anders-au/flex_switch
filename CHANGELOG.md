# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-11

### Changed
- **Breaking:** Require Flutter 3.47.7 and Dart 3.13.5 or later.
- **Breaking:** Use `material_ui` 1.6.0 for Material widgets, themes, and style types. Add `material_ui: ^1.6.0` and migrate `package:flutter/material.dart` imports to `package:material_ui/material_ui.dart` in apps using the switch.
- Upgrade the public `SwitchOption` equality dependency to Equatable 3.0.0.

### Fixed
- Skip disabled options for keyboard and accessibility selection, including when every option is disabled.
- Announce the next or previous enabled option to screen readers and preserve logical option order in RTL.
- Discard canceled drag previews and obsolete previews after option values, enabled states, or the controlled selection change.
- Clear drag previews on release even if a style or theme changes the drag commit policy during the gesture.
- Cancel selection when the first drag movement leaves the vertical drag tolerance.
- Clear pressed feedback safely when an option is disabled while held.
- Keep keyboard traversal to one tab stop per switch, including directional navigation.
- Preserve configured label and icon transparency when dimming disabled options.
- Render keyboard focus as a perimeter ring and honor a zero ring width.
- Announce each segment label once, honoring its accessibility label override.
- Avoid drag errors on tracks with no inner width and keep content-free proportional segments selectable.
- Return an empty argument for invalid UTF-16 input in the Windows example runner.

## [1.3.0] - 2025-08-04

- Added `FlexSwitchController` for fractional, externally synchronized visual
  positioning while retaining discrete selection semantics, including direct
  `Animation<double>` binding through `syncWith`.

## [1.2.1] - 2025-10-07

Allow FlexSwitchTheme to set the default layout so proportional sizing can be configured globally.

## [1.2.0] - 2025-10-06

Introduced a theme extension-backed styling system and moved FlexSwitch style APIs into a dedicated module.

## [1.1.1] - 2025-09-29

Thumb and overlay gutter now match outer padding at the track edges.

## [1.1.0] - 2025-09-16

Added proportional layout, drag commit options, and per-option disabling.

### Added

- Proportional layout: `FlexSwitchLayout.proportional` (segments sized to content).
- Drag behavior controls:
  - `DragCommitBehavior` (immediate vs. commit on release with preview).
  - `thumbDragOnly` to require drags to start on the selected thumb.
- Per-option disable: `SwitchOption.enabled` (dim + skip selection on drag).
- Style: `thumbPressScale`, `hideDividersAdjacentToThumb`,
  `dividerFadeDuration`, `dividerFadeCurve`.

### Improved

- Smoother label/icon transitions; avoids text reflow on weight change.
- Divider fade near the thumb; pressed feedback and pinned-edge thumb scale.
- Example app with new toggles and demos.

## [1.0.0] - 2025-09-15

Initial release.

### Added

- Core `FlexSwitch` widget with:
  - Boolean factory: `FlexSwitch.boolean`
  - Enum factory: `FlexSwitch.fromEnum`
  - Values factory: `FlexSwitch.fromValues`
- Drag-to-select across segments
- Full keyboard support (Left/Right, Home/End, Enter/Space), RTL-aware
- A11y with Semantics + focus ring
- Theming via `FlexSwitchStyle` (colors, radii, dividers, ripple, animation)
- Example app under `example/`
