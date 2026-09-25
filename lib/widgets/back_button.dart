import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Standard back button used across all screens.
///
/// - As [AppBar.leading]: wraps itself in the standard Brutal square container.
/// - Inline in a custom header Row: renders as a plain icon hit-target.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.forAppBar = false});

  final VoidCallback? onPressed;

  /// Set true when used as AppBar.leading — adds the square container frame.
  final bool forAppBar;

  @override
  Widget build(BuildContext context) {
    final icon = GestureDetector(
      onTap: onPressed ?? () => context.pop(),
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.arrow_back_ios, color: Brutal.paper, size: 18),
      ),
    );

    if (!forAppBar) return icon;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Brutal.paper, size: 18),
        onPressed: onPressed ?? () => context.pop(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
