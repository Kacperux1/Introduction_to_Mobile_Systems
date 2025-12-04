import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:view/models/user_profile.dart';
import 'package:view/screens/edit_profile_screen.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: const Text('Your Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: FutureBuilder<UserProfile>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.white);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.yellow));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return _buildProfileCard(user);
            } else {
              return const Text('No user data found.', style: TextStyle(color: Colors.white));
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
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
          const Icon(Icons.account_circle, size: 100, color: Colors.black54),
          const SizedBox(height: 8.0),
          Text(
            user.login,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24.0),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            label: 'Number',
            value: user.number ?? 'Not provided',
          ),
          _buildInfoTile(
            icon: Icons.public_outlined,
            label: 'Country',
            value: user.country ?? 'Not provided',
          ),
          _buildInfoTile(
            icon: Icons.location_city_outlined,
            label: 'City',
            value: user.city ?? 'Not provided',
          ),
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToEditScreen(user),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Change your personal data'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54, size: 30),
      title: Text(
        value,
        style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.black45),
      ),
    );
  }
}
