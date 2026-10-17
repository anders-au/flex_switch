/// When a drag commits a selection to the controlled switch.
enum DragCommitBehavior {
  /// Requests a selection change as the pointer enters an enabled segment.
  immediate,

  /// Previews the selection and requests a change when the pointer is released.
  onRelease,
}

/// Segment sizing for a FlexSwitch control.
enum FlexSwitchLayout {
  /// All segments share equal width.
  equal,

  /// Each segment gets width proportional to its intrinsic content (icon + text),
  /// scaled to fit the available space. When every segment has zero intrinsic
  /// width, all segments share equal width.
  proportional,
}
