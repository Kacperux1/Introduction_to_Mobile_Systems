import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buy_books_screen.dart';
import 'sell_books_screen.dart';
import 'review_books_screen.dart';
import 'your_account_screen.dart';
import 'faq_screen.dart';
import 'audio_settings_screen.dart';
import 'language_screen.dart';
import 'preferences_screen.dart';
import 'ai_recommendation_screen.dart';
import 'chat_list_screen.dart';
import '../l10n_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;
  const HomeScreen({required this.isLoggedIn, required this.onLogout, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRightMenuOpen = false;
  bool _isLeftMenuOpen = false;

  void _toggleRightMenu() {
    setState(() {
      _isRightMenuOpen = !_isRightMenuOpen;
      if (_isRightMenuOpen) _isLeftMenuOpen = false;
    });
  }

  void _toggleLeftMenu() {
    setState(() {
      _isLeftMenuOpen = !_isLeftMenuOpen;
      if (_isLeftMenuOpen) _isRightMenuOpen = false;
    });
  }

  void _closeAllMenus() {
    setState(() {
      _isRightMenuOpen = false;
      _isLeftMenuOpen = false;
    });
  }

  void _navigateToYourAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => YourAccountScreen(token: token)),
      );
    }
  }

  void _navigateToChats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && mounted) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8080/api/me'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListScreen(
                  authToken: token,
                  currentUserId: userData['id'],
                ),
              ),
            );
          }
        }
      } catch (e) {
         print("Error navigating to chats: $e");
      }
    }
  }

  void _navigateToAiRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AiRecommendationScreen(authToken: token)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: s.get('your_account'),
              onTapHint: s.get('tap_to_open_menu'),
              button: true,
              child: _buildAppBarButton(
                icon: SvgPicture.asset(
                  'assets/icons/Book.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(theme.appBarTheme.foregroundColor ?? Colors.black, BlendMode.srcIn),
                ),
                onPressed: _toggleLeftMenu,
              ),
            ),
            Text(
              s.get('app_title'),
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Semantics(
              label: s.get('preferences'),
              onTapHint: s.get('tap_to_open_menu'),
              button: true,
              child: _buildAppBarButton(
                icon: Icon(Icons.menu, color: theme.appBarTheme.foregroundColor ?? Colors.black, size: 30),
                onPressed: _toggleRightMenu,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          //Główna zawartość
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMenuOption(
                  context,
                  text: s.get('buy_books'),
                  assetPath: 'assets/icons/Book.svg',
                  isReversed: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BuyBooksScreen(isLoggedIn: widget.isLoggedIn)),
                    );
                  },
                  hint: s.get('tap_to_select'),
                ),
                _buildMenuOption(
                  context,
                  text: s.get('sell_books'),
                  assetPath: 'assets/icons/Dollar.svg',
                  isReversed: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellBooksScreen()),
                    );
                  },
                  hint: s.get('tap_to_select'),
                ),
                _buildMenuOption(
                  context,
                  text: s.get('reviews_lowercase'),
                  assetPath: 'assets/icons/Review.svg',
                  isReversed: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReviewBooksScreen()),
                    );
                  },
                  hint: s.get('tap_to_select'),
                ),
                _buildMenuOption(
                  context,
                  text: s.get('ai_recommendations'),
                  assetPath: 'assets/icons/Review.svg',
                  isReversed: false,
                  onTap: _navigateToAiRecommendations,
                  hint: s.get('tap_to_select'),
                ),
              ],
            ),
          ),

          if (_isRightMenuOpen || _isLeftMenuOpen)
            GestureDetector(
              onTap: _closeAllMenus,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          
          //Lewe Menu
          _buildSlidingMenu(
            isOpen: _isLeftMenuOpen,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildDrawerItem(s.get('your_account'), _navigateToYourAccount, s.get('tap_to_select')),
                 const SizedBox(height: 20),
                 _buildDrawerItem(s.get('chats'), _navigateToChats, s.get('tap_to_select')),
                 const SizedBox(height: 20),
                 _buildDrawerItem(s.get('ai_recommendations'), _navigateToAiRecommendations, s.get('tap_to_select')),
                 const SizedBox(height: 20),
                 _buildDrawerItem(s.get('faq'), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen())), s.get('tap_to_select')),
                 const Spacer(),
                 Semantics(
                   button: true,
                   label: s.get('logout'),
                   onTapHint: s.get('tap_to_logout'),
                   child: ListTile(
                      leading: Icon(Icons.logout, color: isDefaultMode ? Colors.white : colorScheme.onSurface),
                      title: Text(s.get('logout'), style: TextStyle(color: isDefaultMode ? Colors.white : colorScheme.onSurface, fontSize: 20)),
                      onTap: widget.onLogout,
                  ),
                 ),
              ],
            ),
          ),

          //Prawe Menu
          _buildSlidingMenu(
            isOpen: _isRightMenuOpen,
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDrawerItem(s.get('audio_settings'), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioSettingsScreen())), s.get('tap_to_select')),
                const SizedBox(height: 20),
                _buildDrawerItem(s.get('language'), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen())), s.get('tap_to_select')),
                const SizedBox(height: 20),
                _buildDrawerItem(s.get('preferences'), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesScreen())), s.get('tap_to_select')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingMenu({
    required bool isOpen,
    required Alignment alignment,
    required Widget child,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLeft = alignment == Alignment.centerLeft;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: isLeft ? (isOpen ? 0 : -screenWidth) : null,
      right: !isLeft ? (isOpen ? 0 : -screenWidth) : null,
      width: screenWidth * 0.8,
      child: Material(
        color: isDefaultMode ? Colors.black.withOpacity(0.95) : colorScheme.surface.withOpacity(0.95),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAppBarButton({required Widget icon, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(6.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.appBarTheme.foregroundColor?.withOpacity(0.1) ?? Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.appBarTheme.foregroundColor ?? Colors.white),
        ),
        child: icon,
      ),
    );
  }

  Widget _buildDrawerItem(String title, VoidCallback onTap, String hint) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    return Semantics(
      button: true,
      label: title,
      onTapHint: hint,
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(color: isDefaultMode ? Colors.white : colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    {required String text, required String assetPath, required bool isReversed, required VoidCallback onTap, required String hint}
  ) {
    final theme = Theme.of(context);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    
    Color textColor;
    if (isHighContrast) {
      textColor = Colors.yellow;
    } else if (isDarkMode) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }

    final textWidget = Text(
      text,
      style: TextStyle(color: textColor, fontSize: 18),
      textAlign: isReversed ? TextAlign.right : TextAlign.left,
    );

    final iconWidget = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isHighContrast ? Colors.yellow : Colors.black, width: 0.5),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 40,
        height: 40,
        colorFilter: ColorFilter.mode(isHighContrast ? Colors.yellow : Colors.black, BlendMode.srcIn),
      ),
    );

    return Semantics(
      button: true,
      label: text,
      onTapHint: hint,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: isDefaultMode ? const Color(0xFFE0E0E0) : theme.cardColor,
            borderRadius: BorderRadius.circular(30.0),
            border: isHighContrast ? Border.all(color: Colors.yellow, width: 2) : null,
            boxShadow: [
              if (!isHighContrast)
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: isReversed
                ? [Expanded(child: textWidget), const SizedBox(width: 16), iconWidget]
                : [iconWidget, const SizedBox(width: 16), Expanded(child: textWidget)],
          ),
        ),
      ),
    );
  }
}
