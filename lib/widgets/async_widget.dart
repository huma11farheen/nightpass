import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
    this.skipLoadingOnRefresh = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget? error;
  final Widget? loading;
  final bool skipLoadingOnRefresh;

  @override
  Widget build(BuildContext context) => value.when(
    skipLoadingOnRefresh: skipLoadingOnRefresh,
    data: data,
    error: (err, stack) => error ?? const SizedBox.shrink(),
    loading: () =>
    loading ?? const Center(child: CircularProgressIndicator()),
  );
}
