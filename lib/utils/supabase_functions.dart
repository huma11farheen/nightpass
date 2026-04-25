// A wrapper around supabase functions to unwrap errors
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFunctions  {
  SupabaseFunctions(this.supabase);

  final SupabaseClient supabase;

  Future<FunctionResponse> invoke(
      String functionName, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
        Map<String, dynamic>? queryParameters,
        HttpMethod method = HttpMethod.post,
      }) async {
    try {
      return await supabase.functions.invoke(functionName,
          headers: headers,
          body: body,
          queryParameters: queryParameters,
          method: method);
    } catch (err) {
      if (err is FunctionException) {
        throw SupabaseFunctionException(
            'Edge-function [$functionName] non-success [${err.status}]: ${err.details}',
            err.status,
            err.reasonPhrase,
            err.details);
      }
      rethrow;
    }
  }

  static SupabaseFunctions of(SupabaseClient client) =>
      SupabaseFunctions(client);
}

class SupabaseFunctionException implements Exception {
  SupabaseFunctionException(
      this.message, this.status, this.reason, this.details);

  final dynamic details;
  final String? reason;
  final int status;

  final String message;

  @override
  String toString() => message;
}
