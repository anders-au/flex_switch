# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
