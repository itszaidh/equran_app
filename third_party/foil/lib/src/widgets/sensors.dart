/// Provides a dummy `SensorListener` without any sensor dependencies.
library foil;

import 'package:flutter/widgets.dart';

import '../models/scalar.dart';

/// A callback used to provide a parent with actionable, normalized data.
typedef SensorCallback = void Function(double normalizedX, double normalizedY);

/// A dummy widget that does not use or import sensors_plus.
class SensorListener extends StatefulWidget {
  const SensorListener({
    Key? key,
    required this.disabled,
    required this.step,
    required this.scalar,
    required this.child,
    required this.onStep,
  }) : super(key: key);

  final bool disabled;
  final Duration step;
  final Scalar scalar;
  final Widget child;
  final SensorCallback onStep;

  @override
  _SensorListenerState createState() => _SensorListenerState();
}

class _SensorListenerState extends State<SensorListener> {
  @override
  Widget build(BuildContext context) => widget.child;
}
