import 'package:swiss_knife/swiss_knife.dart';

final RegExp _PATTERN_WORD = RegExp(r'^\w+$', multiLine: false);

final RegExp _LIST_DELIMITER_PATTERN = RegExp(r'\s*[,;:]\s*', multiLine: false);

bool _registerTransformersCalled = false;

void _registerTransformers() {
  if (_registerTransformersCalled) return;
  _registerTransformersCalled = true;

  TMapValue._register();
  TListValue._register();
  TSplit._register();

  TAsList._register();
  TAsMap._register();

  TMapEntry._register();

  TEncodeJSON._register();
  TDecodeJSON._register();

  TAsString._register();

  TTrim._register();

  TLowerCase._register();
  TUpperCase._register();
}

abstract class JSONTransformer {
  static final Map<String, JSONTransformer> _registeredTransformers = {};

  JSONTransformer._register() {
    _registeredTransformers.putIfAbsent(type, () => this);
  }

  factory JSONTransformer.parse(String transformers) {
    _registerTransformers();

    if (transformers == null) return null;

    transformers = _trimTransformers(transformers);

    JSONTransformer root;

    JSONTransformer t;

    LOOP:
    while (transformers.isNotEmpty) {
      for (var tRegistered in _registeredTransformers.values) {
        var match = tRegistered.matches(transformers);

        if (match != null) {
          var t2 = tRegistered.fromMatch(match);
          if (t != null) {
            t.then(t2);
          } else {
            root = t2;
          }

          t = t2;

          transformers = transformers.substring(match.end);
          transformers = _trimTransformers(transformers);

          continue LOOP;
        }
      }

      break;
    }

    return root;
  }

  static final RegExp _TRIM_PATTERN_INIT = RegExp(r'^[\s.]+', multiLine: false);
  static final RegExp _TRIM_PATTERN_END = RegExp(r'[\s.]+$', multiLine: false);

  static String _trimTransformers(String t) {
    return t
        .replaceFirst(_TRIM_PATTERN_INIT, '')
        .replaceFirst(_TRIM_PATTERN_END, '');
  }

  JSONTransformer._() {
    _registerTransformers();
  }

  String get type;

  Match matches(String s);

  JSONTransformer fromMatch(Match match);

  List<JSONTransformer> _then;

  JSONTransformer clearThen() {
    if (_then != null) _then.clear();
    return this;
  }

  JSONTransformer then(JSONTransformer t1,
      [JSONTransformer t2,
      JSONTransformer t3,
      JSONTransformer t4,
      JSONTransformer t5,
      JSONTransformer t6,
      JSONTransformer t7,
      JSONTransformer t8,
      JSONTransformer t9,
      JSONTransformer t10]) {
    var list = <JSONTransformer>[t1, t2, t3, t4, t5, t6, t7, t8, t9, t10];
    list.removeWhere((t) => t == null);
    return thenChain(list);
  }

  JSONTransformer thenChain(List<JSONTransformer> then) {
    _then ??= [];
    _then.addAll(then);
    return this;
  }

  dynamic transform(dynamic json) {
    var transform = computeTransformation(json);
    if (_then != null) {
      for (var t in _then) {
        transform = t.transform(transform);
      }
    }
    return transform;
  }

  dynamic computeTransformation(dynamic json);

  String toStringThen(String prefix) {
    if (_then == null || _then.isEmpty) return '';
    if (_then.length == 1) return '$prefix${_then.first}';
    return '$prefix${_then.join('.')}';
  }

  @override
  String toString();
}

class TListValue extends JSONTransformer {
  final List<int> indexes;

  TListValue(this.indexes) : super._();

  TListValue._register()
      : indexes = null,
        super._register();

  @override
  String get type => 'TListValue';

  static final RegExp PATTERN = RegExp(r'^\[\s*(\d+(?:\s*,\s*\d+)?\s*)\]');

  @override
  Match matches(String s) {
    return PATTERN.firstMatch(s);
  }

  @override
  TListValue fromMatch(Match match) {
    if (match == null) return null;
    var indexesStr = match.group(1);
    print(_LIST_DELIMITER_PATTERN);
    var indexes =
        indexesStr.split(_LIST_DELIMITER_PATTERN).map(parseInt).toList();
    return TListValue(indexes);
  }

  @override
  dynamic computeTransformation(dynamic json) {
    if (json is List) {
      if (indexes == null || indexes.isEmpty) {
        return json;
      } else if (indexes.length == 1) {
        var index = indexes.first;
        return _getIndexValue(json, index);
      } else {
        return indexes.map((i) => _getIndexValue(json, i)).toList();
      }
    } else if (json is Map) {
      if (indexes == null || indexes.isEmpty) {
        return json.values;
      } else if (indexes.length == 1) {
        var index = indexes[0];
        return _getKeyValue(json, '$index');
      } else {
        return indexes.map((i) => _getKeyValue(json, '$i')).toList();
      }
    }
    return [];
  }

  @override
  String toString() {
    var idx = indexes == null || indexes.isEmpty
        ? '*'
        : (indexes.length == 1 ? '${indexes[0]}' : indexes.join(','));
    return '[$idx]${toStringThen('.')}';
  }
}

class TMapValue extends JSONTransformer {
  final List<String> keys;

  TMapValue(this.keys) : super._();

  TMapValue._register()
      : keys = null,
        super._register();

  @override
  String get type => 'TMapValue';

  static final RegExp PATTERN = RegExp(
      r'''^\{\s*((?:".*?"|'.*?'|\w+)(?:\s*,\s*(?:".*?"|'.*?'|\w+))?\s*)\}''');

  @override
  Match matches(String s) {
    return PATTERN.firstMatch(s);
  }

  static final RegExp STRING_PATTERN = RegExp(r'''(?:"(.*?)"|'(.*?)'|(\w+))''');

  @override
  TMapValue fromMatch(Match match) {
    if (match == null) return null;
    var keysStr = match.group(1);
    var keys = STRING_PATTERN
        .allMatches(keysStr)
        .map((m) => m.group(1) ?? m.group(2) ?? m.group(3))
        .toList();
    return TMapValue(keys);
  }

  @override
  dynamic computeTransformation(dynamic json) {
    if (json is Map) {
      if (keys == null || keys.isEmpty) {
        return json.values;
      } else if (keys.length == 1) {
        var key = keys.first;
        return _getKeyValue(json, key);
      } else {
        return keys.map((k) => _getKeyValue(json, k)).toList();
      }
    } else if (json is List) {
      if (keys == null || keys.isEmpty) {
        return json;
      } else {
        return json.map(computeTransformation).toList();
      }
    }
    return [];
  }

  String _keyToString(String s) {
    if (s == null) return '*';

    if (_PATTERN_WORD.hasMatch(s)) {
      return s;
    } else if (s.contains('"')) {
      return "'$s'";
    } else if (s.contains("'")) {
      return '"$s"';
    } else {
      return '"$s"';
    }
  }

  String keysToString() {
    if (keys == null || keys.isEmpty) return '*';
    return keys.map(_keyToString).join(',');
  }

  @override
  String toString() {
    var keys = keysToString();
    return '{$keys}${toStringThen('.')}';
  }
}

abstract class TOperation extends JSONTransformer {
  final String name;

  final bool nonCollectionOperation;
  final List parameters;

  TOperation(this.name, this.nonCollectionOperation, [this.parameters])
      : super._();

  TOperation._register(String name)
      : name = name,
        nonCollectionOperation = null,
        parameters = null,
        super._register();

  @override
  String get type => 'TOperation.$name';

  static final Map<String, RegExp> OPS_PATTERN = {};

  RegExp get _pattern {
    var pattern = OPS_PATTERN[name];
    if (pattern != null) return pattern;
    pattern = RegExp('^$name'
        r'''\(\s*((?:".*?"|'.*?'|[^\s\(\),]+?)(?:\s*,\s*(?:".*?"|'.*?'|[^\s\(\),]+?))*)?\s*\)''');
    OPS_PATTERN[name] = pattern;
    return pattern;
  }

  @override
  Match matches(String s) {
    var pattern = _pattern;
    return pattern.firstMatch(s);
  }

  @override
  TOperation fromMatch(Match match) {
    if (match == null) return null;
    var paramsStr = match.group(1);
    var params = parseParameters(paramsStr);
    return fromParameters(params);
  }

  TOperation fromParameters([List parameters]);

  static final RegExp _PARAMETERS_DELIMITER_PATTERN =
      RegExp(r'\s*,\s*', multiLine: false);

  List parseParameters(String s) {
    if (s == null) return null;
    s = s.trim();
    if (s.isEmpty) return null;

    if (s.length == 1) return [s];

    var params =
        s.split(_PARAMETERS_DELIMITER_PATTERN).map(_parsePrimitive).toList();
    return params;
  }

  dynamic _parsePrimitive(String s) {
    if (s == null) return null;
    s = s.trim();
    if (s.isEmpty) return '';
    if (isInt(s)) return parseInt(s);
    if (isDouble(s)) return parseDouble(s);
    return s;
  }

  String _primitiveToString(dynamic v, bool singleParameter) {
    if (v == null) return v;
    var s = v.toString();

    if (v is num) {
      return v.toString();
    } else if (_PATTERN_WORD.hasMatch(s)) {
      return s;
    } else if (s.contains('"')) {
      return "'$s'";
    } else if (s.contains("'")) {
      return '"$s"';
    } else if (s.length == 1 && singleParameter) {
      return s;
    } else {
      return '"$s"';
    }
  }

  List subParameters(int offset) {
    if (parameters == null) return null;
    offset ??= 0;
    if (offset == 0) return parameters;
    if (offset >= parameters.length) return [];
    return parameters.sublist(offset);
  }

  T getParameter<T>(int index, [T def, T Function(dynamic v) parser]) {
    if (parameters == null || index < 0) return def;
    if (index < parameters.length) {
      var val = parameters[index];
      if (val != null) {
        return parser(val);
      } else {
        return def;
      }
    }
    return def;
  }

  @override
  dynamic computeTransformation(dynamic json) {
    if (json == null) return [];

    if (nonCollectionOperation) {
      return computeOperation(json);
    } else if (json is List) {
      return json.map((e) => computeOperation(e)).toList();
    } else if (json is Map) {
      return json.map((key, value) => MapEntry(key, computeOperation(value)));
    } else {
      return computeOperation(json);
    }
  }

  dynamic computeOperation(dynamic json);

  String parametersToString() {
    if (parameters == null || parameters.isEmpty) return '';
    var singleParameter = parameters.length == 1;
    return parameters
        .map((p) => _primitiveToString(p, singleParameter))
        .join(',');
  }

  @override
  String toString() {
    var params = parametersToString();
    return '$name($params)${toStringThen('.')}';
  }
}

class TTrim extends TOperation {
  static final String NAME = 'trim';

  TTrim([List parameters]) : super(NAME, false, parameters);

  TTrim._register() : super._register(NAME);

  @override
  TTrim fromParameters([List parameters]) => TTrim(parameters);

  @override
  String computeOperation(dynamic json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return s.trim();
  }
}

class TLowerCase extends TOperation {
  static final String NAME = 'lc';

  TLowerCase([List parameters]) : super(NAME, false, parameters);

  TLowerCase._register() : super._register(NAME);

  @override
  TLowerCase fromParameters([List parameters]) => TLowerCase(parameters);

  @override
  String computeOperation(dynamic json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return s.toLowerCase();
  }
}

class TUpperCase extends TOperation {
  static final String NAME = 'uc';

  TUpperCase([List parameters]) : super(NAME, false, parameters);

  TUpperCase._register() : super._register(NAME);

  @override
  TUpperCase fromParameters([List parameters]) => TUpperCase(parameters);

  @override
  String computeOperation(dynamic json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return s.toUpperCase();
  }
}

class TEncodeJSON extends TOperation {
  static final String NAME = 'encodeJson';

  TEncodeJSON([List parameters]) : super(NAME, true, parameters);

  TEncodeJSON._register() : super._register(NAME);

  @override
  TEncodeJSON fromParameters([List parameters]) => TEncodeJSON(parameters);

  @override
  String computeOperation(dynamic json) {
    if (json == null) return null;
    var withIdent = getParameter(0, false, parseBool);
    return encodeJSON(json, withIdent: withIdent);
  }
}

class TDecodeJSON extends TOperation {
  static final String NAME = 'decodeJson';

  TDecodeJSON([List parameters]) : super(NAME, true, parameters);

  TDecodeJSON._register() : super._register(NAME);

  @override
  TDecodeJSON fromParameters([List parameters]) => TDecodeJSON(parameters);

  @override
  String computeOperation(dynamic json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return parseJSON(s);
  }
}

class TAsString extends TOperation {
  static final String NAME = 'asString';

  TAsString([List parameters]) : super(NAME, true, parameters);

  TAsString._register() : super._register(NAME);

  @override
  TAsString fromParameters([List parameters]) => TAsString(parameters);

  @override
  String computeOperation(dynamic json) {
    if (json == null) {
      return '';
    } else if (json is String) {
      return json;
    } else if (json is List) {
      var delimiter = getParameter(0, '');
      return json.join(delimiter);
    } else if (json is Map) {
      var delimiterK = getParameter(0, '');
      var delimiterV = getParameter(1, '');
      return json.entries
          .map((e) => '${e.key}$delimiterK${e.value}')
          .join(delimiterV);
    } else {
      return parseString(json);
    }
  }
}

class TSplit extends TOperation {
  static final String NAME = 'split';

  TSplit([List parameters]) : super(NAME, false, parameters);

  TSplit._register() : super._register(NAME);

  @override
  TSplit fromParameters([List parameters]) => TSplit(parameters);

  @override
  dynamic computeOperation(dynamic json) {
    var s = TAsString(subParameters(2)).transform(json) as String;

    var delimiter = getParameter(0, null, parseString);
    var limit = getParameter(1, null, parseInt);

    var pattern =
        delimiter != null ? RegExp(delimiter) : _LIST_DELIMITER_PATTERN;

    return split(s, pattern, limit);
  }
}

class TMapEntry extends TOperation {
  static final String NAME = 'mapEntry';

  TMapEntry([List parameters]) : super(NAME, false, parameters);

  TMapEntry._register() : super._register(NAME);

  @override
  TMapEntry fromParameters([List parameters]) => TMapEntry(parameters);

  @override
  MapEntry computeOperation(dynamic json) {
    if (json == null) return MapEntry(null, null);

    if (json is MapEntry) {
      return json;
    } else if (json is Pair) {
      return json.asMapEntry;
    } else if (json is List) {
      if (json.isEmpty) {
        return null;
      } else if (json.length == 1) {
        return MapEntry(json[0], null);
      } else {
        return MapEntry(json[0], json[1]);
      }
    } else if (json is Map) {
      if (json.isEmpty) {
        return null;
      } else {
        var keyName = getParameter(0, null, parseString);
        var valName = getParameter(1, null, parseString);

        if (keyName == null || valName == null) {
          var keys = json.keys.toList();

          if (keyName != null) {
            keys.remove(keyName);
          }

          if (valName != null) {
            keys.remove(valName);
          }

          keyName ??= parseString(keys.removeAt(0));
          valName ??= parseString(keys.removeAt(0));
        }
        return MapEntry(json[keyName], json[valName]);
      }
    } else {
      return MapEntry('/', json);
    }
  }
}

class TAsList extends TOperation {
  static final String NAME = 'asList';

  TAsList([List parameters]) : super(NAME, true, parameters);

  TAsList._register() : super._register(NAME);

  @override
  TAsList fromParameters([List parameters]) => TAsList(parameters);

  @override
  List computeOperation(dynamic json) {
    if (json == null) {
      return [];
    } else if (json is Iterable) {
      return json.toList();
    } else if (json is MapEntry) {
      return [json.key, json.value];
    } else if (json is Pair) {
      return json.asList;
    } else if (json is Map) {
      return json.entries.toList();
    } else if (json is String) {
      var delimiter = getParameter(0);
      var delimiterPattern =
          delimiter != null ? RegExp(delimiter) : _LIST_DELIMITER_PATTERN;
      return parseFromInlineList(json, delimiterPattern, (s) => s);
    } else {
      return [json];
    }
  }
}

class TAsMap extends TOperation {
  static final String NAME = 'asMap';

  TAsMap([List parameters]) : super(NAME, true, parameters);

  TAsMap._register() : super._register(NAME);

  @override
  TAsMap fromParameters([List parameters]) => TAsMap(parameters);

  @override
  Map computeOperation(dynamic json) {
    if (json == null) {
      return {};
    } else if (json is Iterable) {
      var tMapEntry = TMapEntry(parameters);
      var entries =
          json.map((e) => tMapEntry.transform(e) as MapEntry).toList();
      return Map.fromEntries(entries);
    } else if (json is MapEntry) {
      return Map.fromEntries([json]);
    } else if (json is Pair) {
      return Map.fromEntries([json.asMapEntry]);
    } else if (json is Map) {
      return json;
    } else if (json is String) {
      var delimiterPairs = getParameter(0);
      var delimiterKeyValue = getParameter(1);
      var delimiterPairsPattern = delimiterPairs != null
          ? RegExp(delimiterPairs)
          : _LIST_DELIMITER_PATTERN;
      var delimiterKeyValuePattern = delimiterPairs != null
          ? RegExp(delimiterKeyValue)
          : _LIST_DELIMITER_PATTERN;
      return parseFromInlineMap(json, delimiterPairsPattern,
          delimiterKeyValuePattern, (s) => s, (s) => s);
    } else {
      return {'/': json};
    }
  }
}

T _getIndexValue<T>(List<T> list, int index) {
  if (list == null || list.isEmpty) return null;
  var length = list.length;

  if (index >= length) {
    index = length - 1;
  } else if (index < 0) {
    index = length + index;
  }

  return list[index];
}

V _getKeyValue<K, V>(Map<K, V> map, K key) {
  if (map == null || map.isEmpty) return null;

  var val = map[key];
  if (val != null) return val;

  var keyLC = '$key'.toLowerCase();
  for (var entry in map.entries) {
    var entryKey = '${entry.key}'.toLowerCase();
    if (entryKey == keyLC) {
      return entry.value;
    }
  }

  return null;
}
