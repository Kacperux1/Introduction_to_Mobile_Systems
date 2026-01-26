import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:view/models/user_profile.dart';
import 'package:view/screens/edit_profile_screen.dart';
import '../l10n_helper.dart';

class YourAccountScreen extends StatefulWidget {
  final String token;
  const YourAccountScreen({super.key, required this.token});

  @override
  State<YourAccountScreen> createState() => _YourAccountScreenState();
}

class _YourAccountScreenState extends State<YourAccountScreen> {
  Future<UserProfile>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
  }

  Future<UserProfile> _fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/me'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to load profile: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load user profile.');
    }
  }

  void _navigateToEditScreen(UserProfile currentUser) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          token: widget.token,
          initialProfile: currentUser,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _userProfileFuture = _fetchUserProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('your_account'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: Center(
        child: FutureBuilder<UserProfile>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color: isDefaultMode ? Colors.white : theme.colorScheme.primary);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return _buildProfileCard(user, theme, s);
            } else {
              return Text('No user data found.', style: TextStyle(color: theme.textTheme.bodyLarge?.color));
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile user, ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

    Color cardBgColor = isHighContrast ? Colors.black : (isDefaultMode ? Colors.grey[200]! : theme.cardColor);
    Color textColor = isHighContrast ? Colors.yellow : Colors.black87;
    Color subTextColor = isHighContrast ? Colors.yellow.withOpacity(0.7) : Colors.black45;
    Color iconColor = isHighContrast ? Colors.yellow : Colors.black54;

    if (isDarkMode) {
      textColor = Colors.white;
      subTextColor = Colors.white70;
      iconColor = Colors.white;
    }

    String profileSemantics = s.locale.languageCode == 'pl'
      ? 'Twój profil. Użytkownik: ${user.login}. Email: ${user.email}. Lokalizacja: ${user.city ?? "niepodana"}, ${user.country ?? "niepodany"}.'
      : 'Your profile. Username: ${user.login}. Email: ${user.email}. Location: ${user.city ?? "not set"}, ${user.country ?? "not set"}.';

    return Semantics(
      container: true,
      label: profileSemantics,
      child: Container(
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20.0),
          border: isHighContrast ? Border.all(color: Colors.yellow, width: 2) : null,
          boxShadow: isHighContrast ? null : [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.account_circle, size: 100, color: iconColor),
            const SizedBox(height: 8.0),
            Text(
              user.login,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 24.0),
            _buildInfoTile(
              icon: Icons.email_outlined,
              label: s.get('email'),
              value: user.email,
              textColor: textColor,
              subTextColor: subTextColor,
              iconColor: iconColor,
            ),
            _buildInfoTile(
              icon: Icons.phone_outlined,
              label: s.get('number'),
              value: user.number ?? 'Not provided',
              textColor: textColor,
              subTextColor: subTextColor,
              iconColor: iconColor,
            ),
            _buildInfoTile(
              icon: Icons.public_outlined,
              label: s.get('country'),
              value: user.country ?? 'Not provided',
              textColor: textColor,
              subTextColor: subTextColor,
              iconColor: iconColor,
            ),
            _buildInfoTile(
              icon: Icons.location_city_outlined,
              label: s.get('city'),
              value: user.city ?? 'Not provided',
              textColor: textColor,
              subTextColor: subTextColor,
              iconColor: iconColor,
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Semantics(
                button: true,
                label: s.get('save_changes'),
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToEditScreen(user),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(s.get('save_changes')),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: isHighContrast ? Colors.yellow : (isDefaultMode ? Colors.black : theme.colorScheme.onSecondaryContainer),
                    backgroundColor: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white : theme.colorScheme.secondaryContainer),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subTextColor,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 30),
      title: Text(
        value,
        style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        label,
        style: TextStyle(fontSize: 14, color: subTextColor),
      ),
    );
  }
}
