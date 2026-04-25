import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:clubship/sign_up/signup_state.dart';
import 'package:clubship/utils/supabase_functions.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  UserRepository(this.supabase);

  final SupabaseClient supabase;

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<SignInResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return SignInResult.success;
    } on AuthException catch (e) {
      debugPrint('Sign-in error: ${e.message}, Status Code: ${e.statusCode}');

      switch (e.message) {
        case 'Invalid login credentials':
          return SignInResult.invalidCredentials;
        case 'Email not confirmed':
          return SignInResult.emailNotConfirmed;
        case 'User not found':
          return SignInResult.userNotFound;
        case 'Password should be at least 6 characters':
          return SignInResult.weakPassword;
        case 'Sign-ins not allowed':
          return SignInResult.signInNotAllowed;
        case 'Network error':
          return SignInResult.networkError;
        default:
          return SignInResult.authError;
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return SignInResult.unknownError;
    }
  }

  Future<UserProfile?> getUserDetail() async {
    final response = await supabase
        .from(UserProfile.modelName)
        .select('*')
        .eq('id', supabase.auth.currentUser?.id ?? '') // Ensure non-null id
        .maybeSingle()
        .withConverter(
          (data) => data != null ? UserProfile.fromJson(data) : null,
        );
    return response;
  }

  Future<bool> sendTicket(
      {required String ticketId,
      required String receiverId,
      required bool isEventTicket}) async {
    try {
      await SupabaseFunctions.of(supabase).invoke('send-ticket', body: {
        'ticketId': ticketId,
        'receiverId': receiverId,
        'isEventTicket': isEventTicket
      });
      return true;
    } catch (e) {
      debugPrint('Error sending ticket: $e');
      return false;
    }
  }

  Future<bool> validUserName({
    required String username,
  }) async {
    final response = await supabase
        .from(UserProfile.modelName)
        .select('*')
        .eq('username', username) // Ensure non-null id
        .maybeSingle()
        .withConverter(
          (data) => data != null ? UserProfile.fromJson(data) : null,
        );
    return response == null;
  }

  Future<List<UserProfile>> searchUsers(String searchQuery) async {
    if (searchQuery.isEmpty) return []; // Prevent empty searches
    try {
      final response = await supabase
          .from(UserProfile.modelName) // Replace with your table name
          .select('*')
          .or('contact_email.ilike.%$searchQuery%,name.ilike.%$searchQuery%,username.ilike.%$searchQuery%')
          .withConverter((data) => data.map(UserProfile.fromJson).toList());

      if (response.isEmpty) {
        debugPrint('No users found for: $searchQuery');
      } else {
        debugPrint('Users found: ${response.length}');
      }

      return response;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  Future<SignUpResult> signUpWithEmailAndPassword(SignUpState profile) async {
    try {
      final result = await supabase.auth.signUp(
        email: profile.email,
        password: profile.password!,
      );

      if (result.user == null) {
        return SignUpResult.unknownError;
      }

      debugPrint('Auth user created: ${result.user?.id}');
      debugPrint('Identities: ${result.user?.identities}');

      if (result.user?.identities?.isEmpty ?? false) {
        return SignUpResult.userAlreadyRegistered;
      }

      // Create user profile in database
      try {
        await createProfile(profile, result.user?.id ?? '');
        debugPrint('Profile created successfully');
      } catch (e) {
        debugPrint('Error creating profile: $e');
        // Delete the auth user if profile creation fails
        await supabase.auth.signOut();
        return SignUpResult.unknownError;
      }

      return SignUpResult.success;
    } on AuthException catch (e) {
      debugPrint('Sign-up error: ${e.message}, Status Code: ${e.statusCode}');

      if (e.statusCode == '400') {
        if (e.message.contains('invalid format')) {
          return SignUpResult.invalidEmail;
        }
      } else if (e.statusCode == '422') {
        if (e.message.contains('Password should be at least 6 characters')) {
          return SignUpResult.weakPassword;
        } else if (e.message.contains('User already registered')) {
          return SignUpResult.userAlreadyRegistered;
        }
        return SignUpResult.weakPassword;
      } else if (e.statusCode == '401') {
        return SignUpResult.unauthorized;
      } else if (e.statusCode == '429') {
        return SignUpResult.tooManyRequests;
      } else if (e.statusCode == '500') {
        return SignUpResult.serverError;
      } else if (e.message.contains('network error')) {
        return SignUpResult.networkError;
      }

      return SignUpResult.authError;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return SignUpResult.unknownError;
    }
  }

  Future<void> createProfile(SignUpState profile, String id) async {
    String? image;
    if (profile.image != null) {
      image = await uploadToCloudinary(profile.image!);
    }

    await supabase.from(UserProfile.modelName).insert({
      'id': id,
      'name': profile.name,
      'username': profile.userName,
      'contact_email': profile.email,
      'image': image,
      'gender': profile.gender?.name
    });
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    // Initialize the Cloudinary client
    final cloudinary = Cloudinary.signedConfig(
      apiKey: '577749947767985',
      apiSecret: 'OOUnHhfnTrFQ5tKDZzn7veU2u0E',
      cloudName: 'dhwmo32qg',
    );

    try {
      // Upload the image to Cloudinary
      final response = await cloudinary.upload(
        file: imageFile.path, // Local file path
        fileBytes: await imageFile.readAsBytes(), // File bytes (optional)
        resourceType: CloudinaryResourceType.image,
        folder: 'uploads', // Optional folder in your Cloudinary account
      );

      if (response.isSuccessful) {
        return response.secureUrl;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> resendVerifyEmail(String email) async {
    try {
      supabase.auth.resend(
        email: email,
        type: OtpType.signup,
      );
    } catch (e) {
      throw Exception('Failed to resend verify email');
    }
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    return sendOtpForPasswordReset(email: email);
  }

  Future<String?> sendOtpForPasswordReset({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to send code. Please try again.';
    }
  }

  Future<String?> verifyOtp({required String email, required String otp}) async {
    try {
      await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Invalid code. Please try again.';
    }
  }

  Future<String?> updatePassword({required String newPassword}) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to update password. Please try again.';
    }
  }

  String? get currentUser {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.id;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? username,
    String? gender,
    String? profileImageUrl,
  }) async {
    final Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (username != null) updates['username'] = username;
    if (gender != null) updates['gender'] = gender;
    if (profileImageUrl != null) updates['image'] = profileImageUrl;

    if (updates.isEmpty) return;

    await supabase.from(UserProfile.modelName).update(updates).eq('id', userId);
  }
}

enum SignUpResult {
  success,
  invalidEmail,
  weakPassword,
  userAlreadyRegistered,
  unauthorized,
  tooManyRequests,
  serverError,
  networkError,
  authError,
  unknownError,
}

enum SignInResult {
  success,
  invalidCredentials,
  emailNotConfirmed,
  userNotFound,
  weakPassword,
  signInNotAllowed,
  networkError,
  authError,
  unknownError,
}

extension SignUpResultName on SignUpResult {
  String get label {
    switch (this) {
      case SignUpResult.success:
        return 'Success';
      case SignUpResult.invalidEmail:
        return 'Invalid Email';
      case SignUpResult.weakPassword:
        return 'Weak Password';
      case SignUpResult.userAlreadyRegistered:
        return 'User Already Registered';
      case SignUpResult.unauthorized:
        return 'Unauthorized Access';
      case SignUpResult.tooManyRequests:
        return 'Too Many Requests';
      case SignUpResult.serverError:
        return 'Server Error';
      case SignUpResult.networkError:
        return 'Network Error';
      case SignUpResult.authError:
        return 'Authentication Error';
      case SignUpResult.unknownError:
        return 'Unknown Error';
    }
  }

  String get description {
    switch (this) {
      case SignUpResult.success:
        return 'Your account has been successfully created.';
      case SignUpResult.invalidEmail:
        return 'Please enter a valid email address.';
      case SignUpResult.weakPassword:
        return 'Your password is too weak. Please choose a stronger one.';
      case SignUpResult.userAlreadyRegistered:
        return 'This email is already registered. Please log in.';
      case SignUpResult.unauthorized:
        return 'You do not have permission to perform this action.';
      case SignUpResult.tooManyRequests:
        return 'Too many attempts. Please try again later.';
      case SignUpResult.serverError:
        return 'A server error occurred. Please try again later.';
      case SignUpResult.networkError:
        return 'Please check your internet connection and try again.';
      case SignUpResult.authError:
        return 'Authentication failed. Please try again.';
      case SignUpResult.unknownError:
        return 'An unknown error occurred. Please try again.';
    }
  }
}

extension SignInResultName on SignInResult {
  String get label {
    switch (this) {
      case SignInResult.success:
        return 'Success';
      case SignInResult.invalidCredentials:
        return 'Invalid Credentials';
      case SignInResult.emailNotConfirmed:
        return 'Email Not Confirmed';
      case SignInResult.userNotFound:
        return 'User Not Found';
      case SignInResult.weakPassword:
        return 'Weak Password';
      case SignInResult.signInNotAllowed:
        return 'Sign-In Not Allowed';
      case SignInResult.networkError:
        return 'Network Error';
      case SignInResult.authError:
        return 'Authentication Error';
      case SignInResult.unknownError:
        return 'Unknown Error';
    }
  }

  String get description {
    switch (this) {
      case SignInResult.success:
        return 'You have signed in successfully.';
      case SignInResult.invalidCredentials:
        return 'The email or password you entered is incorrect.';
      case SignInResult.emailNotConfirmed:
        return 'Please confirm your email before signing in.';
      case SignInResult.userNotFound:
        return 'No account found with this email address.';
      case SignInResult.weakPassword:
        return 'Your password is too weak. Please reset or try another.';
      case SignInResult.signInNotAllowed:
        return 'Sign-in is currently disabled for this account.';
      case SignInResult.networkError:
        return 'Unable to connect. Please check your internet connection.';
      case SignInResult.authError:
        return 'Authentication failed. Please try again.';
      case SignInResult.unknownError:
        return 'An unknown error occurred. Please try again later.';
    }
  }
}
