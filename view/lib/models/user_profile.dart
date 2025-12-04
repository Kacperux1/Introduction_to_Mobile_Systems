class UserProfile {
  final String login;
  final String email;
  final String? number;
  final String? country;
  final String? city;

  UserProfile({
    required this.login,
    required this.email,
    this.number,
    this.country,
    this.city,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      login: json['login'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      number: json['number'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
    );
  }
}
