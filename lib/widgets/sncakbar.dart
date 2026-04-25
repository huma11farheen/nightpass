import 'package:flutter/material.dart';

extension NomuSnackbar on BuildContext {
  void showSnackbar({required String message}) {
    NomuSnackbarTrigger.of(this).show(message: message);
  }
}

class NomuSnackbarTrigger {
  NomuSnackbarTrigger({required this.messenger});

  final ScaffoldMessengerState messenger;

  static NomuSnackbarTrigger of(BuildContext context) =>
      NomuSnackbarTrigger(messenger: ScaffoldMessenger.of(context));

  void show({required String message}) {
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
