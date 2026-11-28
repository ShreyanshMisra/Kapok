import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Edit profile page for updating the user's name and profession.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  /// Profession values stored in users/{uid}.role.
  static const _professionValues = [
    'Medical',
    'Engineering',
    'Carpentry',
    'Plumbing',
    'Construction',
    'Electrical',
    'Supplies',
    'Transportation',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedProfession = 'Other';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name;
      // The dropdown asserts if its value isn't one of the items, so map
      // anything unexpected (empty, legacy casing) onto a known value.
      _selectedProfession = _professionValues.firstWhere(
        (p) => p.toLowerCase() == authState.user.role.trim().toLowerCase(),
        orElse: () => 'Other',
      );
    }
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  String _professionLabel(AppLocalizations l, String value) {
    switch (value) {
      case 'Medical':
        return l.medical;
      case 'Engineering':
        return l.engineering;
      case 'Carpentry':
        return l.carpentry;
      case 'Plumbing':
        return l.plumbing;
      case 'Construction':
        return l.construction;
      case 'Electrical':
        return l.electrical;
      case 'Supplies':
        return l.supplies;
      case 'Transportation':
        return l.transportation;
      default:
        return l.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(localizations.editProfile),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _handleSave,
            child: Text(
              localizations.save,
              style: TextStyle(
                color: _saving ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const KapokLogo(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfilePictureSection(theme),
              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: localizations.fullName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),

              // Profession dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedProfession,
                decoration: InputDecoration(
                  labelText: localizations.profession,
                  prefixIcon: const Icon(Icons.work_outlined),
                ),
                items: _professionValues
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(_professionLabel(localizations, value)),
                        ))
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedProfession = value);
                        }
                      },
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _saving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        localizations.saveChanges,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build profile picture section
  /// Note: Profile pictures use name initials for simplicity and offline-reliability
  /// Custom photo uploads intentionally deferred to avoid Firebase Storage dependency
  Widget _buildProfilePictureSection(ThemeData theme) {
    final name = _nameController.text.trim();
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 40,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Handle save form submission
  void _handleSave() {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final localizations = AppLocalizations.of(context);

    setState(() => _saving = true);
    context.read<AuthBloc>().add(
          ProfileUpdateRequested(
            name: _nameController.text.trim(),
            role: _selectedProfession,
            onComplete: (error) {
              if (error != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: AppColors.error),
                );
                if (mounted) setState(() => _saving = false);
                return;
              }
              messenger.showSnackBar(
                SnackBar(content: Text(localizations.profileUpdatedSuccessfully)),
              );
              if (mounted) navigator.pop();
            },
          ),
        );
  }
}
