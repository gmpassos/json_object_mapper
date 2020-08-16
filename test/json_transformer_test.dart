import 'package:json_object_mapper/src/json_transformer.dart';
import 'package:test/test.dart';

void main() {
  group('JSONTransformer', () {
    setUp(() {});

    test('Transform: entries/list -> list of pairs', () {
      var json = {
        'entries': [
          'a:1',
          'b:2',
          'c:3',
        ]
      };

      var jsonTransformer = TMapValue(['entries']).then(TSplit([':']));

      expect(jsonTransformer.toString(), equals('{entries}.split(:)'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var list = jsonTransformer.transform(json);
      print(list);

      expect(
          list,
          equals([
            ['a', '1'],
            ['b', '2'],
            ['c', '3']
          ]));

      jsonTransformer.then(TEncodeJSON());

      expect(jsonTransformer.toString(),
          equals('{entries}.split(:).encodeJson()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);

      var jsonStr = jsonTransformer.transform(json);
      print(jsonStr);

      expect(jsonStr, equals('[["a","1"],["b","2"],["c","3"]]'));
    });

    test('Transform: entries/maps -> map of name:id', () {
      var json = {
        'result': [
          {'id': 1, 'name': 'a', 'group': 'x'},
          {'id': 2, 'name': 'b', 'group': 'y'},
          {'id': 3, 'name': 'c', 'group': 'z'},
        ]
      };

      var jsonTransformer = TMapValue(['result']).then(
        TMapEntry(['name', 'id']),
        TAsMap(),
      );

      expect(jsonTransformer.toString(),
          equals('{result}.mapEntry(name,id).asMap()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map = jsonTransformer.transform(json);

      print(map);

      expect(map, equals({'a': 1, 'b': 2, 'c': 3}));
    });

    test('Transform: list of maps -> map of name:id', () {
      var json = [
        {'id': 1, 'name': 'a', 'group': 'x'},
        {'id': 2, 'name': 'b', 'group': 'y'},
        {'id': 3, 'name': 'c', 'group': 'z'},
      ];

      var jsonTransformer = TListValue([2, 0]).then(
        TMapEntry(['id', 'group']),
        TAsMap(),
      );

      expect(jsonTransformer.toString(),
          equals('[2,0].mapEntry(id,group).asMap()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map = jsonTransformer.transform(json);

      print(map);

      expect(map, equals({3: 'z', 1: 'x'}));
    });
  });
}

void _expectSelfParse(JSONTransformer jsonTransformer) {
  var transformers = jsonTransformer.toString();
  var jsonTransformer2 = JSONTransformer.parse(transformers);
  var transformers2 = jsonTransformer2.toString();
  expect(transformers2, equals(transformers));
}
