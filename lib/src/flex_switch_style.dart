import 'package:flex_switch/src/flex_switch_enums.dart';
import 'package:material_ui/material_ui.dart';

/// Visual style for FlexSwitch.
///
/// Constructor parameters are optional; color and typography defaults use the active
/// [ThemeData]. Use [copyWith] to derive small variations.
class FlexSwitchStyle {
  /// Creates a style descriptor for FlexSwitch. All parameters are optional.
  const FlexSwitchStyle({
    this.backgroundColor,
    this.thumbColor,
    this.activeLabelColor,
    this.inactiveLabelColor,
    this.borderRadius = 16.0,
    this.thumbRadius = 12.0,
    this.thumbPressScale = 0.95,
    this.padding = 5.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    this.gap = 8.0,
    this.shadow,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.border,
    this.labelTextStyle,
    this.iconSize,
    this.showDividers = false,
    this.dividerColor,
    this.dividerThickness = 1.0,
    this.hideDividersAdjacentToThumb = true,
    this.dividerFadeDuration,
    this.dividerFadeCurve,
    this.focusRingWidth = 2.0,
    this.enableRipple = false,
    this.segmentOverlayColor,
    this.splashFactory,
    this.enableTrackHoverOverlay = true,
    this.segmentGutter = 6.0,
    this.layout = FlexSwitchLayout.equal,
    this.dragCommitBehavior,
    this.inactiveScale = 1.0,
  });

  /// Background color of the outer track.
  final Color? backgroundColor;

  /// Background color of the moving thumb (selected segment highlight).
  final Color? thumbColor;

  /// Color for labels/icons in the selected segment.
  /// Falls back to [ColorScheme.primary] if null.
  final Color? activeLabelColor;

  /// Color for labels/icons in unselected segments.
  /// Falls back to a blended [ColorScheme.onSurface] if null.
  final Color? inactiveLabelColor;

  /// Geometry.
  ///
  /// [borderRadius] rounds the outer track.
  final double borderRadius;

  /// Rounding applied to the moving thumb.
  final double thumbRadius;

  /// Scale applied to the thumb while pressed (pinned-edge transform keeps the
  /// touching edge fixed). Set to 1.0 to disable.
  final double thumbPressScale;

  /// Padding inside the outer track (applies to all sides).
  final double padding;

  /// Padding around the contents of each segment.
  final EdgeInsets itemPadding;

  /// Horizontal space between an option icon and label within a segment.
  final double gap;

  /// Thumb shadow.
  final List<BoxShadow>? shadow;

  /// Animation parameters.
  /// Duration of thumb/content transitions.
  final Duration duration;

  /// Easing curve for thumb/content transitions.
  final Curve curve;

  /// Optional border for the outer track (e.g. `Border.all(...)`).
  final BoxBorder? border;

  /// Typographic defaults (overridable per-option).
  final TextStyle? labelTextStyle;

  /// Fixed icon size; if null, computed from height.
  final double? iconSize;

  /// Whether to draw vertical dividers between segments.
  final bool showDividers;

  /// Color of the vertical dividers (falls back to theme dividerColor).
  final Color? dividerColor;

  /// Thickness of the vertical dividers in logical pixels.
  final double dividerThickness;

  /// When [showDividers] is true: fade dividers that touch the highlighted/selected
  /// segment, matching Cupertino's behavior.
  final bool hideDividersAdjacentToThumb;

  /// Optional override for divider fade duration/curve. Falls back to [duration]/[curve].
  final Duration? dividerFadeDuration;
  final Curve? dividerFadeCurve;

  /// Focus ring width for keyboard focus.
  final double focusRingWidth;

  /// Interaction visuals for segments.
  final bool enableRipple;

  /// Overlay color for segment interactions (pressed/hover/focus).
  final WidgetStateProperty<Color?>? segmentOverlayColor;

  /// Splash factory used when [enableRipple] is true.
  final InteractiveInkFeatureFactory? splashFactory;

  /// Show a subtle hover overlay across the whole track.
  final bool enableTrackHoverOverlay;

  /// Horizontal space reserved around each segment (logical px).
  /// Interior boundaries apply half this value per neighboring segment, while
  /// the outer track edges keep the full [padding] distance.
  final double segmentGutter;

  /// Layout model used to size each segment.
  final FlexSwitchLayout layout;

  /// Drag commit policy (style-level default).
  /// Used when the widget's `dragCommitBehavior` parameter is null.
  final DragCommitBehavior? dragCommitBehavior;

  /// Scale applied to non-selected segments.
  /// Defaults to 1.0 to eliminate flicker when dragging.
  final double inactiveScale;

  /// Returns a copy with the specified fields replaced.
  FlexSwitchStyle copyWith({
    Color? backgroundColor,
    Color? thumbColor,
    Color? activeLabelColor,
    Color? inactiveLabelColor,
    double? borderRadius,
    double? thumbRadius,
    double? thumbPressScale,
    double? padding,
    EdgeInsets? itemPadding,
    double? gap,
    List<BoxShadow>? shadow,
    Duration? duration,
    Curve? curve,
    BoxBorder? border,
    TextStyle? labelTextStyle,
    double? iconSize,
    bool? showDividers,
    Color? dividerColor,
    double? dividerThickness,
    bool? hideDividersAdjacentToThumb,
    Duration? dividerFadeDuration,
    Curve? dividerFadeCurve,
    double? focusRingWidth,
    bool? enableRipple,
    WidgetStateProperty<Color?>? segmentOverlayColor,
    InteractiveInkFeatureFactory? splashFactory,
    bool? enableTrackHoverOverlay,
    double? segmentGutter,
    FlexSwitchLayout? layout,
    DragCommitBehavior? dragCommitBehavior,
    double? inactiveScale,
  }) {
    return FlexSwitchStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      thumbColor: thumbColor ?? this.thumbColor,
      activeLabelColor: activeLabelColor ?? this.activeLabelColor,
      inactiveLabelColor: inactiveLabelColor ?? this.inactiveLabelColor,
      borderRadius: borderRadius ?? this.borderRadius,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      thumbPressScale: thumbPressScale ?? this.thumbPressScale,
      padding: padding ?? this.padding,
      itemPadding: itemPadding ?? this.itemPadding,
      gap: gap ?? this.gap,
      shadow: shadow ?? this.shadow,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      border: border ?? this.border,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      iconSize: iconSize ?? this.iconSize,
      showDividers: showDividers ?? this.showDividers,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      hideDividersAdjacentToThumb:
          hideDividersAdjacentToThumb ?? this.hideDividersAdjacentToThumb,
      dividerFadeDuration: dividerFadeDuration ?? this.dividerFadeDuration,
      dividerFadeCurve: dividerFadeCurve ?? this.dividerFadeCurve,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      enableRipple: enableRipple ?? this.enableRipple,
      segmentOverlayColor: segmentOverlayColor ?? this.segmentOverlayColor,
      splashFactory: splashFactory ?? this.splashFactory,
      enableTrackHoverOverlay:
          enableTrackHoverOverlay ?? this.enableTrackHoverOverlay,
      segmentGutter: segmentGutter ?? this.segmentGutter,
      layout: layout ?? this.layout,
      dragCommitBehavior: dragCommitBehavior ?? this.dragCommitBehavior,
      inactiveScale: inactiveScale ?? this.inactiveScale,
    );
  }

  /// Merge [other] into this style; non-null fields in [other] take priority.
  FlexSwitchStyle merge(FlexSwitchStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      thumbColor: other.thumbColor,
      activeLabelColor: other.activeLabelColor,
      inactiveLabelColor: other.inactiveLabelColor,
      borderRadius: other.borderRadius,
      thumbRadius: other.thumbRadius,
      thumbPressScale: other.thumbPressScale,
      padding: other.padding,
      itemPadding: other.itemPadding,
      gap: other.gap,
      shadow: other.shadow,
      duration: other.duration,
      curve: other.curve,
      border: other.border,
      labelTextStyle: other.labelTextStyle,
      iconSize: other.iconSize,
      showDividers: other.showDividers,
      dividerColor: other.dividerColor,
      dividerThickness: other.dividerThickness,
      hideDividersAdjacentToThumb: other.hideDividersAdjacentToThumb,
      dividerFadeDuration: other.dividerFadeDuration,
      dividerFadeCurve: other.dividerFadeCurve,
      focusRingWidth: other.focusRingWidth,
      enableRipple: other.enableRipple,
      segmentOverlayColor: other.segmentOverlayColor,
      splashFactory: other.splashFactory,
      enableTrackHoverOverlay: other.enableTrackHoverOverlay,
      segmentGutter: other.segmentGutter,
      layout: other.layout,
      dragCommitBehavior: other.dragCommitBehavior,
      inactiveScale: other.inactiveScale,
    );
  }
}

/// Theme-aware defaults and overrides for FlexSwitch.
///
/// Extend your app's ThemeData with FlexSwitchTheme to set global defaults:
///
/// ```dart
/// ThemeData(
///   extensions: [
///     FlexSwitchTheme(
///       backgroundColor: Colors.grey[800],
///       thumbColor: Colors.blue,
///       borderRadius: 20.0,
///       enableRipple: true,
///     ),
///   ],
/// )
/// ```
@immutable
class FlexSwitchTheme extends ThemeExtension<FlexSwitchTheme> {
  const FlexSwitchTheme({
    this.backgroundColor,
    this.thumbColor,
    this.activeLabelColor,
    this.inactiveLabelColor,
    this.borderRadius,
    this.thumbRadius,
    this.thumbPressScale,
    this.padding,
    this.itemPadding,
    this.gap,
    this.shadow,
    this.duration,
    this.curve,
    this.border,
    this.labelTextStyle,
    this.iconSize,
    this.showDividers,
    this.dividerColor,
    this.dividerThickness,
    this.hideDividersAdjacentToThumb,
    this.dividerFadeDuration,
    this.dividerFadeCurve,
    this.focusRingWidth,
    this.enableRipple,
    this.segmentOverlayColor,
    this.splashFactory,
    this.enableTrackHoverOverlay,
    this.segmentGutter,
    this.layout,
    this.dragCommitBehavior,
    this.inactiveScale,
  });

  final Color? backgroundColor;
  final Color? thumbColor;
  final Color? activeLabelColor;
  final Color? inactiveLabelColor;
  final double? borderRadius;
  final double? thumbRadius;
  final double? thumbPressScale;
  final double? padding;
  final EdgeInsets? itemPadding;
  final double? gap;
  final List<BoxShadow>? shadow;
  final Duration? duration;
  final Curve? curve;
  final BoxBorder? border;
  final TextStyle? labelTextStyle;
  final double? iconSize;
  final bool? showDividers;
  final Color? dividerColor;
  final double? dividerThickness;
  final bool? hideDividersAdjacentToThumb;
  final Duration? dividerFadeDuration;
  final Curve? dividerFadeCurve;
  final double? focusRingWidth;
  final bool? enableRipple;
  final WidgetStateProperty<Color?>? segmentOverlayColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final bool? enableTrackHoverOverlay;
  final double? segmentGutter;
  final FlexSwitchLayout? layout;
  final DragCommitBehavior? dragCommitBehavior;
  final double? inactiveScale;

  /// Base defaults that respond to the ambient [ThemeData].
  static FlexSwitchStyle defaults(ThemeData theme) {
    return FlexSwitchStyle(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.6,
      ),
      thumbColor: theme.colorScheme.surface,
      labelTextStyle: theme.textTheme.labelLarge,
      dividerColor: theme.dividerColor.withValues(alpha: 0.35),
    );
  }

  /// Apply this extension's overrides to [base].
  FlexSwitchStyle applyTo(FlexSwitchStyle base) {
    return base.copyWith(
      backgroundColor: backgroundColor ?? base.backgroundColor,
      thumbColor: thumbColor ?? base.thumbColor,
      activeLabelColor: activeLabelColor ?? base.activeLabelColor,
      inactiveLabelColor: inactiveLabelColor ?? base.inactiveLabelColor,
      borderRadius: borderRadius ?? base.borderRadius,
      thumbRadius: thumbRadius ?? base.thumbRadius,
      thumbPressScale: thumbPressScale ?? base.thumbPressScale,
      padding: padding ?? base.padding,
      itemPadding: itemPadding ?? base.itemPadding,
      gap: gap ?? base.gap,
      shadow: shadow ?? base.shadow,
      duration: duration ?? base.duration,
      curve: curve ?? base.curve,
      border: border ?? base.border,
      labelTextStyle: labelTextStyle ?? base.labelTextStyle,
      iconSize: iconSize ?? base.iconSize,
      showDividers: showDividers ?? base.showDividers,
      dividerColor: dividerColor ?? base.dividerColor,
      dividerThickness: dividerThickness ?? base.dividerThickness,
      hideDividersAdjacentToThumb:
          hideDividersAdjacentToThumb ?? base.hideDividersAdjacentToThumb,
      dividerFadeDuration: dividerFadeDuration ?? base.dividerFadeDuration,
      dividerFadeCurve: dividerFadeCurve ?? base.dividerFadeCurve,
      focusRingWidth: focusRingWidth ?? base.focusRingWidth,
      enableRipple: enableRipple ?? base.enableRipple,
      segmentOverlayColor: segmentOverlayColor ?? base.segmentOverlayColor,
      splashFactory: splashFactory ?? base.splashFactory,
      enableTrackHoverOverlay:
          enableTrackHoverOverlay ?? base.enableTrackHoverOverlay,
      segmentGutter: segmentGutter ?? base.segmentGutter,
      layout: layout ?? base.layout,
      dragCommitBehavior: dragCommitBehavior ?? base.dragCommitBehavior,
      inactiveScale: inactiveScale ?? base.inactiveScale,
    );
  }

  /// Resolve the effective style using widget overrides, theme extension, and defaults.
  static FlexSwitchStyle resolve(
    BuildContext context,
    FlexSwitchStyle? widgetOverride,
  ) {
    final theme = Theme.of(context);
    // Defaults derived from ThemeData.
    FlexSwitchStyle resolved = defaults(theme);
    // Theme extension overrides.
    final extension = theme.extension<FlexSwitchTheme>();
    if (extension != null) {
      resolved = extension.applyTo(resolved);
    }
    // Widget-level overrides take highest priority.
    resolved = resolved.merge(widgetOverride);
    return resolved;
  }

  @override
  FlexSwitchTheme copyWith({
    Color? backgroundColor,
    Color? thumbColor,
    Color? activeLabelColor,
    Color? inactiveLabelColor,
    double? borderRadius,
    double? thumbRadius,
    double? thumbPressScale,
    double? padding,
    EdgeInsets? itemPadding,
    double? gap,
    List<BoxShadow>? shadow,
    Duration? duration,
    Curve? curve,
    BoxBorder? border,
    TextStyle? labelTextStyle,
    double? iconSize,
    bool? showDividers,
    Color? dividerColor,
    double? dividerThickness,
    bool? hideDividersAdjacentToThumb,
    Duration? dividerFadeDuration,
    Curve? dividerFadeCurve,
    double? focusRingWidth,
    bool? enableRipple,
    WidgetStateProperty<Color?>? segmentOverlayColor,
    InteractiveInkFeatureFactory? splashFactory,
    bool? enableTrackHoverOverlay,
    double? segmentGutter,
    FlexSwitchLayout? layout,
    DragCommitBehavior? dragCommitBehavior,
    double? inactiveScale,
  }) {
    return FlexSwitchTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      thumbColor: thumbColor ?? this.thumbColor,
      activeLabelColor: activeLabelColor ?? this.activeLabelColor,
      inactiveLabelColor: inactiveLabelColor ?? this.inactiveLabelColor,
      borderRadius: borderRadius ?? this.borderRadius,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      thumbPressScale: thumbPressScale ?? this.thumbPressScale,
      padding: padding ?? this.padding,
      itemPadding: itemPadding ?? this.itemPadding,
      gap: gap ?? this.gap,
      shadow: shadow ?? this.shadow,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      border: border ?? this.border,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      iconSize: iconSize ?? this.iconSize,
      showDividers: showDividers ?? this.showDividers,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      hideDividersAdjacentToThumb:
          hideDividersAdjacentToThumb ?? this.hideDividersAdjacentToThumb,
      dividerFadeDuration: dividerFadeDuration ?? this.dividerFadeDuration,
      dividerFadeCurve: dividerFadeCurve ?? this.dividerFadeCurve,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      enableRipple: enableRipple ?? this.enableRipple,
      segmentOverlayColor: segmentOverlayColor ?? this.segmentOverlayColor,
      splashFactory: splashFactory ?? this.splashFactory,
      enableTrackHoverOverlay:
          enableTrackHoverOverlay ?? this.enableTrackHoverOverlay,
      segmentGutter: segmentGutter ?? this.segmentGutter,
      layout: layout ?? this.layout,
      dragCommitBehavior: dragCommitBehavior ?? this.dragCommitBehavior,
      inactiveScale: inactiveScale ?? this.inactiveScale,
    );
  }

  @override
  FlexSwitchTheme lerp(ThemeExtension<FlexSwitchTheme>? other, double t) {
    if (other is! FlexSwitchTheme) return this;
    return FlexSwitchTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      thumbColor: Color.lerp(thumbColor, other.thumbColor, t),
      activeLabelColor: Color.lerp(activeLabelColor, other.activeLabelColor, t),
      inactiveLabelColor: Color.lerp(
        inactiveLabelColor,
        other.inactiveLabelColor,
        t,
      ),
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      thumbRadius: t < 0.5 ? thumbRadius : other.thumbRadius,
      thumbPressScale: t < 0.5 ? thumbPressScale : other.thumbPressScale,
      padding: t < 0.5 ? padding : other.padding,
      itemPadding: EdgeInsets.lerp(itemPadding, other.itemPadding, t),
      gap: t < 0.5 ? gap : other.gap,
      shadow: t < 0.5 ? shadow : other.shadow,
      duration: t < 0.5 ? duration : other.duration,
      curve: t < 0.5 ? curve : other.curve,
      border: t < 0.5 ? border : other.border,
      labelTextStyle: TextStyle.lerp(labelTextStyle, other.labelTextStyle, t),
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      showDividers: t < 0.5 ? showDividers : other.showDividers,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      dividerThickness: t < 0.5 ? dividerThickness : other.dividerThickness,
      hideDividersAdjacentToThumb: t < 0.5
          ? hideDividersAdjacentToThumb
          : other.hideDividersAdjacentToThumb,
      dividerFadeDuration: t < 0.5
          ? dividerFadeDuration
          : other.dividerFadeDuration,
      dividerFadeCurve: t < 0.5 ? dividerFadeCurve : other.dividerFadeCurve,
      focusRingWidth: t < 0.5 ? focusRingWidth : other.focusRingWidth,
      enableRipple: t < 0.5 ? enableRipple : other.enableRipple,
      segmentOverlayColor: t < 0.5
          ? segmentOverlayColor
          : other.segmentOverlayColor,
      splashFactory: t < 0.5 ? splashFactory : other.splashFactory,
      enableTrackHoverOverlay: t < 0.5
          ? enableTrackHoverOverlay
          : other.enableTrackHoverOverlay,
      segmentGutter: t < 0.5 ? segmentGutter : other.segmentGutter,
      layout: t < 0.5 ? layout : other.layout,
      dragCommitBehavior: t < 0.5
          ? dragCommitBehavior
          : other.dragCommitBehavior,
      inactiveScale: t < 0.5 ? inactiveScale : other.inactiveScale,
    );
  }
}
