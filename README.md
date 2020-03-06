# json_object_mapper

A simple and easy way to map Objects to/from Map and JSON with Web support.

#### Main features:
 
- Compatible with Web (dart2js) and VM.

- No code generation.

- Uses Mirrors only if available in platform (transparent load).

## Usage

A simple usage example:

```dart
import 'package:json_object_mapper/json_object_mapper.dart';

class User extends JSONObject {
  String username ;
  String email ;

  User.fields(this.username, this.email);

  User.json(String json) {
    initializeFromJSON(json) ;
  }

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

main() {
  
      User user1 = User.fields("joe", "joe@mail.com") ;
      
      print("User[1]: $user1");      
      // User[1]: User{username: joe, email: joe@mail.com}

      print(user1.toJSON());
      // {"username":"joe","email":"joe@mail.com"}

      User user2 = User.json( '{"username":"joe2","email":"joe2@mail.com"}' ) ;
      
      print("User[2]: $user2");
      // User[2]: User{username: joe2, email: joe2@mail.com}
      
      print(user2.toJSON());
      // {"username":"joe2","email":"joe2@mail.com"}

}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/json_object_mapper/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

