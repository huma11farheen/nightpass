import 'package:clubship/widgets/back_button.dart';
import 'dart:async';
import 'dart:io';

import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/supabase_models/gender.dart';
import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/my_page/my_page_state.dart';
import 'package:clubship/my_page/my_page_view_model.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final updateDetailsProvider =
    StateNotifierProvider<MyPageViewModel, MyPageState>(
  (ref) => MyPageViewModel(
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class AccountUpdatePage extends ConsumerStatefulWidget {
  const AccountUpdatePage({super.key, required this.user});

  final UserProfile? user;

  @override
  ConsumerState<AccountUpdatePage> createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends ConsumerState<AccountUpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Gender? _selectedGender;
  Timer? _debounce;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.user?.gender;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Brutal.elevated,
          border: Border(top: BorderSide(color: Brutal.hairlineColor)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3,
                color: Brutal.mute,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'UPLOAD PHOTO',
              style: Brutal.label(size: 12, color: Brutal.mute),
            ),
            const SizedBox(height: 16),
            _ImageSourceOption(
              icon: Icons.camera_alt_outlined,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 1),
            _ImageSourceOption(
              icon: Icons.photo_library_outlined,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final viewModel = ref.read(updateDetailsProvider.notifier);
      final imageUrl = await viewModel.userRepository.uploadToCloudinary(
        File(pickedFile.path),
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      viewModel.updateProfileImage(imageUrl);

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await viewModel.userRepository.updateUserProfile(
          userId: userId,
          profileImageUrl: imageUrl,
        );
      }

      setState(() {
        _uploadedImageUrl = imageUrl;
      });

      ref.invalidate(getUserDetailProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated'),
            backgroundColor: Brutal.elevated,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _checkUsernameAvailability(String username) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (username.isEmpty || username == widget.user?.username) return;

      final viewModel = ref.read(updateDetailsProvider.notifier);
      final isAvailable = await viewModel.checkUsernameAvailability(username);

      if (!isAvailable && mounted) {
        _showUsernameUnavailableDialog();
      }
    });
  }

  void _showUsernameUnavailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Brutal.elevated,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Brutal.magenta, size: 20),
            const SizedBox(width: 10),
            Text('USERNAME TAKEN', style: Brutal.label(size: 12, color: Brutal.paper)),
          ],
        ),
        content: Text(
          'This username is already in use. Please choose a different one.',
          style: Brutal.body(size: 15, color: Brutal.dim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: Brutal.label(size: 12, color: Brutal.magenta)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(updateDetailsProvider.notifier);

    return Scaffold(
      backgroundColor: Brutal.bg,
      appBar: AppBar(
        backgroundColor: Brutal.bg,
        elevation: 0,
        leading: const AppBackButton(forAppBar: true),
        title: Text('Account Settings', style: Brutal.display(size: 20, color: Brutal.paper)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Brutal.hairlineColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Brutal.elevated,
                      border: Brutal.neon(),
                      image: (_uploadedImageUrl ?? widget.user?.image) != null
                          ? DecorationImage(
                              image: NetworkImage(_uploadedImageUrl ?? widget.user!.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (_uploadedImageUrl ?? widget.user?.image) == null
                        ? const Icon(Icons.person, size: 40, color: Brutal.mute)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _showImageSourceDialog,
                      child: Container(
                        width: 28,
                        height: 28,
                        color: _isUploadingImage ? Brutal.hover : Brutal.magenta,
                        child: _isUploadingImage
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Brutal.paper),
                                ),
                              )
                            : const Icon(Icons.camera_alt, color: Brutal.paper, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Section header
            _SectionLabel('Personal Information'),
            const SizedBox(height: 16),

            // Name field
            _FieldBlock(
              icon: Icons.person_outline,
              label: 'FULL NAME',
              child: ClubTextField(
                initialText: widget.user?.name,
                hintText: 'Enter your full name',
                onChanged: (value) => viewModel.updateName(value),
              ),
            ),
            const SizedBox(height: 1),

            // Username field
            _FieldBlock(
              icon: Icons.alternate_email,
              label: 'USERNAME',
              child: ClubTextField(
                initialText: widget.user?.username,
                hintText: 'Enter your username',
                onChanged: (value) {
                  viewModel.updateUsername(value);
                  _checkUsernameAvailability(value);
                },
              ),
            ),
            const SizedBox(height: 1),

            // Email (read-only)
            _FieldBlock(
              icon: Icons.email_outlined,
              label: 'EMAIL ADDRESS',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                color: Brutal.card,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.user?.contactEmail ?? 'Not set',
                        style: Brutal.body(size: 16, color: Brutal.dim),
                      ),
                    ),
                    Text('READ-ONLY', style: Brutal.label(size: 10, color: Brutal.mute)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 1),

            // Gender
            _FieldBlock(
              icon: Icons.wc_outlined,
              label: 'GENDER',
              child: Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      icon: Icons.male,
                      label: 'Male',
                      isSelected: _selectedGender == Gender.male,
                      onTap: () {
                        setState(() => _selectedGender = Gender.male);
                        viewModel.updateGender(Gender.male);
                      },
                    ),
                  ),
                  const SizedBox(width: 1),
                  Expanded(
                    child: _GenderButton(
                      icon: Icons.female,
                      label: 'Female',
                      isSelected: _selectedGender == Gender.female,
                      onTap: () {
                        setState(() => _selectedGender = Gender.female);
                        viewModel.updateGender(Gender.female);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            AppButton.primary(
              onPressed: () async {
                final userId = supabase.auth.currentUser?.id;
                if (userId == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User not logged in'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                try {
                  await viewModel.updateUserProfile(userId);
                  ref.invalidate(getUserDetailProvider);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Brutal.elevated,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating profile: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              text: 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 2, height: 12, color: Brutal.magenta),
        const SizedBox(width: 10),
        Text(text.toUpperCase(), style: Brutal.label(size: 11, color: Brutal.dim)),
      ],
    );
  }
}

// ─── Field block ──────────────────────────────────────────────────────────────

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.icon, required this.label, required this.child});

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Brutal.magenta, size: 14),
              const SizedBox(width: 8),
              Text(label, style: Brutal.label(size: 10, color: Brutal.mute)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Gender button ────────────────────────────────────────────────────────────

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Brutal.bg : Brutal.card,
          border: isSelected
              ? Border.all(color: Brutal.magenta, width: 2)
              : Border.all(color: Brutal.hairlineColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Brutal.magenta : Brutal.mute, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: Brutal.body(size: 16, color: isSelected ? Brutal.magenta : Brutal.dim),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image source option ──────────────────────────────────────────────────────

class _ImageSourceOption extends StatelessWidget {
  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Brutal.card,
          border: Border.all(color: Brutal.hairlineColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              color: Brutal.elevated,
              child: Icon(icon, color: Brutal.magenta, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: Brutal.body(size: 17, color: Brutal.paper)),
            ),
            const Icon(Icons.arrow_forward_ios, color: Brutal.mute, size: 14),
          ],
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
