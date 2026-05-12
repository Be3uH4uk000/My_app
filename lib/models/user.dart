class UserProfile {
  final int id;
  final String name;
  final String status;
  final String avatar;

  const UserProfile({
    required this.id,
    required this.name,
    required this.status,
    required this.avatar,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int,
      name: map['name'] as String,
      status: map['status'] as String,
      avatar: map['avatar'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'avatar': avatar,
    };
  }
}
