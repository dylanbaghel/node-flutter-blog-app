import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/url.dart' show BASE_URL;
import '../utils/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  String _userId;
  String _fullName;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    return _token;
  }

  String get userId {
    return _userId;
  }

  Future<void> _saveToDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'token': _token,
      'userId': _userId,
      'fullName': _fullName,
    };

    prefs.setString("userData", json.encode(userData));
  }

  Future<void> login(String username, String password) async {
    const url = "$BASE_URL/auth/login";
    print(username);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {'username': username.trim(), 'password': password.trim()},
      ),
    );

    var responseData = json.decode(response.body) as Map<String, dynamic>;
    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }

    _token = responseData['token'];
    _userId = responseData['data']['_id'];
    _fullName = responseData['data']['fullName'];
    notifyListeners();
    _saveToDevice();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _fullName = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userData");
  }

  Future<void> register(
      String fullName, String username, String password) async {
    const url = "$BASE_URL/auth/register";
    print(username);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {
          'fullName': fullName.trim(),
          'username': username.trim(),
          'password': password.trim()
        },
      ),
    );

    var responseData = json.decode(response.body) as Map<String, dynamic>;
    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }

    _token = responseData['token'];
    _userId = responseData['data']['_id'];
    _fullName = responseData['data']['fullName'];
    notifyListeners();
    _saveToDevice();
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("userData")) {
      var userData =
          json.decode(prefs.getString("userData")) as Map<String, dynamic>;
      _fullName = userData["fullName"];
      _token = userData["token"];
      _userId = userData["userId"];
      notifyListeners();
      return true;
    }
    return false;
  }
}
