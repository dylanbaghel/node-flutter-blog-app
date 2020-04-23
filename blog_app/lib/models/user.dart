import 'package:flutter/foundation.dart';

class User {
  String id;
  String username;
  String fullName;
  DateTime cratedAt;
  String role;

  User({
    @required this.id,
    @required this.username,
    @required this.fullName,
    @required this.cratedAt,
    @required this.role,
  });
}
