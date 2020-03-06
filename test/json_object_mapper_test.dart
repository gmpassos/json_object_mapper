import 'package:json_object_mapper/json_object_mapper.dart';
import 'package:test/test.dart';

class User extends JSONObject {
  String username ;
  String email ;

  User.fromFields(this.username, this.email);

  User.fromJSON(String json) {
    initializeFromJSON(json) ;
  }

  User();

  @override
  List<String> getObjectFields() {
    return getObjectFieldsDefault() ;
    //return ['username' , 'email'] ;
  }

  @override
  String toString() {
    return 'User{username: $username, email: $email}' ;
  }

}

void main() {
  group('A group of tests', () {

    setUp(() {
    });

    test('First Test', () {

      User user1 = User.fromFields("joe", "joe@mail.com") ;
      print("User[1]: $user1");

      expect( user1.username , equals('joe')) ;
      expect( user1.email , equals('joe@mail.com')) ;

      var json1 = user1.toJSON();
      print("JSON[1]: $json1");

      expect( json1 , equals('{"username":"joe","email":"joe@mail.com"}')) ;

      User user2 = User.fromJSON( '{"username":"joe2","email":"joe2@mail.com"}' ) ;
      print("User[2]: $user2");

      expect( user2.toJSON() , equals('{"username":"joe2","email":"joe2@mail.com"}')) ;
      expect( user2.username , equals('joe2')) ;
      expect( user2.email , equals('joe2@mail.com')) ;

    });
  });
}
