import 'package:hive/hive.dart';

part 'user_details.g.dart';

@HiveType(typeId: 0)
class UserDetails {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final String password;
  @HiveField(2)
  final String userId;

  UserDetails(
      {required this.username, required this.password, required this.userId});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      username: json['username'],
      password: json['password'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'userId': userId,
    };
  }
}
