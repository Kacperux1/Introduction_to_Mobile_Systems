import 'package:flutter/material.dart';
import 'package:view/screens/loading_screen.dart';
import 'package:view/screens/register_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
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
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _listen(TextEditingController controller, String label) async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) => debugPrint('onStatus: $val'),
          onError: (val) => debugPrint('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              controller.text = val.recognizedWords;
            }),
          );
        }
      } else {
        _showErrorSnackBar('Microphone permission denied');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _loginPressed() async {
    FocusScope.of(context).unfocus();
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please enter username and password.');
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
                  label: 'BookTrade Logo',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      'BookTrade',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                  hint: s.get('voice_input'),
                  child: TextFormField(
                    controller: _usernameController,
                    style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black),
                    decoration: InputDecoration(
                      labelText: s.get('username'),
                      labelStyle: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black54),
                      filled: true,
                      fillColor: isHighContrast ? Colors.black : Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.person, color: isHighContrast ? Colors.yellow : Colors.black54),
                      suffixIcon: IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                             color: _isListening ? Colors.red : (isHighContrast ? Colors.yellow : Colors.black54)),
                        onPressed: () => _listen(_usernameController, s.get('username')),
                        tooltip: s.get('voice_input'),
                      ),
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
                    style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black),
                    decoration: InputDecoration(
                      labelText: s.get('password'),
                      labelStyle: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black54),
                      filled: true,
                      fillColor: isHighContrast ? Colors.black : Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock, color: isHighContrast ? Colors.yellow : Colors.black54),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _loginPressed(),
                  ),
                ),
                const SizedBox(height: 40),
                Semantics(
                  button: true,
                  label: s.get('login'),
                  onTap: _loginPressed,
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
