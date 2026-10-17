import 'package:flex_switch/flex_switch.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const FlexSwitchDemoApp());

class FlexSwitchDemoApp extends StatefulWidget {
  const FlexSwitchDemoApp({super.key});

  @override
  State<FlexSwitchDemoApp> createState() => _FlexSwitchDemoAppState();
}

class _FlexSwitchDemoAppState extends State<FlexSwitchDemoApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: FlexSwitchDemoPage(
        themeMode: _themeMode,
        onThemeModeChanged: (m) => setState(() => _themeMode = m),
      ),
    );
  }
}

class FlexSwitchDemoPage extends StatefulWidget {
  const FlexSwitchDemoPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<FlexSwitchDemoPage> createState() => _FlexSwitchDemoPageState();
}

class _FlexSwitchDemoPageState extends State<FlexSwitchDemoPage> {
  bool _disabled = false;
  bool _rtl = false;
  bool _trackHoverOverlay = true;
  double _gutter = 10;
  bool _ripple = false;
  bool _primaryRippleTint = false;
  bool _thumbDragOnly = false;
  bool _commitOnRelease = false;
  bool _proportional = false;
  bool _showDividers = true;
  bool _disableMiddle = false;

  bool _boolValue = false;
  int _step = 1;
  int _inboxTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlexSwitch Demo')),
      body: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              runSpacing: 8,
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SwitchListTile(
                  key: const ValueKey('disabled-control'),
                  title: const Text('Disabled'),
                  value: _disabled,
                  onChanged: (v) => setState(() => _disabled = v),
                ),
                SwitchListTile(
                  key: const ValueKey('rtl-control'),
                  title: const Text('Right-to-left'),
                  value: _rtl,
                  onChanged: (v) => setState(() => _rtl = v),
                ),
                SwitchListTile(
                  title: const Text('Track hover overlay'),
                  value: _trackHoverOverlay,
                  onChanged: (v) => setState(() => _trackHoverOverlay = v),
                ),
                SwitchListTile(
                  key: const ValueKey('ripple-control'),
                  title: const Text('Ripple'),
                  value: _ripple,
                  onChanged: (v) => setState(() => _ripple = v),
                ),
                SwitchListTile(
                  key: const ValueKey('ripple-tint-control'),
                  title: const Text('Primary ripple tint'),
                  subtitle: const Text('Off = neutral grey, On = brand color'),
                  value: _primaryRippleTint,
                  onChanged: (v) => setState(() => _primaryRippleTint = v),
                ),
                SwitchListTile(
                  key: const ValueKey('thumb-only-control'),
                  title: const Text('Thumb-drag-only'),
                  subtitle: const Text('Drag must start on the selected thumb'),
                  value: _thumbDragOnly,
                  onChanged: (v) => setState(() => _thumbDragOnly = v),
                ),
                SwitchListTile(
                  key: const ValueKey('release-control'),
                  title: const Text('Commit on release'),
                  subtitle: const Text(
                    'Preview while dragging, commit on lift',
                  ),
                  value: _commitOnRelease,
                  onChanged: (v) => setState(() => _commitOnRelease = v),
                ),
                SwitchListTile(
                  key: const ValueKey('proportional-control'),
                  title: const Text('Proportional widths'),
                  subtitle: const Text('Segments sized to their content'),
                  value: _proportional,
                  onChanged: (v) => setState(() => _proportional = v),
                ),
                SwitchListTile(
                  key: const ValueKey('dividers-control'),
                  title: const Text('Show dividers'),
                  value: _showDividers,
                  onChanged: (v) => setState(() => _showDividers = v),
                ),
                SwitchListTile(
                  key: const ValueKey('disable-middle-control'),
                  title: const Text('Disable middle item'),
                  value: _disableMiddle,
                  onChanged: (v) => setState(() => _disableMiddle = v),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Segment gutter'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 12,
                    divisions: 12,
                    label: _gutter.toStringAsFixed(0),
                    value: _gutter,
                    onChanged: (v) => setState(() => _gutter = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text('Boolean', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Section(
              child: FlexSwitch.boolean(
                key: const ValueKey('boolean-switch'),
                value: _boolValue,
                onChanged: (v) => setState(() => _boolValue = v),
                trueLabel: 'On',
                falseLabel: 'Off',
                trueIcon: Icons.check_rounded,
                falseIcon: Icons.close_rounded,
                disabled: _disabled,
                style: FlexSwitchStyle(
                  enableTrackHoverOverlay: _trackHoverOverlay,
                  segmentGutter: _gutter,
                  enableRipple: _ripple,
                  segmentOverlayColor: _primaryRippleTint
                      ? WidgetStateProperty.resolveWith<Color?>((states) {
                          final scheme = Theme.of(context).colorScheme;
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.transparent;
                          }
                          if (states.contains(WidgetState.pressed)) {
                            return scheme.primary.withValues(alpha: 0.10);
                          }
                          if (states.contains(WidgetState.hovered)) {
                            return scheme.primary.withValues(alpha: 0.06);
                          }
                          if (states.contains(WidgetState.focused)) {
                            return scheme.primary.withValues(alpha: 0.08);
                          }
                          return Colors.transparent;
                        })
                      : null,
                  borderRadius: 16,
                  thumbRadius: 12,
                ),
                layout: _proportional
                    ? FlexSwitchLayout.proportional
                    : FlexSwitchLayout.equal,
                dragCommitBehavior: _commitOnRelease
                    ? DragCommitBehavior.onRelease
                    : DragCommitBehavior.immediate,
                thumbDragOnly: _thumbDragOnly,
                height: 44,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Enum (ThemeMode)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Section(
              child: FlexSwitch.fromEnum<ThemeMode>(
                key: const ValueKey('theme-switch'),
                values: ThemeMode.values,
                selectedValue: widget.themeMode,
                onChanged: widget.onThemeModeChanged,
                labelBuilder: (m) => switch (m) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                },
                iconBuilder: (m) => switch (m) {
                  ThemeMode.system => Icons.brightness_auto_rounded,
                  ThemeMode.light => Icons.light_mode_rounded,
                  ThemeMode.dark => Icons.dark_mode_rounded,
                },
                activeColorBuilder: (m) => switch (m) {
                  ThemeMode.system => Theme.of(context).colorScheme.primary,
                  ThemeMode.light => Colors.amber,
                  ThemeMode.dark => Colors.lightBlueAccent,
                },
                style: FlexSwitchStyle(
                  showDividers: _showDividers,
                  dividerThickness: 1,
                  enableTrackHoverOverlay: _trackHoverOverlay,
                  segmentGutter: _gutter,
                  enableRipple: _ripple,
                  segmentOverlayColor: _primaryRippleTint
                      ? WidgetStateProperty.resolveWith<Color?>((states) {
                          final scheme = Theme.of(context).colorScheme;
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.transparent;
                          }
                          if (states.contains(WidgetState.pressed)) {
                            return scheme.primary.withValues(alpha: 0.10);
                          }
                          if (states.contains(WidgetState.hovered)) {
                            return scheme.primary.withValues(alpha: 0.06);
                          }
                          if (states.contains(WidgetState.focused)) {
                            return scheme.primary.withValues(alpha: 0.08);
                          }
                          return Colors.transparent;
                        })
                      : null,
                  borderRadius: 16,
                  thumbRadius: 12,
                ),
                disabled: _disabled,
                layout: _proportional
                    ? FlexSwitchLayout.proportional
                    : FlexSwitchLayout.equal,
                dragCommitBehavior: _commitOnRelease
                    ? DragCommitBehavior.onRelease
                    : DragCommitBehavior.immediate,
                thumbDragOnly: _thumbDragOnly,
                height: 48,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Custom options (steps)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Section(
              child: Builder(
                builder: (context) {
                  final options = <SwitchOption<int>>[
                    const SwitchOption<int>(
                      value: 0,
                      label: 'One',
                      icon: Icons.filter_1_rounded,
                    ),
                    SwitchOption<int>(
                      value: 1,
                      label: 'Two',
                      icon: Icons.filter_2_rounded,
                      enabled: !_disableMiddle,
                    ),
                    const SwitchOption<int>(
                      value: 2,
                      label: 'Three',
                      icon: Icons.filter_3_rounded,
                    ),
                    const SwitchOption<int>(
                      value: 3,
                      label: 'Four',
                      icon: Icons.filter_4_rounded,
                    ),
                  ];
                  return FlexSwitch<int>(
                    key: const ValueKey('steps-switch'),
                    options: options,
                    selectedValue: _step,
                    onChanged: (v) => setState(() => _step = v),
                    style: FlexSwitchStyle(
                      showDividers: _showDividers,
                      enableTrackHoverOverlay: _trackHoverOverlay,
                      segmentGutter: _gutter,
                      enableRipple: _ripple,
                      segmentOverlayColor: _primaryRippleTint
                          ? WidgetStateProperty.resolveWith<Color?>((states) {
                              final scheme = Theme.of(context).colorScheme;
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.transparent;
                              }
                              if (states.contains(WidgetState.pressed)) {
                                return scheme.primary.withValues(alpha: 0.10);
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return scheme.primary.withValues(alpha: 0.06);
                              }
                              if (states.contains(WidgetState.focused)) {
                                return scheme.primary.withValues(alpha: 0.08);
                              }
                              return Colors.transparent;
                            })
                          : null,
                      borderRadius: 18,
                      thumbRadius: 14,
                    ),
                    disabled: _disabled,
                    height: 46,
                    layout: _proportional
                        ? FlexSwitchLayout.proportional
                        : FlexSwitchLayout.equal,
                    dragCommitBehavior: _commitOnRelease
                        ? DragCommitBehavior.onRelease
                        : DragCommitBehavior.immediate,
                    thumbDragOnly: _thumbDragOnly,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Proportional widths demo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Section(
              child: FlexSwitch.fromValues<int>(
                key: const ValueKey('inbox-switch'),
                values: const [0, 1, 2],
                label: (value) => switch (value) {
                  0 => 'All',
                  1 => 'Mentions and replies',
                  _ => 'DMs',
                },
                icon: (value) => switch (value) {
                  0 => Icons.inbox_rounded,
                  1 => Icons.alternate_email_rounded,
                  _ => Icons.mail_rounded,
                },
                selectedValue: _inboxTab,
                onChanged: (v) => setState(() => _inboxTab = v),
                layout: FlexSwitchLayout.proportional,
                dragCommitBehavior: _commitOnRelease
                    ? DragCommitBehavior.onRelease
                    : DragCommitBehavior.immediate,
                thumbDragOnly: _thumbDragOnly,
                style: FlexSwitchStyle(
                  showDividers: _showDividers,
                  enableTrackHoverOverlay: _trackHoverOverlay,
                  segmentGutter: _gutter,
                  enableRipple: _ripple,
                  borderRadius: 16,
                  thumbRadius: 12,
                ),
                disabled: _disabled,
                height: 46,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Current values',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'disabled: $_disabled, trackHover: $_trackHoverOverlay, gutter: ${_gutter.toStringAsFixed(0)}',
            ),
            Text(
              'bool: $_boolValue, themeMode: ${widget.themeMode}, step: $_step, inboxTab: $_inboxTab',
            ),
            Text(
              'thumbDragOnly: $_thumbDragOnly, onRelease: $_commitOnRelease, proportional: $_proportional, dividers: $_showDividers, disableMiddle: $_disableMiddle',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(children: [Expanded(child: child)]),
    );
  }
}
