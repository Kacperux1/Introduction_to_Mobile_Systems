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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAppBarButton(
              icon: SvgPicture.asset(
                'assets/icons/Book.svg',
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              onPressed: _toggleLeftMenu,
            ),
            const Text(
              'BookTrade',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            _buildAppBarButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: _toggleRightMenu,
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
                  text: 'Buy books for your studies',
                  assetPath: 'assets/icons/Book.svg',
                  isReversed: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BuyBooksScreen(isLoggedIn: widget.isLoggedIn)),
                    );
                  },
                ),
                _buildMenuOption(
                  context,
                  text: 'Sell books you no longer use',
                  assetPath: 'assets/icons/Dollar.svg',
                  isReversed: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellBooksScreen()),
                    );
                  },
                ),
                _buildMenuOption(
                  context,
                  text: 'give reviews of books',
                  assetPath: 'assets/icons/Review.svg',
                  isReversed: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReviewBooksScreen()),
                    );
                  },
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
                 _buildDrawerItem('Your Account', _navigateToYourAccount),
                 const SizedBox(height: 20),
                 _buildDrawerItem('FAQ', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()))),
                 const Spacer(),
                 ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Log out', style: TextStyle(color: Colors.white, fontSize: 20)),
                    onTap: widget.onLogout,
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
                _buildDrawerItem('Audio settings', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioSettingsScreen()))),
                const SizedBox(height: 20),
                _buildDrawerItem('Language', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen()))),
                const SizedBox(height: 20),
                _buildDrawerItem('Preferences', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesScreen()))),
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

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: isLeft ? (isOpen ? 0 : -screenWidth) : null,
      right: !isLeft ? (isOpen ? 0 : -screenWidth) : null,
      width: screenWidth * 1.0,
      child: Material(
        color: Colors.black.withOpacity(0.85),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAppBarButton({required Widget icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(6.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: icon,
      ),
    );
  }

  Widget _buildDrawerItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    {required String text, required String assetPath, required bool isReversed, required VoidCallback onTap}
  ) {
    final textWidget = Text(
      text,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      textAlign: isReversed ? TextAlign.right : TextAlign.left,
    );

    final iconWidget = Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 40,
        height: 40,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: isReversed
              ? [Expanded(child: textWidget), const SizedBox(width: 16), iconWidget]
              : [iconWidget, const SizedBox(width: 16), Expanded(child: textWidget)],
        ),
      ),
    );
  }
}
