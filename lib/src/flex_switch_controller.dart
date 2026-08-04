import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';

/// Drives a FlexSwitch's visual position independently of its selected value.
///
/// Positions use logical option indices. Fractional values interpolate between
/// adjacent options, which allows a pageable control to drive the switch while
/// a swipe is in progress.
class FlexSwitchController extends ChangeNotifier {
  FlexSwitchController({double? initialPosition})
      : _position = _validate(initialPosition);

  double? _position;
  Animation<double>? _animation;

  /// The controlled visual position, or null to follow the selected value.
  double? get position => _position;

  set position(double? value) {
    final next = _validate(value);
    if (_position == next) return;
    _position = next;
    notifyListeners();
  }

  /// Returns visual positioning to the switch's selected value.
  void clear() {
    _detachAnimation();
    position = null;
  }

  /// Continuously synchronizes [position] with an external animation.
  ///
  /// Calling this again replaces the previous animation binding. Pass null to
  /// detach while retaining the most recent visual position.
  void syncWith(Animation<double>? animation) {
    if (identical(_animation, animation)) return;
    _detachAnimation();
    _animation = animation;
    if (animation == null) return;
    animation.addListener(_handleAnimationTick);
    position = animation.value;
  }

  void _handleAnimationTick() {
    final animation = _animation;
    if (animation != null) position = animation.value;
  }

  void _detachAnimation() {
    _animation?.removeListener(_handleAnimationTick);
    _animation = null;
  }

  @override
  void dispose() {
    _detachAnimation();
    super.dispose();
  }

  static double? _validate(double? value) {
    if (value != null && !value.isFinite) {
      throw ArgumentError.value(value, 'position', 'Must be finite');
    }
    return value;
  }
}
