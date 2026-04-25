import 'package:clubship/utils/auth_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension SupabaseTimestampFormatter on String {
  /// Formats a Supabase `timestampz` string into a readable format.
  String toFormattedDate() {
    // Parse the raw timestampz string into a DateTime object
    final DateTime dateTime = DateTime.parse(this).toLocal();

    // Format the date and time as needed
    String day = DateFormat('dd').format(dateTime);
    String month = DateFormat('MMMM').format(dateTime);
    String year = DateFormat('yyyy').format(dateTime);
    String time = DateFormat('HH:mm').format(dateTime);
    String ordinalSuffix = _getOrdinalSuffix(dateTime.day);

    return '$day$ordinalSuffix $month, $year at $time';
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th'; // Special cases
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

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

extension AuthErrorExtension on Object {
  bool get isAuthException => AuthErrorHandler.isAuthException(this);

  bool get isInvalidCredentials => AuthErrorHandler.isInvalidCredentials(this);

  bool get isEmailAlreadyInUse => AuthErrorHandler.isEmailAlreadyInUse(this);

  bool get isWeakPassword => AuthErrorHandler.isWeakPassword(this);

  int? get statusCode => AuthErrorHandler.getStatusCode(this);

  String? get errorCode => AuthErrorHandler.getErrorCode(this);

  String? get errorMessage => AuthErrorHandler.getMessage(this);
}
