import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Edit profile page for updating user information
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  
  String _selectedRole = 'Other';

  // Available roles

  @override
  void initState() {
    super.initState();
    // TODO: Initialize with current user data
    _nameController.text = 'Full Name';
    _selectedRole = 'Other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).editProfile),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              AppLocalizations.of(context).save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const KapokLogo(),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).profileUpdatedSuccessfully),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile picture section
                _buildProfilePictureSection(),
                const SizedBox(height: 32),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fullName,
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                // Role dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).role,
                    prefixIcon: const Icon(Icons.work_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                    items: () {
                      final localizations = AppLocalizations.of(context);
                      final roles = [
                        {'value': 'Medical', 'label': localizations.medical},
                        {'value': 'Engineering', 'label': localizations.engineering},
                        {'value': 'Carpentry', 'label': localizations.carpentry},
                        {'value': 'Plumbing', 'label': localizations.plumbing},
                        {'value': 'Construction', 'label': localizations.construction},
                        {'value': 'Electrical', 'label': localizations.electrical},
                        {'value': 'Supplies', 'label': localizations.supplies},
                        {'value': 'Transportation', 'label': localizations.transportation},
                        {'value': 'Other', 'label': localizations.other},
                      ];
                      return roles.map((Map<String, String> role) {
                        return DropdownMenuItem(
                          value: role['value'],
                          child: Text(role['label']!),
                        );
                      }).toList();
                    }(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 32),
                
                // Save button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).saveChanges,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build profile picture section
  /// Note: Profile pictures use name initials for simplicity and offline-reliability
  /// Custom photo uploads intentionally deferred to avoid Firebase Storage dependency
  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            _nameController.text.isNotEmpty
                ? _nameController.text[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 40,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Handle save form submission
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ProfileUpdateRequested(
          name: _nameController.text.trim(),
          role: _selectedRole,
        ),
      );
    }
  }
}
