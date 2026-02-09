import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kapok_app/core/constants/terms_of_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../core/enums/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Sign up page for user registration
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _tosAgreed = false;
  
  // Use enum values directly to ensure consistency
  String _selectedAccountType = UserRole.teamMember.value; // 'teamMember'
  String _selectedRole = 'Other';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context).createAccount),
        actions: const [KapokLogo()],
        titleTextStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AuthAuthenticated) {
              // TODO: Navigate to home page
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Account type dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountType,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).accountType,
                      prefixIcon: const Icon(Icons.group_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                    items: () {
                      final localizations = AppLocalizations.of(context);
                      // Use enum values directly to ensure they match what UserRole.fromString expects
                      final accountTypes = [
                        {'value': UserRole.teamMember.value, 'label': localizations.teamMember},
                        {'value': UserRole.teamLeader.value, 'label': localizations.teamLeader},
                        {'value': UserRole.admin.value, 'label': localizations.admin},
                      ];
                      return accountTypes.map((Map<String, String> type) {
                        return DropdownMenuItem(
                          value: type['value'],
                          child: Text(type['label']!),
                        );
                      }).toList();
                    }(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountType = value!;
                      });
                    },
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
                        borderSide: BorderSide(color: theme.colorScheme.primary),
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
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return AppLocalizations.of(context).passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign up button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
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
                                AppLocalizations.of(context).createAccount,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms of Service button
                  Center(
                    child: TextButton(
                      onPressed: _showTermsOfServiceDialog,
                      child: Text(
                        AppLocalizations.of(context).viewTermsOfService,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // Terms and conditions
                  Text(
                    AppLocalizations.of(context).byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle sign up form submission
  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_tosAgreed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pleaseAgreeToTheTermsOfServiceToContinue),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
        SignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          accountType: _selectedAccountType,
          role: _selectedRole,
        ),
      );
    }
  }

  /// Show Terms of Service dialog
  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool agreed = false;
        final dialogTheme = Theme.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogTheme.dialogBackgroundColor,
              title: Row(
                children: [
                  Icon(Icons.description, color: dialogTheme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).termsOfService,
                    style: TextStyle(color: dialogTheme.colorScheme.onSurface),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).pleaseReadAndAgreeToTheFollowingTerms,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: dialogTheme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Terms content in a scrollable container
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dialogTheme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: dialogTheme.colorScheme.surfaceContainerHighest,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          TermsOfService.content,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: dialogTheme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Checkbox for agreement
                    Row(
                      children: [
                        Checkbox(
                          value: agreed,
                          onChanged: (value) {
                            setDialogState(() {
                              agreed = value ?? false;
                            });
                          },
                          activeColor: dialogTheme.colorScheme.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                agreed = !agreed;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context).iHaveReadAndAgreeToTheTermsOfService,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: dialogTheme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context).cancel,
                    style: TextStyle(color: dialogTheme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                ElevatedButton(
                  onPressed: agreed
                      ? () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _tosAgreed = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context).termsOfServiceAccepted),
                              backgroundColor: dialogTheme.colorScheme.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dialogTheme.colorScheme.primary,
                    foregroundColor: dialogTheme.colorScheme.onPrimary,
                  ),
                  child: Text(AppLocalizations.of(context).iAgree),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
