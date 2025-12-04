import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  final String username;
  final String password;

  const LoadingScreen({required this.username, required this.password, super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _logoBlinkController;
  late final AnimationController _dotsController;

  final String _baseUrl = 'http://10.0.2.2:8080'; // 10.0.2.2 Android emulator

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _logoBlinkController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _performLogin());
  }

  Future<void> _performLogin() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'login': widget.username, 'password': widget.password}),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        Navigator.of(context).pop(true);
      } else {
        _handleLoginError('Invalid credentials, please try again.');
      }
    } catch (e) {
      _handleLoginError('Could not connect to the server.');
    }
  }

  void _handleLoginError(String message) {
    if (mounted) {
      Navigator.of(context).pop(message);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _logoBlinkController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_logoBlinkController),
                child: SvgPicture.asset(
                  'assets/logo/Logo.svg',
                  height: 80,
                ),
              ),
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  final angle = _rotationController.value * 2 * math.pi;
                  const radius = 80.0;
                  final bool isIcon1InFront = math.sin(angle) > 0;

                  final icon1 = _buildAnimatedIcon(
                      angle: angle,
                      radius: radius,
                      assetPath: 'assets/icons/Dollar.svg',
                      scaleFactor: 0.4);

                  final icon2 = _buildAnimatedIcon(
                      angle: angle + math.pi,
                      radius: radius,
                      assetPath: 'assets/icons/Book.svg',
                      scaleFactor: 0.4);

                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: isIcon1InFront ? [icon2, icon1] : [icon1, icon2],
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  final dotCount = (_dotsController.value * 4).floor();
                  final dots = '.' * (dotCount % 4);
                  return Text(
                    'Loading$dots',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, letterSpacing: 2.0),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(
      {required double angle,
      required double radius,
      required String assetPath,
      required double scaleFactor}) {
    final sinAngle = math.sin(angle);
    final scale = 1.0 + sinAngle * scaleFactor;
    return Transform.translate(
      offset: Offset(
        radius * math.cos(angle),
        0,
      ),
      child: Transform.scale(
        scale: scale,
        child: _buildCircleIcon(assetPath),
      ),
    );
  }

  Widget _buildCircleIcon(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 40,
        height: 40,
      ),
    );
  }
}
