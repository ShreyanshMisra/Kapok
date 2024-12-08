import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/auth_page/sign_up_page.dart';
import 'package:kapok_new/pages/home_screens/map_page.dart';
import 'package:translator/translator.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Translator instance
  final GoogleTranslator _translator = GoogleTranslator();

  // Variables to hold UI text
  String _loginLabel = 'Login';
  String _emailLabel = 'Email';
  String _passwordLabel = 'Password';
  String _createAccountLabel = 'Create Account';

  // Tracks whether or not page is translated
  bool _isTranslated = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    String email = _emailController.text;
    String password = _passwordController.text;
    //TODO
    // Authenticate both with firebase? 

    print('Email: $email'); // for testing
    print('Password: $password'); // for testing
  }

  Future<void> _translateTexts() async {
    // If already translated, revert to English
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

    // Translate each text to Spanish
    final loginLabelEs = await _translator.translate(_loginLabel, to: 'es');
    final emailLabelEs = await _translator.translate(_emailLabel, to: 'es');
    final passwordLabelEs = await _translator.translate(_passwordLabel, to: 'es');
    final createAccountLabelEs = await _translator.translate(_createAccountLabel, to: 'es');

    // Update state with translated text
    setState(() {
      _loginLabel = loginLabelEs.text;
      _emailLabel = emailLabelEs.text;
      _passwordLabel = passwordLabelEs.text;
      _createAccountLabel = createAccountLabelEs.text;
      _isTranslated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Column(
        children: [
          // Top section for image
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF4B5499),
              child: Center(
                // temporary image provider until we add into assets
                child: Image.network('https://images.squarespace-cdn.com/content/v1/545e4c9ce4b016683bd50935/1631996083297-WIGHQU6ASS2LCXGY4ULC/ATT00001.jpg?format=750w'),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text(
                    _loginLabel,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    ),
                    onTap: (){
                      Get.to(MapPage());
                    },
                  ),
                const SizedBox(height: 50),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: _emailLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _passwordLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: GestureDetector(
                        child: Text(
                          _loginLabel,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onTap: (){
                          Get.to(MapPage());
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 16,
                        ),
                      ),
                      onTap: (){
                        Get.to(SignUpPage());
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating action button for translation, positioned at bottom right
      floatingActionButton: FloatingActionButton(
        onPressed: _translateTexts, // Translates text on the page
        backgroundColor: Colors.white,
        child: const Icon(Icons.translate),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
