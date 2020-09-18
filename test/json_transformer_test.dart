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

    test('Transform: sub-entries/maps -> map of id:pos', () {
      var json = {
        'result': {
          'list': [
            {
              'id': 1,
              'name': 'a',
              'pos': {'x': 10, 'y': 100}
            },
            {
              'id': 2,
              'name': 'b',
              'pos': {'x': 20, 'y': 200}
            },
            {
              'id': 3,
              'name': 'c',
              'pos': {'x': 30, 'y': 300}
            },
          ]
        }
      };

      var jsonTransformer =
          JSONTransformer.parse('{result}.{list}.mapEntry(id, pos).asMap()');

      expect(jsonTransformer.toString(),
          equals('{result}.{list}.mapEntry(id,pos).asMap()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map = jsonTransformer.transform(json);

      print(map);

      expect(
          map,
          equals({
            1: {'x': 10, 'y': 100},
            2: {'x': 20, 'y': 200},
            3: {'x': 30, 'y': 300}
          }));
    });

    test('Transform: sub-entries/maps -> map of id:pos/x', () {
      var json = {
        'result': {
          'list': [
            {
              'id': 1,
              'name': 'a',
              'pos': {'x': 10, 'y': 100}
            },
            {
              'id': 2,
              'name': 'b',
              'pos': {'x': 20, 'y': 200}
            },
            {
              'id': 3,
              'name': 'c',
              'pos': {'x': 30, 'y': 300}
            },
          ]
        }
      };

      var jsonTransformer = JSONTransformer.parse(
          '{result}{list}.mapEntry(id, {pos}{x}).asMap()');

      expect(jsonTransformer.toString(),
          equals('{result}.{list}.mapEntry(id,{pos}.{x}).asMap()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map = jsonTransformer.transform(json);

      print(map);

      expect(map, equals({1: 10, 2: 20, 3: 30}));
    });

    test('Transform: sub-entries/maps -> map of id:pos/x,y', () {
      var json = {
        'result': {
          'list': [
            {
              'id': 1,
              'name': 'a',
              'pos': {'x': 10, 'y': 100}
            },
            {
              'id': 2,
              'name': 'b',
              'pos': {'x': 20, 'y': 200}
            },
            {
              'id': 3,
              'name': 'c',
              'pos': {'x': 30, 'y': 300}
            },
          ]
        }
      };

      var jsonTransformer = JSONTransformer.parse(
          '{result}{list}.mapEntry(id, {pos}{x}+","+{pos}{y}).asMap()');

      expect(
          jsonTransformer.toString(),
          equals(
              '{result}.{list}.mapEntry(id,{pos}.{x}+","+{pos}.{y}).asMap()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map = jsonTransformer.transform(json);

      print(map);

      expect(map, equals({1: '10,100', 2: '20,200', 3: '30,300'}));
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

    test('Transform: trim, uc, lc', () {
      var json = [' a ', ' b ', ' c '];

      var jsonTransformer = TTrim().then(TUpperCase());

      expect(jsonTransformer.toString(), equals('trim().uc()'));
      _expectSelfParse(jsonTransformer);

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map = jsonTransformer.transform(json);
      print(map);
      expect(map, equals(['A', 'B', 'C']));

      jsonTransformer.then(TLowerCase());

      print('-----------------------------------');
      print(jsonTransformer);
      print(json);
      var map2 = jsonTransformer.transform(json);
      print(map2);
      expect(map2, equals(['a', 'b', 'c']));
    });
  });
}

void _expectSelfParse(JSONTransformer jsonTransformer) {
  var transformers = jsonTransformer.toString();
  var jsonTransformer2 = JSONTransformer.parse(transformers);
  var transformers2 = jsonTransformer2.toString();
  expect(transformers2, equals(transformers));
}
