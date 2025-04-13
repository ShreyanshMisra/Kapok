// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kapok_new/pages/home_screens/map_page.dart';
//
// import '../../controllers/authentication_controller.dart';
//
// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});
//
//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   var authenticationController = AuthenticationController.authController;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _handleSignUp() {
//     String name = _nameController.text;
//     String email = _emailController.text;
//     String password = _passwordController.text;
//     String confirmPassword = _confirmPasswordController.text;
//
//     if (password == confirmPassword) {
//       // TODO: Sign up with Firebase
//       print('Name: $name'); // for testing
//       print('Email: $email');
//     } else {
//       print('Passwords do not match');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Top section for image
//             Container(
//               color: const Color(0xFF4B5499),
//               height: MediaQuery.of(context).size.height * 0.3, // Adjusted to fit screen
//               child: Center(
//                 child: Image.network('https://images.squarespace-cdn.com/content/v1/545e4c9ce4b016683bd50935/1631996083297-WIGHQU6ASS2LCXGY4ULC/ATT00001.jpg?format=750w'),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Sign Up',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Full Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: 'Email Address',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _confirmPasswordController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: 'Confirm Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _handleSignUp,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.indigo,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: GestureDetector(
//                         child: Text(
//                           'Create Account',
//                           style: TextStyle(fontSize: 16, color: Colors.white),
//                         ),
//                         onTap: () async{
//                           //Get.to(const NamePage(), transition: Transition.fade, duration: const Duration(milliseconds: 400));
//                           if (_emailController.text.trim().isNotEmpty
//                               && _passwordController.text.trim().isNotEmpty
//                               && _confirmPasswordController.text.trim().isNotEmpty)
//                           {
//                             // if (!isUniversityEmail(emailTextEditingController.text.trim())) {
//                             //   ScaffoldMessenger.of(context).showSnackBar(
//                             //     SnackBar(
//                             //       content: Text(
//                             //         'Please use a valid university email address.',
//                             //         style: TextStyle(
//                             //           fontSize: height * 0.0184931506848,
//                             //           fontWeight: FontWeight.bold,
//                             //           fontFamily: 'GemunuLibreBold',
//                             //         ),
//                             //       ),
//                             //       duration: Duration(seconds: 2),
//                             //     ),
//                             //   );
//                             //   return;
//                             // }
//
//                             if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
//                               // setState(() {
//                               //   showProgressBar = true;
//                               // });
//
//                               try {
//                                 await authenticationController.createNewUserAccount(
//                                   _emailController.text.trim(),
//                                   _passwordController.text.trim(),
//                                 );
//
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Account created successfully!',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'GemunuLibreBold',
//                                       ),
//                                     ),
//                                     duration: const Duration(seconds: 2),
//                                   ),
//                                 );
//                                 Get.to(const MapPage(), transition: Transition.fade, duration: const Duration(milliseconds: 400));
//
//                               } catch (error) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Account creation failed: $error',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'GemunuLibreBold',
//                                       ),
//                                     ),
//                                     duration: const Duration(seconds: 4),
//                                   ),
//                                 );
//                               }
//                               // finally {
//                               //   setState(() {
//                               //     showProgressBar = false;
//                               //   });
//                               // }
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     'Passwords do not match. Please ensure that the passwords are the same.',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'GemunuLibreBold',
//                                     ),
//                                   ),
//                                   duration: const Duration(seconds: 2),
//                                 ),
//                               );
//                             }
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'A Field is empty. Please fill out all text fields.',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'GemunuLibreBold',
//                                   ),
//                                 ),
//                                 duration: const Duration(seconds: 2),
//                               ),
//                             );
//                           }
//                         },
//                     ),
//                   ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/home_screens/map_page.dart';
import 'package:translator/translator.dart';

import '../../controllers/authentication_controller.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  var authenticationController = AuthenticationController.authController;

  // Translator instance
  final GoogleTranslator _translator = GoogleTranslator();

  // Variables to hold UI text
  String _signUpLabel = 'Sign Up';
  String _fullNameLabel = 'Full Name';
  String _emailLabel = 'Email Address';
  String _passwordLabel = 'Password';
  String _confirmPasswordLabel = 'Confirm Password';
  String _createAccountLabel = 'Create Account';

  // Tracks whether or not page is translated
  bool _isTranslated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      // TODO: Sign up with Firebase
      print('Name: $name'); // for testing
      print('Email: $email');
    } else {
      print('Passwords do not match');
    }
  }

  Future<void> _translateTexts() async {
    // If already translated, revert to English
    if (_isTranslated) {
      setState(() {
        _signUpLabel = 'Sign Up';
        _fullNameLabel = 'Full Name';
        _emailLabel = 'Email Address';
        _passwordLabel = 'Password';
        _confirmPasswordLabel = 'Confirm Password';
        _createAccountLabel = 'Create Account';
        _isTranslated = false;
      });
      return;
    }

    // Translate each text to Spanish
    final signUpLabelEs = await _translator.translate(_signUpLabel, to: 'es');
    final fullNameLabelEs = await _translator.translate(_fullNameLabel, to: 'es');
    final emailLabelEs = await _translator.translate(_emailLabel, to: 'es');
    final passwordLabelEs = await _translator.translate(_passwordLabel, to: 'es');
    final confirmPasswordLabelEs = await _translator.translate(_confirmPasswordLabel, to: 'es');
    final createAccountLabelEs = await _translator.translate(_createAccountLabel, to: 'es');

    // Update state with translated text
    setState(() {
      _signUpLabel = signUpLabelEs.text;
      _fullNameLabel = fullNameLabelEs.text;
      _emailLabel = emailLabelEs.text;
      _passwordLabel = passwordLabelEs.text;
      _confirmPasswordLabel = confirmPasswordLabelEs.text;
      _createAccountLabel = createAccountLabelEs.text;
      _isTranslated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF083677),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section for image
            Container(
              color: const Color(0xFF083677),
              height: MediaQuery.of(context).size.height * 0.3, // Adjusted to fit screen
              child: Center(
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            Container(
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
                  Text(
                    _signUpLabel,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _fullNameLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _confirmPasswordLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF083677),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: GestureDetector(
                        child: Text(
                          _createAccountLabel,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onTap: () async{
                          //Get.to(const NamePage(), transition: Transition.fade, duration: const Duration(milliseconds: 400));
                          if (_emailController.text.trim().isNotEmpty
                              && _passwordController.text.trim().isNotEmpty
                              && _confirmPasswordController.text.trim().isNotEmpty)
                          {

                            if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {

                              try {
                                await authenticationController.createNewUserAccount(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Account created successfully!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GemunuLibreBold',
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                Get.to(const MapPage(), transition: Transition.fade, duration: const Duration(milliseconds: 400));

                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Account creation failed: $error',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GemunuLibreBold',
                                      ),
                                    ),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Passwords do not match. Please ensure that the passwords are the same.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'GemunuLibreBold',
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'A Field is empty. Please fill out all text fields.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'GemunuLibreBold',
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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