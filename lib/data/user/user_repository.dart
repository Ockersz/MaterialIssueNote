import 'dart:convert';

import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:mri/data/user/user_details.dart';

class UserRepository {
  static const String _boxName = 'userBox';
  final String baseURL = 'http://192.168.1.19:5000';
  static const Duration timeoutDuration = Duration(seconds: 10);

  Future<Box> init() async {
    return await Hive.openBox<UserDetails>(_boxName);
  }

  Future<UserDetails> login(String username, String password) async {
    await Hive.close();
    final userDetailsBox = await Hive.openBox(_boxName);
    final response = await http.post(
      Uri.parse('$baseURL/mobile/login'),
      body: {
        'username': username,
        'password': password,
      },
    ).timeout(timeoutDuration);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final userDetails = UserDetails.fromJson(jsonDecode(response.body));
      await userDetailsBox.put(userDetails.userId, userDetails);
      return userDetails;
    } else {
      return Future.error('Invalid username or password');
    }
  }

  Future<UserDetails> register(String username, String password) async {
    await Hive.close();
    final userDetailsBox = await Hive.openBox(_boxName);
    final response = await http.post(
      Uri.parse('$baseURL/mobile/register'),
      body: {
        'username': username,
        'password': password,
      },
    ).timeout(timeoutDuration);
    print(response.body);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final userDetails = UserDetails.fromJson(jsonDecode(response.body));
      await userDetailsBox.put(userDetails.userId, userDetails);
      return userDetails;
    } else if (response.statusCode == 403) {
      return Future.error('User already Have an account');
    } else {
      return Future.error('Invalid username or password');
    }
  }

  Future<bool> isLoggedIn() async {
    await Hive.close();
    final userDetailsBox = await Hive.openBox(_boxName);
    return userDetailsBox.isNotEmpty;
  }

  Future<void> logout() async {
    await Hive.close();
    final userDetailsBox = await Hive.openBox(_boxName);
    await userDetailsBox.clear();
  }

  Future<UserDetails> getUserDetails() async {
    final userDetailsBox = await Hive.openBox(_boxName);
    final userDetails = userDetailsBox.values.first;
    return userDetails;
  }
}
