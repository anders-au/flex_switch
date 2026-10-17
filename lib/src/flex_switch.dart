import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flex_switch/flex_switch.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A single selectable option used by [FlexSwitch].
///
/// Each option holds a `value` of type `T` and optional presentation
/// metadata (text [label], [icon]) and per-option style overrides.
///
/// Equality is based on [value] only so that options lists can be rebuilt
/// without breaking selection.
@immutable
class SwitchOption<T> extends Equatable {
  /// Creates an option for [FlexSwitch].
  ///
  /// - [value] uniquely identifies the option and participates in equality.
  /// - [label] and [icon] drive visual presentation.
  /// - [activeColor], [inactiveColor], and [textStyle] can override the
  ///   effective colors or typography for this option only.
  /// - [semanticsLabel] and [tooltip] enhance accessibility/UX.
  const SwitchOption({
    required this.value,
    this.label,
    this.icon,
    this.activeColor,
    this.inactiveColor,
    this.textStyle,
    this.semanticsLabel,
    this.tooltip,
    this.enabled = true,
  });

  /// The underlying value for this option.
  ///
  /// This is used for selection and equality.
  final T value;

  /// Optional short text shown inside the segment.
  final String? label;

  /// Optional icon shown alongside [label].
  final IconData? icon;

  /// Per-option active label/icon color. Falls back to
  /// [FlexSwitchStyle.activeLabelColor] or theme.
  final Color? activeColor;

  /// Per-option inactive label/icon color. Falls back to
  /// [FlexSwitchStyle.inactiveLabelColor] or theme blend.
  final Color? inactiveColor;

  /// Per-option text style. Falls back to
  /// [FlexSwitchStyle.labelTextStyle] or theme text style.
  final TextStyle? textStyle;

  /// Optional semantics label exposed to screen readers for this option.
  final String? semanticsLabel;

  /// Optional tooltip shown on long press or mouse hover.
  final String? tooltip;

  /// If false, this option is visually dimmed and cannot be selected by user
  /// interaction (but can still be selected programmatically).
  final bool enabled;

  @override
  List<Object?> get props => [value];
}

/// Universal, multi-option segmented control.
///
/// Features
/// - Boolean, enum, or arbitrary values
/// - Keyboard: Left/Right (RTL-aware), Home/End, Enter/Space
/// - Drag-to-select across segments
/// - Semantics, focus ring, and tooltips
/// - Highly themable via [FlexSwitchStyle]
class FlexSwitch<T> extends StatefulWidget {
  /// Creates a segmented control with custom [options].
  ///
  /// At least two options are required. The control is fully controlled via
  /// [selectedValue] and [onChanged].
  const FlexSwitch({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.style,
    this.height,
    this.disabled = false,
    this.hapticFeedback = true,
    this.layout,
    this.allowDrag = true,
    this.dragCommitBehavior,
    this.thumbDragOnly = false,
    this.semanticsLabel,
    this.semanticValueBuilder,
    this.controller,
  }) : assert(options.length >= 2, 'FlexSwitch requires at least two options');

  /// Convenience constructor for a two-state boolean switch.
  ///
  /// Use [trueLabel]/[falseLabel] and [trueIcon]/[falseIcon] to customize
  /// the presentation of the two segments.
  static FlexSwitch<bool> boolean({
    Key? key,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? trueLabel,
    String? falseLabel,
    IconData? trueIcon,
    IconData? falseIcon,
    FlexSwitchStyle? style,
    double? height,
    bool disabled = false,
    bool hapticFeedback = true,
    FlexSwitchLayout? layout,
    bool allowDrag = true,
    DragCommitBehavior? dragCommitBehavior,
    bool thumbDragOnly = false,
    FlexSwitchController? controller,
  }) {
    return FlexSwitch<bool>(
      key: key,
      selectedValue: value,
      onChanged: onChanged,
      style: style,
      height: height,
      disabled: disabled,
      hapticFeedback: hapticFeedback,
      layout: layout,
      allowDrag: allowDrag,
      dragCommitBehavior: dragCommitBehavior,
      thumbDragOnly: thumbDragOnly,
      controller: controller,
      options: [
        SwitchOption<bool>(value: false, label: falseLabel, icon: falseIcon),
        SwitchOption<bool>(value: true, label: trueLabel, icon: trueIcon),
      ],
    );
  }

  /// Convenience constructor for enums.
  ///
  /// Provide [values] to control order; [labelBuilder] and [iconBuilder]
  /// derive presentation from each enum value. Optionally tint the active
  /// segment per-value via [activeColorBuilder].
  static FlexSwitch<E> fromEnum<E extends Enum>({
    Key? key,
    required E selectedValue,
    required ValueChanged<E> onChanged,
    required List<E> values,
    String Function(E)? labelBuilder,
    IconData Function(E)? iconBuilder,
    Color Function(E)? activeColorBuilder,
    FlexSwitchStyle? style,
    double? height,
    bool disabled = false,
    bool hapticFeedback = true,
    FlexSwitchLayout? layout,
    bool allowDrag = true,
    DragCommitBehavior? dragCommitBehavior,
    bool thumbDragOnly = false,
    FlexSwitchController? controller,
  }) {
    return FlexSwitch<E>(
      key: key,
      selectedValue: selectedValue,
      onChanged: onChanged,
      style: style,
      height: height,
      disabled: disabled,
      hapticFeedback: hapticFeedback,
      layout: layout,
      allowDrag: allowDrag,
      dragCommitBehavior: dragCommitBehavior,
      thumbDragOnly: thumbDragOnly,
      controller: controller,
      options: values
          .map(
            (e) => SwitchOption<E>(
              value: e,
              label: labelBuilder?.call(e) ?? e.name,
              icon: iconBuilder?.call(e),
              activeColor: activeColorBuilder?.call(e),
            ),
          )
          .toList(),
    );
  }

  /// Convenience constructor for arbitrary value lists.
  ///
  /// Use [label] (and optionally [icon] / [activeColor]) to map values to
  /// presentation. Values participate in selection and equality.
  static FlexSwitch<V> fromValues<V>({
    Key? key,
    required List<V> values,
    required V selectedValue,
    required ValueChanged<V> onChanged,
    required String Function(V) label,
    IconData Function(V)? icon,
    Color Function(V)? activeColor,
    FlexSwitchStyle? style,
    double? height,
    bool disabled = false,
    bool hapticFeedback = true,
    FlexSwitchLayout? layout,
    bool allowDrag = true,
    DragCommitBehavior? dragCommitBehavior,
    bool thumbDragOnly = false,
    FlexSwitchController? controller,
  }) {
    return FlexSwitch<V>(
      key: key,
      selectedValue: selectedValue,
      onChanged: onChanged,
      style: style,
      height: height,
      disabled: disabled,
      hapticFeedback: hapticFeedback,
      layout: layout,
      allowDrag: allowDrag,
      dragCommitBehavior: dragCommitBehavior,
      thumbDragOnly: thumbDragOnly,
      controller: controller,
      options: values
          .map(
            (v) => SwitchOption<V>(
              value: v,
              label: label(v),
              icon: icon?.call(v),
              activeColor: activeColor?.call(v),
            ),
          )
          .toList(),
    );
  }

  /// The list of segments to show, in visual order.
  final List<SwitchOption<T>> options;

  /// The currently selected option's [SwitchOption.value].
  final T selectedValue;

  /// Called when selection changes because of user interaction.
  final ValueChanged<T> onChanged;

  /// Visual customization and interaction styling.
  final FlexSwitchStyle? style;

  /// Height of the control. If null, an adaptive default is used.
  final double? height;

  /// If true, the control is non-interactive and visually disabled.
  final bool disabled;

  /// If true, taps/drags trigger a subtle haptic selection click.
  final bool hapticFeedback;

  /// Layout model for segment sizing. Set to null to inherit from [FlexSwitchStyle].
  final FlexSwitchLayout? layout;

  /// If true, horizontal drag over the control changes selection.
  final bool allowDrag;

  /// Whether selection should be committed immediately while dragging, or only on release.
  /// If null, defers to [FlexSwitchStyle.dragCommitBehavior] when provided. Otherwise defaults
  /// to [DragCommitBehavior.onRelease] when [thumbDragOnly] is true, or
  /// [DragCommitBehavior.immediate] when drags can originate anywhere.
  final DragCommitBehavior? dragCommitBehavior;

  /// If true, drags are only accepted when they start on the currently selected
  /// segment (thumb). Otherwise any horizontal drag over the control is accepted.
  final bool thumbDragOnly;

  /// Optional semantic label for the whole control (e.g. "Theme mode").
  final String? semanticsLabel;

  /// Provides an accessible value string for screen readers.
  /// Defaults to the current option's [SwitchOption.label] if available.
  final String Function(T value)? semanticValueBuilder;

  /// Controls the continuous visual position without changing semantics.
  final FlexSwitchController? controller;

  @override
  State<FlexSwitch<T>> createState() => _FlexSwitchState<T>();
}

class _FlexSwitchState<T> extends State<FlexSwitch<T>> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'FlexSwitch');
  late List<SwitchOption<T>> _previousOptions;
  bool _hovering = false;
  bool _focused = false;

  // Drag state
  int? _highlightedIndex; // Preview index when commit-on-release is active
  int? _lastDragIndex; // Last enabled index visited during drag
  Offset? _lastDragDownLocal; // Pointer down location before drag recognition
  static const double _kTouchYDistanceThreshold = 50; // logical px guard
  bool _dragAccepted = false;

  // Per-segment interaction state no longer tracked; Material handles ink.
  final Set<int> _pressed = <int>{};
  bool _thumbPressed = false;

  int get _selectedIndex => math.max(
    0,
    widget.options.indexWhere((o) => o.value == widget.selectedValue),
  );

  void _handleControllerChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _previousOptions = List.of(widget.options);
    widget.controller?.addListener(_handleControllerChanged);
  }

  void _announceAndChange(T value) {
    if (widget.disabled ||
        !widget.options.any(
          (option) => option.value == value && option.enabled,
        )) {
      return;
    }
    if (value == widget.selectedValue) return;
    if (widget.hapticFeedback) HapticFeedback.selectionClick();
    widget.onChanged(value);
  }

  int? _nextEnabledIndex(int start, int delta, {bool wrap = false}) {
    final count = widget.options.length;
    for (var step = 1; step < count; step++) {
      final candidate = start + delta * step;
      if (!wrap && (candidate < 0 || candidate >= count)) return null;
      final index = candidate % count;
      if (_isEnabledIndex(index)) return index;
    }
    return null;
  }

  void _moveBy(int delta) {
    final direction = Directionality.of(context);
    final logicalDelta = direction == TextDirection.ltr ? delta : -delta;
    final next = _nextEnabledIndex(_selectedIndex, logicalDelta);
    if (next != null) _announceAndChange(widget.options[next].value);
  }

  void _moveToEdge({required bool last}) {
    final index = last
        ? widget.options.lastIndexWhere((option) => option.enabled)
        : widget.options.indexWhere((option) => option.enabled);
    if (index >= 0) _announceAndChange(widget.options[index].value);
  }

  void _activate() {
    final next = _nextEnabledIndex(_selectedIndex, 1, wrap: true);
    if (next != null) _announceAndChange(widget.options[next].value);
  }

  String _semanticValueAt(int index) {
    final option = widget.options[index];
    return widget.semanticValueBuilder?.call(option.value) ??
        option.semanticsLabel ??
        option.label ??
        index.toString();
  }

  void _clearDrag() {
    _highlightedIndex = null;
    _lastDragIndex = null;
    _lastDragDownLocal = null;
    _dragAccepted = false;
    _thumbPressed = false;
  }

  @override
  void didUpdateWidget(FlexSwitch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
    final optionsChanged =
        _previousOptions.length != widget.options.length ||
        List.generate(widget.options.length, (index) => index).any(
          (index) =>
              _previousOptions[index].value != widget.options[index].value ||
              _previousOptions[index].enabled != widget.options[index].enabled,
        );
    // Keep an independent list so in-place edits cannot hide obsolete indices.
    _previousOptions = List.of(widget.options);
    if (optionsChanged ||
        widget.disabled ||
        !widget.allowDrag ||
        widget.layout != oldWidget.layout ||
        widget.dragCommitBehavior != oldWidget.dragCommitBehavior ||
        widget.thumbDragOnly != oldWidget.thumbDragOnly ||
        (_highlightedIndex != null &&
            widget.selectedValue != oldWidget.selectedValue)) {
      _clearDrag();
      _pressed.clear();
    }
  }

  int _indexFromDx({
    required double dx,
    required double trackWidth,
    required double segmentWidth,
    required double padding,
  }) {
    final dir = Directionality.of(context);
    final clamped = dx.clamp(padding, trackWidth - padding);
    var index = ((clamped - padding) / segmentWidth).floor();
    index = index.clamp(0, widget.options.length - 1);
    if (dir == TextDirection.rtl) {
      index = (widget.options.length - 1) - index;
    }
    return index;
  }

  /// Resolve index for variable width segments (LTR physical order), then map to logical index.
  int _indexFromDxVariable({
    required double dx,
    required double trackWidth,
    required double padding,
    required List<double> segmentWidths, // physical LTR order
  }) {
    final clamped = dx.clamp(padding, trackWidth - padding);
    double cursor = padding;
    int physicalIndex = 0;
    for (; physicalIndex < segmentWidths.length; physicalIndex++) {
      final end = cursor + segmentWidths[physicalIndex];
      if (clamped <= end) break;
      cursor = end;
    }
    physicalIndex = physicalIndex.clamp(0, segmentWidths.length - 1);
    final dir = Directionality.of(context);
    return dir == TextDirection.rtl
        ? (segmentWidths.length - 1 - physicalIndex)
        : physicalIndex;
  }

  bool _isEnabledIndex(int i) =>
      i >= 0 && i < widget.options.length && widget.options[i].enabled;

  /// Pick the nearest enabled index to [i]. Prefers right, then left at equal distance.
  int _nearestEnabledIndex(int i) {
    if (widget.options.isEmpty) return 0;
    final last = widget.options.length - 1;
    final int base = i.clamp(0, last);
    if (_isEnabledIndex(base)) return base;
    for (int d = 1; d <= last; d++) {
      final r = base + d;
      if (r <= last && _isEnabledIndex(r)) return r;
      final l = base - d;
      if (l >= 0 && _isEnabledIndex(l)) return l;
    }
    return base; // fallback (shouldn't happen if at least one enabled)
  }

  // Segment overlay color resolution is now delegated to Ink overlayColor
  // via WidgetStateProperty on _SegmentInkWell; no manual overlay layer.

  double _computeDefaultHeight(ThemeData theme) {
    // Respect minimum tap size.
    const minInteractive = kMinInteractiveDimension;
    // Heuristic default based on typography.
    final base = theme.textTheme.labelLarge?.fontSize ?? 14;
    final h = (base * 3.0).clamp(36.0, 56.0);
    return math.max(minInteractive, h);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = widget.height ?? _computeDefaultHeight(theme);
    final style = FlexSwitchTheme.resolve(context, widget.style);
    final layout = widget.layout ?? style.layout;
    final List<SwitchOption<T>> options = widget.options;
    final int optionCount = options.length;
    final int selectedIndex = _selectedIndex.clamp(0, optionCount - 1);
    final interactive =
        !widget.disabled && options.any((option) => option.enabled);
    final nextIndex = _nextEnabledIndex(selectedIndex, 1);
    final previousIndex = _nextEnabledIndex(selectedIndex, -1);
    final DragCommitBehavior effectiveCommit =
        widget.dragCommitBehavior ??
        style.dragCommitBehavior ??
        (widget.thumbDragOnly
            ? DragCommitBehavior.onRelease
            : DragCommitBehavior.immediate);
    final bool previewOnDrag = effectiveCommit == DragCommitBehavior.onRelease;

    final thumbShadow =
        style.shadow ??
        <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ];

    return FocusableActionDetector(
      focusNode: _focusNode,
      enabled: interactive,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      onShowFocusHighlight: (f) => setState(() => _focused = f),
      onShowHoverHighlight: (h) => setState(() => _hovering = h),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowRight): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.home): _MoveToIntent(0),
        SingleActivator(LogicalKeyboardKey.end): _MoveToIntent(-1),
      },
      actions: <Type, Action<Intent>>{
        _MoveIntent: CallbackAction<_MoveIntent>(
          onInvoke: (intent) {
            _moveBy(intent.delta);
            return null;
          },
        ),
        _MoveToIntent: CallbackAction<_MoveToIntent>(
          onInvoke: (intent) {
            _moveToEdge(last: intent.index < 0);
            return null;
          },
        ),
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            _activate();
            return null;
          },
        ),
      },
      child: Semantics(
        container: true,
        label: widget.semanticsLabel,
        value: _semanticValueAt(selectedIndex),
        increasedValue: interactive && nextIndex != null
            ? _semanticValueAt(nextIndex)
            : null,
        decreasedValue: interactive && previousIndex != null
            ? _semanticValueAt(previousIndex)
            : null,
        onIncrease: interactive && nextIndex != null
            ? () => _announceAndChange(options[nextIndex].value)
            : null,
        onDecrease: interactive && previousIndex != null
            ? () => _announceAndChange(options[previousIndex].value)
            : null,
        enabled: interactive,
        child: Opacity(
          opacity: widget.disabled ? 0.6 : 1.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hasWidth =
                  constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
              final width = hasWidth
                  ? constraints.maxWidth
                  : 300.0; // safe default if unconstrained
              final media = MediaQuery.maybeOf(context);
              final textScaler = media?.textScaler ?? TextScaler.noScaling;
              final textDirection = Directionality.of(context);
              const weightActive = FontWeight.w600;
              const weightInactive = FontWeight.w500;
              final baseDefault =
                  style.labelTextStyle ??
                  theme.textTheme.labelLarge ??
                  const TextStyle();
              final iconSize = style.iconSize ?? math.max(16, height * 0.45);
              final trackRadius = BorderRadius.circular(style.borderRadius);
              final thumbRadius = BorderRadius.circular(style.thumbRadius);
              final padding = style.padding;
              final innerWidth = math.max(0, width - 2 * padding);
              final count = widget.options.length;
              final segmentWidth = innerWidth / count;
              // Gutter: inset visuals (thumb/overlay) from dividers.
              final rawGutter = style.segmentGutter;
              final gutter = math.max(
                0,
                math.min(rawGutter, segmentWidth * 0.45),
              );

              double measureLabelWidth(SwitchOption<T> option) {
                final label = option.label;
                if (label == null || label.isEmpty) return 0;
                final labelStyle = (option.textStyle ?? baseDefault).copyWith(
                  fontWeight: weightActive,
                );
                final painter = TextPainter(
                  text: TextSpan(text: label, style: labelStyle),
                  textDirection: textDirection,
                  maxLines: 1,
                  textScaler: textScaler,
                );
                try {
                  painter.layout(maxWidth: double.infinity);
                  return painter.width;
                } finally {
                  painter.dispose();
                }
              }

              final List<double> labelReserveWidths = List<double>.generate(
                count,
                (i) => measureLabelWidth(widget.options[i]),
                growable: false,
              );

              // Selected/highlighted thumb geometry.
              // Support proportional widths by measuring intrinsic content widths.
              final double equalSegmentWidth = segmentWidth;
              List<double> segmentWidths;
              if (layout == FlexSwitchLayout.equal) {
                segmentWidths = List<double>.filled(count, equalSegmentWidth);
              } else {
                final List<double> intrinsic = <double>[];
                for (var i = 0; i < count; i++) {
                  final o = widget.options[i];
                  double w = labelReserveWidths[i];
                  if (o.icon != null) w += iconSize;
                  if (o.icon != null && (o.label ?? '').isNotEmpty) {
                    w += style.gap;
                  }
                  w += style.itemPadding.horizontal;
                  intrinsic.add(w);
                }
                final totalIntrinsic = intrinsic.fold<double>(
                  0,
                  (a, b) => a + b,
                );
                segmentWidths = totalIntrinsic == 0
                    ? List<double>.filled(count, equalSegmentWidth)
                    : intrinsic
                          .map((w) => w * innerWidth / totalIntrinsic)
                          .toList(growable: false);
              }

              final int effectiveIndex =
                  previewOnDrag && _highlightedIndex != null
                  ? _highlightedIndex!
                  : _selectedIndex;
              final controlledPosition = widget.controller?.position;
              final visualPosition =
                  (controlledPosition ?? effectiveIndex.toDouble()).clamp(
                    0.0,
                    count - 1.0,
                  );
              final bool isRTL =
                  Directionality.of(context) == TextDirection.rtl;
              // Geometry uses physical left-to-right order for prefix sums.
              final List<double> segmentWidthsLTR = isRTL
                  ? segmentWidths.reversed.toList(growable: false)
                  : segmentWidths;
              ({double left, double width}) geometryForIndex(int index) {
                final physicalIndex = isRTL ? count - 1 - index : index;
                final prefixSum = segmentWidthsLTR
                    .take(physicalIndex)
                    .fold<double>(0, (a, b) => a + b);
                final leadingInset = physicalIndex == 0 ? 0.0 : gutter / 2;
                final trailingInset = physicalIndex == count - 1
                    ? 0.0
                    : gutter / 2;
                return (
                  left: padding + prefixSum + leadingInset,
                  width: math.max(
                    0,
                    segmentWidthsLTR[physicalIndex] -
                        leadingInset -
                        trailingInset,
                  ),
                );
              }

              final lowerIndex = visualPosition.floor();
              final upperIndex = visualPosition.ceil();
              final fraction = visualPosition - lowerIndex;
              final lowerGeometry = geometryForIndex(lowerIndex);
              final upperGeometry = geometryForIndex(upperIndex);
              final left = ui.lerpDouble(
                lowerGeometry.left,
                upperGeometry.left,
                fraction,
              )!;
              final thumbVisualWidth = ui.lerpDouble(
                lowerGeometry.width,
                upperGeometry.width,
                fraction,
              )!;
              final physicalIndexLTR = isRTL
                  ? count - 1 - visualPosition.round()
                  : visualPosition.round();
              final isEdgeLeft = physicalIndexLTR == 0;
              final isEdgeRight = physicalIndexLTR == count - 1;

              final bgColor =
                  style.backgroundColor ??
                  theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  );
              final thumbColor = style.thumbColor ?? theme.colorScheme.surface;

              Widget content = SizedBox(
                height: height,
                width: width,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track
                    _TrackDecoration(
                      radius: trackRadius,
                      color: bgColor,
                      border: style.border,
                    ),

                    // Optional dividers (crisp, positioned at exact boundaries)
                    if (style.showDividers && count > 1)
                      IgnorePointer(
                        child: Stack(
                          children: List.generate(count - 1, (i) {
                            // Divider i sits after physical segment i (LTR order).
                            final double x =
                                padding +
                                segmentWidthsLTR
                                    .take(i + 1)
                                    .fold<double>(0, (a, b) => a + b) -
                                (style.dividerThickness / 2);
                            final bool touchesSelected =
                                (i == physicalIndexLTR) ||
                                (i == physicalIndexLTR - 1);
                            return Positioned(
                              left: x,
                              top: padding,
                              bottom: padding,
                              child: SizedBox(
                                width: style.dividerThickness,
                                child: AnimatedOpacity(
                                  key: ValueKey('divider_$i'),
                                  duration:
                                      style.dividerFadeDuration ??
                                      style.duration,
                                  curve: style.dividerFadeCurve ?? style.curve,
                                  opacity:
                                      (style.hideDividersAdjacentToThumb &&
                                          touchesSelected)
                                      ? 0.0
                                      : 1.0,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color:
                                          style.dividerColor ??
                                          theme.dividerColor.withValues(
                                            alpha: 0.35,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                    // Animated thumb
                    AnimatedPositioned(
                      duration: controlledPosition == null
                          ? style.duration
                          : Duration.zero,
                      curve: style.curve,
                      left: left,
                      top: padding,
                      width: thumbVisualWidth,
                      height: height - 2 * padding,
                      child: TweenAnimationBuilder<double>(
                        duration: style.duration,
                        curve: style.curve,
                        tween: Tween<double>(
                          begin: 1,
                          end: (_thumbPressed && !_hovering)
                              ? (style.thumbPressScale.clamp(0.8, 1.0))
                              : 1.0,
                        ),
                        builder: (context, scale, child) {
                          final double w = thumbVisualWidth;
                          final double delta = isEdgeLeft
                              ? (w - w * scale)
                              : isEdgeRight
                              ? (w * scale - w)
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(-delta / 2, 0),
                            child: Transform.scale(scale: scale, child: child),
                          );
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: thumbColor,
                            borderRadius: thumbRadius,
                            boxShadow: thumbShadow,
                          ),
                        ),
                      ),
                    ),

                    // Segment ink overlays are handled by _SegmentInkWell below.

                    // Row of interactive segments (full-width tap target per segment)
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        children: List.generate(count, (i) {
                          final option = widget.options[i];
                          final selectionProgress =
                              (1 - (visualPosition - i).abs()).clamp(0.0, 1.0);
                          final selected = selectionProgress > 0.5;
                          final Color activeColor =
                              option.activeColor ??
                              style.activeLabelColor ??
                              theme.colorScheme.primary;
                          final Color inactiveColor =
                              option.inactiveColor ??
                              style.inactiveLabelColor ??
                              theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              );
                          final baseTextStyle =
                              option.textStyle ??
                              style.labelTextStyle ??
                              theme.textTheme.labelLarge;
                          // Jitter-free font weight/color animation
                          final base = baseTextStyle ?? const TextStyle();
                          final resolvedColor = selected
                              ? activeColor
                              : inactiveColor;
                          final contentColor = resolvedColor.withValues(
                            alpha:
                                resolvedColor.a * (option.enabled ? 1.0 : 0.4),
                          );
                          final displayStyle = base.copyWith(
                            fontWeight: selected
                                ? weightActive
                                : weightInactive,
                            color: contentColor,
                          );
                          final reservedLabelWidth = labelReserveWidths[i];

                          final label = option.label;
                          final icon = option.icon;

                          final segmentVisual = Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (icon != null)
                                    Icon(
                                      icon,
                                      size: iconSize,
                                      color: contentColor,
                                    ),
                                  if (icon != null && label != null)
                                    SizedBox(width: style.gap),
                                  if (label != null)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: reservedLabelWidth,
                                      ),
                                      child: AnimatedDefaultTextStyle(
                                        duration: style.duration,
                                        curve: style.curve,
                                        style: displayStyle,
                                        child: Text(
                                          label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );

                          // No local borderRadius var needed; InkWell uses thumbRadius directly.
                          final segmentCell = Tooltip(
                            message:
                                option.tooltip ??
                                option.semanticsLabel ??
                                option.label ??
                                '',
                            waitDuration: const Duration(milliseconds: 400),
                            child: Builder(
                              builder: (inkCtx) {
                                final isPressed = _pressed.contains(i);
                                final int physicalIndexForInk = isRTL
                                    ? (count - 1 - i)
                                    : i;
                                final double inkLeftInset =
                                    physicalIndexForInk == 0 ? 0.0 : gutter / 2;
                                final double inkRightInset =
                                    physicalIndexForInk == count - 1
                                    ? 0.0
                                    : gutter / 2;

                                return Material(
                                  type: MaterialType.transparency,
                                  child: _SegmentInkWell(
                                    canRequestFocus: false,
                                    onTap: (option.enabled && !widget.disabled)
                                        ? () {
                                            _focusNode.requestFocus();
                                            _announceAndChange(option.value);
                                          }
                                        : null,
                                    onHighlightChanged:
                                        option.enabled && !widget.disabled
                                        ? (down) {
                                            setState(() {
                                              if (down) {
                                                _pressed.add(i);
                                                if (i == effectiveIndex) {
                                                  _thumbPressed = true;
                                                }
                                              } else {
                                                _pressed.remove(i);
                                                if (i == effectiveIndex) {
                                                  _thumbPressed = false;
                                                }
                                              }
                                            });
                                          }
                                        : null,
                                    borderRadius: BorderRadius.circular(
                                      style.thumbRadius,
                                    ),
                                    overlayColor:
                                        style.segmentOverlayColor ??
                                        WidgetStateProperty.resolveWith<
                                          Color?
                                        >((states) {
                                          final base =
                                              theme.colorScheme.onSurface;
                                          if (states.contains(
                                            WidgetState.disabled,
                                          )) {
                                            return Colors.transparent;
                                          }
                                          if (states.contains(
                                            WidgetState.pressed,
                                          )) {
                                            return base.withValues(alpha: 0.10);
                                          }
                                          if (states.contains(
                                            WidgetState.hovered,
                                          )) {
                                            return base.withValues(alpha: 0.06);
                                          }
                                          if (states.contains(
                                            WidgetState.focused,
                                          )) {
                                            return base.withValues(alpha: 0.08);
                                          }
                                          return Colors.transparent;
                                        }),
                                    splashFactory: style.enableRipple
                                        ? (style.splashFactory ??
                                              InkRipple.splashFactory)
                                        : NoSplash.splashFactory,
                                    splashColor: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.14),
                                    leftInset: inkLeftInset,
                                    rightInset: inkRightInset,
                                    child: Semantics(
                                      excludeSemantics: true,
                                      enabled:
                                          option.enabled && !widget.disabled,
                                      selected: selected,
                                      button: true,
                                      inMutuallyExclusiveGroup: true,
                                      label:
                                          option.semanticsLabel ??
                                          option.label ??
                                          'Option $i',
                                      child: SizedBox.expand(
                                        child: Padding(
                                          padding: style.itemPadding,
                                          child: AnimatedScale(
                                            scale: selected
                                                ? 1.0
                                                : style.inactiveScale,
                                            duration: style.duration,
                                            curve: style.curve,
                                            child: AnimatedOpacity(
                                              duration: style.duration,
                                              curve: style.curve,
                                              opacity: (!selected && isPressed)
                                                  ? 0.2
                                                  : 1.0,
                                              child: segmentVisual,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );

                          // Wrap per layout: equal -> Expanded, proportional -> SizedBox with width.
                          return (layout == FlexSwitchLayout.equal)
                              ? Expanded(child: segmentCell)
                              : SizedBox(
                                  width: segmentWidths[i],
                                  child: segmentCell,
                                );
                        }),
                      ),
                    ),
                  ],
                ),
              );

              // Wrap with drag detector so it participates as an ancestor in the gesture arena.
              if (widget.allowDrag && interactive && innerWidth > 0) {
                content = _DragGestureDetector(
                  child: content,
                  onDragDown: (local) => _lastDragDownLocal = local,
                  onDragCancel: () {
                    if (_dragAccepted) {
                      setState(_clearDrag);
                    } else {
                      _clearDrag();
                    }
                  },
                  onDragStart: (local) {
                    // Accept only if not thumb-only, or start over the selected segment.
                    final Offset originLocal = _lastDragDownLocal ?? local;
                    int indexFromLocal(Offset position) =>
                        (layout == FlexSwitchLayout.equal)
                        ? _indexFromDx(
                            dx: position.dx,
                            trackWidth: width,
                            segmentWidth: equalSegmentWidth,
                            padding: padding,
                          )
                        : _indexFromDxVariable(
                            dx: position.dx,
                            trackWidth: width,
                            padding: padding,
                            segmentWidths: segmentWidthsLTR,
                          );
                    final int originIndex = indexFromLocal(originLocal);
                    final int pointerIndex = indexFromLocal(local);
                    final bool startsOnSelected = originIndex == _selectedIndex;
                    _dragAccepted = !widget.thumbDragOnly || startsOnSelected;
                    if (!_dragAccepted) {
                      _lastDragIndex = null;
                      _lastDragDownLocal = null;
                      return;
                    }
                    if ((local.dy - height / 2).abs() >
                        _kTouchYDistanceThreshold) {
                      _lastDragIndex = null;
                      _lastDragDownLocal = null;
                      return;
                    }
                    final int initialDragIndex = _nearestEnabledIndex(
                      pointerIndex,
                    );
                    _lastDragIndex = initialDragIndex;
                    setState(() {
                      _thumbPressed = true;
                      if (previewOnDrag) {
                        _highlightedIndex = initialDragIndex;
                      }
                    });
                    if (!previewOnDrag) {
                      final value = widget.options[initialDragIndex].value;
                      if (value != widget.selectedValue) {
                        _announceAndChange(value);
                      }
                    }
                    _lastDragDownLocal = null;
                  },
                  onDragEnd: () {
                    if (!_dragAccepted) return;
                    final int? commitIndex = previewOnDrag
                        ? (_highlightedIndex ?? _lastDragIndex)
                        : null;
                    setState(_clearDrag);
                    if (commitIndex != null &&
                        commitIndex >= 0 &&
                        commitIndex < widget.options.length &&
                        commitIndex != _selectedIndex) {
                      _announceAndChange(widget.options[commitIndex].value);
                    }
                  },
                  onDragUpdate: (local) {
                    if (!_dragAccepted) return;
                    // Vertical slop guard (cancel preview while out-of-band).
                    final midY = height / 2;
                    if ((local.dy - midY).abs() > _kTouchYDistanceThreshold) {
                      if (previewOnDrag && _highlightedIndex != null) {
                        setState(() => _highlightedIndex = null);
                      }
                      _lastDragIndex = null;
                      _lastDragDownLocal = null;
                      return;
                    }
                    final int rawIndex = (layout == FlexSwitchLayout.equal)
                        ? _indexFromDx(
                            dx: local.dx,
                            trackWidth: width,
                            segmentWidth: equalSegmentWidth,
                            padding: padding,
                          )
                        : _indexFromDxVariable(
                            dx: local.dx,
                            trackWidth: width,
                            padding: padding,
                            segmentWidths: segmentWidthsLTR,
                          );
                    final index = _nearestEnabledIndex(rawIndex);
                    _lastDragIndex = index;
                    if (previewOnDrag) {
                      if (_highlightedIndex != index) {
                        setState(() => _highlightedIndex = index);
                      }
                    } else {
                      final value = widget.options[index].value;
                      if (value != widget.selectedValue) {
                        _announceAndChange(value);
                      }
                    }
                  },
                );
              }

              // Outer clip + hover overlay
              content = ClipRRect(
                borderRadius: BorderRadius.circular(style.borderRadius),
                child: Stack(
                  children: [
                    content,
                    if (style.enableTrackHoverOverlay &&
                        _hovering &&
                        !widget.disabled)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.03,
                                  ),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: trackRadius,
                            border: style.focusRingWidth > 0
                                ? Border.all(
                                    color: _focused
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: 0.35,
                                          )
                                        : Colors.transparent,
                                    width: style.focusRingWidth,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height,
                  minWidth: hasWidth ? 0 : width,
                ),
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Ink for a full-width hit target whose ink/overlay is inset horizontally.
/// The insets can differ per edge so the overlay matches the thumb even when
/// the outer track edges keep full padding.
class _SegmentInkWell extends InkResponse {
  const _SegmentInkWell({
    required this.leftInset,
    required this.rightInset,
    required Widget super.child,
    super.onTap,
    super.onHighlightChanged,
    super.overlayColor,
    super.splashColor,
    super.splashFactory,
    super.borderRadius,
    super.canRequestFocus,
  }) : super(containedInkWell: true, highlightShape: BoxShape.rectangle);

  /// Horizontal inset (logical px) applied from the left edge.
  final double leftInset;

  /// Horizontal inset (logical px) applied from the right edge.
  final double rightInset;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () {
      final size = referenceBox.size;
      final double clampedLeft = leftInset.clamp(0.0, size.width);
      final double clampedRight = rightInset
          .clamp(0.0, math.max(0.0, size.width - clampedLeft))
          .toDouble();
      final double width = math.max(0, size.width - clampedLeft - clampedRight);
      return Offset(clampedLeft, 0) & Size(width, size.height);
    };
  }
}

/// Internal: draws the track background and border.
class _TrackDecoration extends StatelessWidget {
  const _TrackDecoration({
    required this.radius,
    required this.color,
    this.border,
  });

  final BorderRadius radius;
  final Color color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
          border: border,
        ),
      ),
    );
  }
}

/// Internal: horizontal drag recognizer across the whole control.
class _DragGestureDetector extends StatelessWidget {
  const _DragGestureDetector({
    required this.child,
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragCancel,
    this.onDragDown,
  });

  final Widget child;

  /// Local pointer position within the control.
  final void Function(Offset localPosition) onDragUpdate;
  final void Function(Offset localPosition) onDragStart;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;
  final void Function(Offset localPosition)? onDragDown;

  @override
  Widget build(BuildContext context) {
    // An accepted Flutter drag reports onEnd for PointerCancelEvent too.
    // Clear preview before the recognizer sees that event so it cannot commit.
    return Listener(
      onPointerCancel: (_) => onDragCancel(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragDown: onDragDown == null
            ? null
            : (d) => onDragDown!(d.localPosition),
        onHorizontalDragStart: (d) => onDragStart(d.localPosition),
        onHorizontalDragCancel: onDragCancel,
        onHorizontalDragEnd: (_) => onDragEnd(),
        onHorizontalDragUpdate: (d) => onDragUpdate(d.localPosition),
        child: child,
      ),
    );
  }
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.delta);

  final int delta;
}

class _MoveToIntent extends Intent {
  const _MoveToIntent(this.index);

  // -1 means last
  final int index;
}
