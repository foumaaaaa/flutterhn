// TODO: Implementer le code pour presentation/screens/home/widgets/refresh_indicator_custom
// presentation/screens/home/widgets/refresh_indicator_custom.dart
import 'package:flutter/material.dart';

class RefreshIndicatorCustom extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const RefreshIndicatorCustom({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      strokeWidth: 2.5,
      displacement: 40,
      child: child,
    );
  }
}
