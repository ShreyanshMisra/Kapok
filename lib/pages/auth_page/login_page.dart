import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/auth_page/sign_up_page.dart';
import 'package:kapok_new/theme/app_theme.dart';
import 'package:translator/translator.dart';
import '../../controllers/authentication_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controllerAuth = AuthenticationController.authController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();

  String _loginLabel = 'Login';
  String _emailLabel = 'Email';
  String _passwordLabel = 'Password';
  String _createAccountLabel = 'Create Account';
  bool _isTranslated = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('A field is empty. Please fill out all fields.');
      return;
    }

    try {
      await controllerAuth.loginUser(email, password);
    } catch (e) {
      _showSnackBar('Login failed: $e');
    }
  }

  Future<void> _translateTexts() async {
    if (_isTranslated) {
      setState(() {
        _loginLabel = 'Login';
        _emailLabel = 'Email';
        _passwordLabel = 'Password';
        _createAccountLabel = 'Create Account';
        _isTranslated = false;
      });
      return;
    }

    final loginEs = await _translator.translate(_loginLabel, to: 'es');
    final emailEs = await _translator.translate(_emailLabel, to: 'es');
    final passwordEs = await _translator.translate(_passwordLabel, to: 'es');
    final createAccountEs =
        await _translator.translate(_createAccountLabel, to: 'es');

    setState(() {
      _loginLabel = loginEs.text;
      _emailLabel = emailEs.text;
      _passwordLabel = passwordEs.text;
      _createAccountLabel = createAccountEs.text;
      _isTranslated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFF083677),
=======
      backgroundColor: theme.primaryColor, // #013576
>>>>>>> 2bb0241 (Fixed formatting)
      body: Column(
        children: [
          Expanded(
            flex: 1,
<<<<<<< HEAD
            child: Container(
              color: const Color(0xFF083677),
              child: Center(
                // temporary image provider until we add into assets
                child: Image.asset('assets/images/logo.png'),
=======
            child: Center(
              child: Image.network(
                'https://images.squarespace-cdn.com/content/v1/545e4c9ce4b016683bd50935/1631996083297-WIGHQU6ASS2LCXGY4ULC/ATT00001.jpg?format=750w',
                fit: BoxFit.contain,
>>>>>>> 2bb0241 (Fixed formatting)
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor, // gray bg
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      _loginLabel,
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: 32),

<<<<<<< HEAD
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF083677),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
=======
                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: _emailLabel,
                        prefixIcon:
                            Icon(Icons.email, color: theme.primaryColor),
                        border: OutlineInputBorder(
>>>>>>> 2bb0241 (Fixed formatting)
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: _passwordLabel,
                        prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

<<<<<<< HEAD
                  TextButton(
                    onPressed: () {
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()), // redirect to signup page
                      );*/
                    },
                    child: GestureDetector(
                        child: Text(
                          _createAccountLabel,
                          style: const TextStyle(
                            color: Color(0xFF083677),
                            fontSize: 16,
                          ),
                        ),
                        onTap: (){
                          Get.to(SignUpPage());
                        }
=======
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        child: Text(_loginLabel),
                      ),
>>>>>>> 2bb0241 (Fixed formatting)
                    ),

                    const SizedBox(height: 16),

                    // Sign Up Link
                    TextButton(
                      onPressed: () {
                        Get.to(() => const SignUpPage());
                      },
                      child: Text(
                        _createAccountLabel,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Translation Button
      floatingActionButton: FloatingActionButton(
        onPressed: _translateTexts,
        backgroundColor: Colors.white,
        child: const Icon(Icons.translate, color: Colors.black87),
      ),
    );
  }
}
