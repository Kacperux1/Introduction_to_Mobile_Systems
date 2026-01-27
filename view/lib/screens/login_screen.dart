import 'package:flutter/material.dart';
import 'package:view/screens/loading_screen.dart';
import 'package:view/screens/register_screen.dart';
import '../l10n_helper.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _loginPressed() async {
    FocusScope.of(context).unfocus();
    final username = _usernameController.text;
    final password = _passwordController.text;
    final s = S.of(context);

    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar(s.get('required_fields_error'));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          username: username,
          password: password,
        ),
      ),
    );

    if (result == true) {
      widget.onLoginSuccess();
    } else if (result is String && mounted) {
      _showErrorSnackBar(result);
    }
  }

  void _navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    Color labelColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);
    Color buttonBg = isHighContrast ? Colors.black : (isDefaultMode ? Colors.grey[300]! : colorScheme.secondaryContainer);
    Color buttonText = isHighContrast ? Colors.yellow : (isDefaultMode ? Colors.black : colorScheme.onSecondaryContainer);
    Color inputTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),
                Semantics(
                  label: s.get('logo_label'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      s.get('app_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Semantics(
                  label: s.get('username'),
                  child: TextFormField(
                    controller: _usernameController,
                    style: TextStyle(color: inputTextColor),
                    decoration: InputDecoration(
                      labelText: s.get('username'),
                      labelStyle: TextStyle(color: inputTextColor.withOpacity(0.7)),
                      filled: true,
                      fillColor: isHighContrast ? Colors.black : Colors.grey[300]?.withOpacity(isDarkMode || isDefaultMode ? 0.2 : 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.person, color: inputTextColor.withOpacity(0.7)),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: s.get('password'),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: inputTextColor),
                    decoration: InputDecoration(
                      labelText: s.get('password'),
                      labelStyle: TextStyle(color: inputTextColor.withOpacity(0.7)),
                      filled: true,
                      fillColor: isHighContrast ? Colors.black : Colors.grey[300]?.withOpacity(isDarkMode || isDefaultMode ? 0.2 : 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock, color: inputTextColor.withOpacity(0.7)),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _loginPressed(),
                  ),
                ),
                const SizedBox(height: 40),
                Semantics(
                  button: true,
                  label: s.get('login'),
                  onTapHint: s.get('tap_to_login'),
                  child: ElevatedButton(
                    onPressed: _loginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      foregroundColor: buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      elevation: 2,
                    ),
                    child: Text(s.get('login'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: s.get('no_account'),
                  onTapHint: s.get('tap_to_register'),
                  child: TextButton(
                    onPressed: _navigateToRegisterScreen,
                    child: Text(
                      s.get('no_account'),
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 16, 
                        decoration: TextDecoration.underline
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
