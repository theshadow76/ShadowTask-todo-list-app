const String tableUsers = 'users';

class UserFields {
  static final List<String> values = [id, email, password];

  static const String id = '_id';
  static const String email = 'email';
  static const String password = 'password';
}

class User {
  final int? id;
  final String email;
  final String password;

  const User({this.id, required this.email, required this.password});

  User copy({int? id, String? email, String? password}) => User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password);

  static User fromJson(Map<String, Object?> json) => User(
        id: json[UserFields.id] as int?,
        email: json[UserFields.email] as String,
        password: json[UserFields.password] as String,
      );

  Map<String, Object?> toJson() => {
        UserFields.id: id,
        UserFields.email: email,
        UserFields.password: password,
      };
}
