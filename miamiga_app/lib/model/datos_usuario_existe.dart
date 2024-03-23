class UserExist {
  final String email;

  UserExist({required this.email});

  factory UserExist.fromMap(Map<String, dynamic> map) {
    return UserExist(
      email: map['email'] ?? '',
    );
  }
}