import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/http_exception.dart' show HttpException;
import '../utils/url.dart' show BASE_URL;

class UserProvider with ChangeNotifier {
  String _id;
  String _fullName;
  String _username;
  String _imagePath;
  String _publicId;
  String _email;

  String get email {
    return _email;
  }

  String get id {
    return _id;
  }

  String get fullName {
    return _fullName;
  }

  String get username {
    return _username;
  }

  String get imagePath {
    return _imagePath;
  }

  String get publicId {
    return _publicId;
  }

  Future<void> getMe(String token) async {
    const url = "$BASE_URL/auth/me";
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    final responseData = json.decode(response.body);

    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }
    _id = responseData['data']['_id'];
    _fullName = responseData['data']['fullName'];
    _username = responseData['data']['username'];
    _email = responseData['data']['email'];
    if ((responseData['data'] as Map<String, dynamic>).containsKey('profile')) {
      print('doker');
      _imagePath = responseData['data']['profile']['imagePath'];
      _publicId = responseData['data']['profile']['publicId'];
    }
    notifyListeners();
  }

  Future<void> updateProfilePhoto(String token, {File image}) async {
    var url = "$BASE_URL/users/";
    if (image == null) {
    } else {
      url += "profile";
      final request = http.MultipartRequest('PATCH', Uri.parse(url))
        ..headers.addAll({'Authorization': 'Bearer $token'})
        ..files
            .add(await http.MultipartFile.fromPath('profileImage', image.path))
        ..fields['profileImage'] = Uri.encodeComponent(image.path);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (responseData['statusCode'] != 200) {
        throw new HttpException(responseData['message']);
      }

      _imagePath = responseData['data']['profile']['imagePath'];
      notifyListeners();
    }
  }

  Future<void> updateUserInfo(
      String token, String username, String fullName, String email) async {
    const url = "$BASE_URL/users/update";
    print(fullName);
    final response = await http.patch(url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: json.encode({
          "username": username,
          "fullName": fullName,
          "email": email,
        }));
    final responseData = json.decode(response.body);
    print(responseData);
    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }

    _username = responseData['data']['username'];
    _fullName = responseData['data']['fullName'];
    _email = responseData['data']['email'];
    notifyListeners();
  }
}
