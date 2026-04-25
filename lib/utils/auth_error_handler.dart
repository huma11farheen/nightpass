class AuthErrorHandler {
  static const String invalidCredentials = 'Invalid login credentials';

  static const String emailInUse = 'Email already registered';

  static const String weakPassword = 'Password should be at least 6 characters';

  static const String invalidCredentialsCode = 'invalid_credentials';

  static bool isAuthException(dynamic error) =>
      error.toString().contains('AuthException');

  static bool isSpecificAuthError(dynamic error, String specificMessage) {
    final errorStr = error.toString();
    return errorStr.contains('AuthException') &&
        errorStr.contains(specificMessage);
  }

  static int? getStatusCode(dynamic error) {
    final errorStr = error.toString();
    final statusCodeMatch = RegExp(r'statusCode: (\d+)').firstMatch(errorStr);
    return statusCodeMatch != null
        ? int.tryParse(statusCodeMatch.group(1)!)
        : null;
  }

  static String? getErrorCode(dynamic error) {
    final errorStr = error.toString();
    final errorCodeMatch = RegExp(r'errorCode: (\w+)').firstMatch(errorStr);
    return errorCodeMatch?.group(1);
  }

  static String? getMessage(dynamic error) {
    final errorStr = error.toString();
    final messageMatch = RegExp(r'message: (.*?),').firstMatch(errorStr);
    return messageMatch?.group(1);
  }

  static bool isInvalidCredentials(dynamic error) =>
      isSpecificAuthError(error, invalidCredentials) ||
          getErrorCode(error) == invalidCredentialsCode;

  static bool isEmailAlreadyInUse(dynamic error) =>
      isSpecificAuthError(error, emailInUse);

  static bool isWeakPassword(dynamic error) =>
      isSpecificAuthError(error, weakPassword);
}
