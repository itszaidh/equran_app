import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:foil/foil.dart';
import 'package:equran/backend/library.dart';

/// A reusable wrapper widget that conditionally applies a premium holographic foil
/// shimmer effect (`Roll` + `Foil`) with `Crinkle.twinkling` and a seamless `Foils.linearRainbow`
/// gradient if the 'holographicCardsEnabled' preference is enabled in [SettingsDB].
class HolographicCardWrapper extends StatelessWidget {
  const HolographicCardWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: SettingsDB().box.listenable(
        keys: <String>['holographicCardsEnabled'],
      ),
      builder: (BuildContext context, Box<dynamic> box, _) {
        final bool enabled =
            box.get('holographicCardsEnabled', defaultValue: false) as bool;
        return enabled
            ? Roll(
                crinkle: Crinkle.twinkling,
                gradient: Foils.linearRainbow,
                child: Foil(useSensor: false, opacity: 0.15, child: child),
              )
            : child;
      },
    );
  }
}
