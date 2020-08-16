import 'package:json_object_mapper/json_object_mapper.dart';
import 'package:test/test.dart';

class User extends JSONObject {
  String username;
  String email;

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
  group('JSONObject', () {
    setUp(() {});

    test('Test constructors', () {
      var user1 = User.fromFields('joe', 'joe@mail.com');
      print(
          'User[1]: $user1 >> ${user1.getObjectFields()} = ${user1.getObjectValues()}');

      expect(user1.username, equals('joe'));
      expect(user1.email, equals('joe@mail.com'));

      var json1 = user1.toJson();
      print('JSON[1]: $json1');

      expect(json1, equals('{"username":"joe","email":"joe@mail.com"}'));

      user1.setObjectValues(['joe1', 'joe1@mail.com']);

      expect(user1.username, equals('joe1'));
      expect(user1.email, equals('joe1@mail.com'));

      var json1_2 = user1.toJson();
      print('JSON[1.2]: $json1_2');

      expect(json1_2, equals('{"username":"joe1","email":"joe1@mail.com"}'));

      print('-----------------------------------------');

      var user2 = User.fromJson('{"username":"joe2","email":"joe2@mail.com"}');
      print(
          'User[2]: $user2 >> ${user2.getObjectFields()} = ${user2.getObjectValues()}');

      var json2 = user2.toJson();
      print('JSON[2]: $json2');

      expect(json2, equals('{"username":"joe2","email":"joe2@mail.com"}'));

      expect(user2.username, equals('joe2'));
      expect(user2.email, equals('joe2@mail.com'));
    });
  });
}
