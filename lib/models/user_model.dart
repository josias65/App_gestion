class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: json['created_at'] is DateTime 
          ? json['created_at'] 
          : DateTime.parse(json['created_at']),
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'role': role,
    };
  }

  // Méthode pour convertir un Map en User
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      name: map['name'],
      email: map['email'],
      avatar: map['avatar'],
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.parse(map['createdAt']),
      role: map['role'] ?? 'user',
    );
  }

  // Méthode pour convertir User en Map
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Opérateur d'égalité
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, role: $role)';
}
