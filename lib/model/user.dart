class User {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? country;
  final String? city;
  final String userType;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.country,
    this.city,
    required this.userType,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      country: json['country'],
      city: json['city'],
      userType: json['userType'] ?? 'coder',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'country': country,
      'city': city,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}