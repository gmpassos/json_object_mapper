# json_object_mapper

[![pub package](https://img.shields.io/pub/v/json_object_mapper.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/json_object_mapper)
[![CI](https://img.shields.io/github/workflow/status/gmpassos/json_object_mapper/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/gmpassos/json_object_mapper/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/json_object_mapper?logo=git&logoColor=white)](https://github.com/gmpassos/json_object_mapper/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/json_object_mapper/latest?logo=git&logoColor=white)](https://github.com/gmpassos/json_object_mapper/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/json_object_mapper?logo=git&logoColor=white)](https://github.com/gmpassos/json_object_mapper/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/json_object_mapper?logo=github&logoColor=white)](https://github.com/gmpassos/json_object_mapper/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/json_object_mapper?logo=github&logoColor=white)](https://github.com/gmpassos/json_object_mapper)
[![License](https://img.shields.io/github/license/gmpassos/json_object_mapper?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/json_object_mapper/blob/master/LICENSE)
[![Funding](https://img.shields.io/badge/Donate-yellow?labelColor=666666&style=plastic&logo=liberapay)](https://liberapay.com/gmpassos/donate)
[![Funding](https://img.shields.io/liberapay/patrons/gmpassos.svg?logo=liberapay)](https://liberapay.com/gmpassos/donate)

A simple and easy way to map Objects from JSON and to Map with support for Dart Native and Dart Web.

#### Main features:

- Works with simple Objects: no method implementation needed.

- Compatible with Web (JS) and Native (VM) platforms.

- No @annotations or code generation.

- Only uses Mirrors if it's available in the platform (transparent load).

#### JSONTransformer

You can use simple and easy `JSONTransformer` patterns to transform a JSON tree.

This helps to integrate JSON trees of 3rd part with your code, UI and Entities. 

## Usage

### JSONObject

A simple JSON Object mapping example:

```dart
import 'package:json_object_mapper/json_object_mapper.dart';

class User extends JSONObject {
  String username ;
  String email ;

  User.fromFields(this.username, this.email);

  User.fromJson(String json) {
    initializeFromJson(json) ;
  }

  @override
  String toString() {
    return 'User{username: $username, email: $email}' ;
  }

}

main() {
  
      User user1 = User.fromFields("joe", "joe@mail.com") ;
      
      print("User[1]: $user1");      
      // User[1]: User{username: joe, email: joe@mail.com}

      print(user1.toJson());
      // {"username":"joe","email":"joe@mail.com"}

      User user2 = User.fromJson( '{"username":"joe2","email":"joe2@mail.com"}' ) ;
      
      print("User[2]: $user2");
      // User[2]: User{username: joe2, email: joe2@mail.com}
      
      print(user2.toJson());
      // {"username":"joe2","email":"joe2@mail.com"}

}
```

### JSONTransformer

A simple JSON tree transformation example:

```dart

var json = {
        'result': [
          {'id': 1, 'name': 'a', 'group': 'x'},
          {'id': 2, 'name': 'b', 'group': 'y'},
          {'id': 3, 'name': 'c', 'group': 'z'},
        ]
      };

var json2 = JSONTransformer.parse('{result}.mapEntry(name,id).asMap()');

/// json2 = {'a': 1, 'b': 2, 'c': 3}

```

## JSONTransformer Operations

- `{"$key"}`: converts `node` to a `$key` value of `node as Map`.
- `[$index]`: converts `node` to a `$index` value of `node as List`.
- `asMap()`: converts `node` to a `Map`.
- `asList()`: converts `node` to a `List`.
- `asString($delimiter)`: converts `node` to a `String`, using optional `$delimiter` for `node List`.
- `mapEntry($key,$value)`: converts `node` or `node.entries` to a `MapEntry($key, $value)`.
- `split($delimiter,$limit?)`: converts `node` or `node.entries` splitting into a `List` of parts, using `$delimiter as RegExp` and optional `$limit`.
- `uc()`: converts `node` or `node.entries` to an Upper Case `String`.
- `lc()`: converts `node` or `node.entries` to a Lower Case `String`.
- `trim()`: converts `node` or `node.entries` to a Trimmed `String`.
- `encodeJson($withIdent)`: converts `node` encoding to a JSON `String`, using optional `$withIdent as bool`.
- `decodeJson()`: converts `node` or `node.entries` decoding to a JSON tree.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/json_object_mapper/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

