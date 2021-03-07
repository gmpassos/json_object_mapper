import 'package:json_object_mapper/json_object_mapper.dart';

class User extends JSONObject {
  String? username;
  String? email;

  User.fromFields(String username, String email) {
    this.username = username;
    this.email = email;
  }

  User.fromJson(String json) {
    initializeFromJson(json);
  }

  User();

  @override
  String toString() {
    return 'User{username: $username, email: $email}';
  }
}

void main() {
  var user1 = User.fromFields('joe', 'joe@mail.com');
  print('User 1: $user1');

  var json1 = user1.toJson();

  var user2 = User.fromJson(json1);
  print('User 2: $user2');

  print('Username: ${user2.username}');
  print('Email: ${user2.email}');
}

// OUTPUT:
// User 1: User{username: joe, email: joe@mail.com}
// User 2: User{username: joe, email: joe@mail.com}
// Username: joe
// Email: joe@mail.com
