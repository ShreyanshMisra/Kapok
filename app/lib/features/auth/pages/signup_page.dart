import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/terms_of_service.dart';
import '../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
  
  String _selectedAccountType = 'TeamMember';
  String _selectedRole = 'Other';

  // Account types and roles
  final List<String> _accountTypes = [
    'TeamMember',
    'TeamLeader',
    'Admin',
  ];

  final List<String> _roles = [
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Account'),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
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
                      labelText: 'Full Name',
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
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  // Account type dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountType,
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      prefixIcon: const Icon(Icons.group_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: _accountTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
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
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.work_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
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
                      labelText: 'Password',
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
                        borderSide: BorderSide(color: AppColors.primary),
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
                      labelText: 'Confirm Password',
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
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign up button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: (state is AuthLoading || !_tosAgreed)
                            ? null
                            : _handleSignUp,
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
                            : const Text(
                                'Create Account',
                                style: TextStyle(
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
                        'View Terms of Service',
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  // Terms and conditions
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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
            content: const Text('Please agree to the Terms of Service to continue.'),
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.description, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Terms of Service'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please read and agree to the following terms:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Terms content in a scrollable container
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.background,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          TermsOfService.content,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.6,
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
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                agreed = !agreed;
                              });
                            },
                            child: const Text(
                              'I have read and agree to the Terms of Service',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
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
                              content: const Text('Terms of Service accepted'),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                  ),
                  child: const Text('I Agree'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
