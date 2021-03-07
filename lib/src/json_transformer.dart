import 'package:swiss_knife/swiss_knife.dart';
import 'package:swiss_knife/src/collections.dart';

const _REGEXP_DIALECT = {
  'n': r'[\r\n]',
  's': r'[ \t]',
  'd': r'[+-]?\d+',
  'str': r'''(?:'.*?'|".*?")''',
  'strs': r'$str+',
  'word': r'[\w.:_-]+',
  'strword': r'(?:$str|$word)',
  'mapkey': r'\{$strword\}',
  'mapkeys': r'$mapkey(?:\.?$mapkey)*',
  'listidx': r'\[$d\]',
  'listidxs': r'$listidx(?:\.?$listidx)*',
  'entry': r'(?:$mapkey|$listidx)',
  'entries': r'$entry(?:\.?$entry)*',
  'strentry': r'(?:$str|$entry)',
  'strentries': r'$strentry(?:\.?$strentry)*',
  'concat': r'$strentries(?:\+$strentries)+',
  'param': r'(?:$concat|$word|$d|$strentries)',
  'params': r'$param(?:\s*,\s*$param)*',
  'funct': r'\.?\w+\(\s*$params\s*\)',
};

final RegExp _PATTERN_WORD = RegExp(r'^\w+$', multiLine: false);

final RegExp _PATTERN_LIST_INDEXES =
    regExpDialect(_REGEXP_DIALECT, r'^$listidxs$');

final RegExp _PATTERN_MAP_KEYS = regExpDialect(_REGEXP_DIALECT, r'^$mapkeys$');

final RegExp _LIST_DELIMITER_PATTERN = RegExp(r'\s*[,;:]\s*', multiLine: false);

final RegExp _PATTERN_CONCAT = regExpDialect(_REGEXP_DIALECT, r'^$concat');

bool _registerTransformersCalled = false;

void _registerTransformers() {
  if (_registerTransformersCalled) return;
  _registerTransformersCalled = true;

  TString._register();
  TConcatenation._register();
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

  /// Returns a [JSONTransformer] from [transformers]. Parses if needed.
  static JSONTransformer? from(Object? transformers) {
    if (transformers == null) return null;

    if (transformers is JSONTransformer) return transformers;

    if (transformers is String) {
      return JSONTransformer.parse(transformers);
    }

    if (transformers is List) {
      var list = transformers
          .map((e) => JSONTransformer.from(e))
          .whereType<JSONTransformer>()
          .toList();

      if (list.isEmpty) {
        return null;
      }

      var root = list.removeAt(0);
      root.thenChain(list);
      return root;
    }

    return null;
  }

  /// Parses [transformers] to a [JSONTransformer] chain.
  static JSONTransformer? parse(String? transformers) {
    _registerTransformers();

    if (transformers == null) return null;

    transformers = _trimTransformers(transformers);

    JSONTransformer? root;

    JSONTransformer? t;

    LOOP:
    while (transformers!.isNotEmpty) {
      for (var tRegistered in _registeredTransformers.values) {
        var match = tRegistered.matches(transformers!);

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

  Match? matches(String s);

  JSONTransformer? fromMatch(Match match);

  List<JSONTransformer>? _then;

  JSONTransformer clearThen() {
    if (_then != null) _then!.clear();
    return this;
  }

  /// Other [JSONTransformer] to apply after this [transform].
  JSONTransformer then(JSONTransformer? t1,
      [JSONTransformer? t2,
      JSONTransformer? t3,
      JSONTransformer? t4,
      JSONTransformer? t5,
      JSONTransformer? t6,
      JSONTransformer? t7,
      JSONTransformer? t8,
      JSONTransformer? t9,
      JSONTransformer? t10]) {
    var list = [t1, t2, t3, t4, t5, t6, t7, t8, t9, t10]
        .whereType<JSONTransformer>()
        .toList();
    return thenChain(list);
  }

  JSONTransformer thenChain(List<JSONTransformer>? then) {
    if (then == null || then.isEmpty) return this;
    _then ??= [];
    _then!.addAll(then);
    return this;
  }

  /// Transforms [json] using chain operations.
  dynamic transform(Object? json) {
    var transform = computeTransformation(json);
    if (_then != null) {
      for (var t in _then!) {
        transform = t.transform(transform);
      }
    }
    return transform;
  }

  dynamic computeTransformation(Object? json);

  String toStringThen(String prefix) {
    if (_then == null || _then!.isEmpty) return '';
    if (_then!.length == 1) return '$prefix${_then!.first}';
    return '$prefix${_then!.join('.')}';
  }

  /// Returns this chain of operations as [String].
  @override
  String toString();
}

/// A text [String].
class TString extends JSONTransformer {
  /// The group of transformations.
  final String text;

  TString(this.text) : super._();

  TString._register()
      : text = '',
        super._register();

  @override
  String get type => 'TString';

  var PATTERN = regExpDialect(_REGEXP_DIALECT, r'''^(?:'(.*?)'|"(.*?)")$''');

  @override
  Match? matches(String s) {
    return PATTERN.firstMatch(s);
  }

  @override
  TString? fromMatch(Match match) {
    var text = match.group(1) ?? match.group(2)!;
    return TString(text);
  }

  @override
  String computeTransformation(Object? json) {
    return text;
  }

  @override
  String toString() {
    if (text.contains('"')) {
      return "'$text'";
    } else {
      return '"$text"';
    }
  }
}

/// Concatenate transformations
class TConcatenation extends JSONTransformer {
  /// The group of transformations.
  final List<JSONTransformer> group;

  TConcatenation(this.group) : super._();

  TConcatenation._register()
      : group = [],
        super._register();

  @override
  String get type => 'TConcatenation';

  var PATTERN =
      regExpDialect(_REGEXP_DIALECT, r'^($strentries(?:\+$strentries)+)$');

  @override
  Match? matches(String s) {
    return PATTERN.firstMatch(s);
  }

  static final RegExp ENTRY_PATTERN =
      regExpDialect(_REGEXP_DIALECT, r'(?:($str)|($entries))');

  @override
  TConcatenation fromMatch(Match match) {
    var entriesStr = match.group(1)!;
    var entries = ENTRY_PATTERN.allMatches(entriesStr).map((m) {
      return m.group(1) ?? m.group(2);
    }).toList();
    var group = entries.map((e) => JSONTransformer.parse(e)!).toList();
    return TConcatenation(group);
  }

  @override
  String computeTransformation(Object? json) {
    return group.map((t) {
      var v = t.transform(json);
      return v;
    }).join();
  }

  String groupsToString() {
    if (group.isEmpty) return '';
    return group.map((t) => t.toString()).join('+');
  }

  @override
  String toString() {
    var groups = groupsToString();
    return '$groups${toStringThen('.')}';
  }
}

/// Transforms JSON node to a [List] index value.
class TListValue extends JSONTransformer {
  /// The indexes to use for values.
  final List<int> indexes;

  TListValue(this.indexes) : super._();

  TListValue._register()
      : indexes = [],
        super._register();

  @override
  String get type => 'TListValue';

  static final RegExp PATTERN = RegExp(r'^\[\s*(\d+(?:\s*,\s*\d+)?\s*)\]');

  @override
  Match? matches(String s) {
    return PATTERN.firstMatch(s);
  }

  @override
  TListValue fromMatch(Match match) {
    var indexesStr = match.group(1)!;
    var indexes = indexesStr
        .split(_LIST_DELIMITER_PATTERN)
        .map((e) => parseInt(e)!)
        .toList();
    return TListValue(indexes);
  }

  @override
  dynamic computeTransformation(Object? json) {
    if (json is List) {
      if (indexes.isEmpty) {
        return json;
      } else if (indexes.length == 1) {
        var index = indexes.first;
        return _getIndexValue(json, index);
      } else {
        return indexes.map((i) => _getIndexValue(json, i)).toList();
      }
    } else if (json is Map) {
      if (indexes.isEmpty) {
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
    var idx = indexes.isEmpty
        ? '*'
        : (indexes.length == 1 ? '${indexes[0]}' : indexes.join(','));
    return '[$idx]${toStringThen('.')}';
  }
}

/// Transforms JSON node to a [Map] key value.
class TMapValue extends JSONTransformer {
  /// The keys to use for values.
  final List<String> keys;

  TMapValue(this.keys) : super._();

  TMapValue._register()
      : keys = [],
        super._register();

  @override
  String get type => 'TMapValue';

  static final RegExp PATTERN = RegExp(
      r'''^\{\s*((?:".*?"|'.*?'|\w+)(?:\s*,\s*(?:".*?"|'.*?'|\w+))?\s*)\}''');

  @override
  Match? matches(String s) {
    return PATTERN.firstMatch(s);
  }

  static final RegExp STRING_PATTERN = RegExp(r'''(?:"(.*?)"|'(.*?)'|(\w+))''');

  @override
  TMapValue fromMatch(Match match) {
    var keysStr = match.group(1)!;
    var keys = STRING_PATTERN
        .allMatches(keysStr)
        .map((m) => (m.group(1) ?? m.group(2) ?? m.group(3))!)
        .toList();
    return TMapValue(keys);
  }

  @override
  dynamic computeTransformation(Object? json) {
    if (json is Map) {
      if (keys.isEmpty) {
        return json.values;
      } else if (keys.length == 1) {
        var key = keys.first;
        return _getKeyValue(json, key);
      } else {
        return keys.map((k) => _getKeyValue(json, k)).toList();
      }
    } else if (json is List) {
      if (keys.isEmpty) {
        return json;
      } else {
        return json.map(computeTransformation).toList();
      }
    }
    return [];
  }

  String _keyToString(String s) {
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
    if (keys.isEmpty) return '*';
    return keys.map(_keyToString).join(',');
  }

  @override
  String toString() {
    var keys = keysToString();
    return '{$keys}${toStringThen('.')}';
  }
}

/// Base class for operations.
abstract class TOperation extends JSONTransformer {
  /// Name of the operation, like a method name.
  final String name;

  final bool nonCollectionOperation;
  final List? parameters;

  TOperation(this.name, this.nonCollectionOperation, [this.parameters])
      : super._();

  TOperation._register(String name)
      : name = name,
        nonCollectionOperation = false,
        parameters = null,
        super._register();

  @override
  String get type => 'TOperation.$name';

  static final Map<String, RegExp> OPS_PATTERN = {};

  RegExp get _pattern {
    var pattern = OPS_PATTERN[name];
    if (pattern != null) return pattern;

    pattern = regExpDialect(
        _REGEXP_DIALECT,
        '^$name'
        r'\(\s*($params)?\s*\)');

    OPS_PATTERN[name] = pattern;
    return pattern;
  }

  @override
  Match? matches(String s) {
    var pattern = _pattern;
    return pattern.firstMatch(s);
  }

  @override
  TOperation fromMatch(Match match) {
    var paramsStr = match.group(1);
    var params = parseParameters(paramsStr);
    return fromParameters(params);
  }

  TOperation fromParameters([List? parameters]);

  static final RegExp _PARAMETERS_PATTERN =
      regExpDialect(_REGEXP_DIALECT, r'^\s*($param)(?:\s*,\s*|\s*$)');

  List? parseParameters(String? s) {
    if (s == null) return null;
    s = s.trim();
    if (s.isEmpty) return null;

    if (s.length == 1) return [s];

    var params = <String>[];

    while (s!.isNotEmpty) {
      var m = _PARAMETERS_PATTERN.firstMatch(s);
      if (m != null) {
        var val = m.group(1);
        if (val != null) {
          params.add(val);
        }
        s = s.substring(m.end);
      } else {
        params.add(s.trim());
        break;
      }
    }

    var parsedParameters = params.map(_parsePrimitive).toList();

    return parsedParameters;
  }

  dynamic _parsePrimitive(String s) {
    s = s.trim();

    if (s.isEmpty) {
      return '';
    } else if (isInt(s)) {
      return parseInt(s);
    } else if (isDouble(s)) {
      return parseDouble(s);
    } else if (_PATTERN_CONCAT.hasMatch(s)) {
      var t = JSONTransformer.parse(s);
      return t;
    } else if (_PATTERN_MAP_KEYS.hasMatch(s)) {
      var t = JSONTransformer.parse(s);
      return t;
    } else if (_PATTERN_LIST_INDEXES.hasMatch(s)) {
      var t = JSONTransformer.parse(s);
      return t;
    }
    return s;
  }

  String? _primitiveToString(Object? v, bool singleParameter) {
    if (v == null) return null;
    var s = v.toString();

    if (v is num) {
      return s;
    } else if (v is JSONTransformer) {
      return s;
    } else if (_PATTERN_WORD.hasMatch(s)) {
      return s;
    } else if (_PATTERN_LIST_INDEXES.hasMatch(s)) {
      return s;
    } else if (_PATTERN_MAP_KEYS.hasMatch(s)) {
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

  List? subParameters(int offset) {
    if (parameters == null) return null;
    if (offset == 0) return parameters;
    if (offset >= parameters!.length) return [];
    return parameters!.sublist(offset);
  }

  T? getParameter<T>(int index, [T? def, T Function(Object v)? parser]) {
    if (parameters == null || index < 0) return def;
    if (index < parameters!.length) {
      var val = parameters![index];
      if (val != null) {
        return parser != null ? parser(val) : val;
      } else {
        return def;
      }
    }
    return def;
  }

  @override
  dynamic computeTransformation(Object? json) {
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

  dynamic computeOperation(Object? json);

  String parametersToString() {
    if (parameters == null || parameters!.isEmpty) return '';
    var singleParameter = parameters!.length == 1;
    return parameters!
        .map((p) => _primitiveToString(p, singleParameter))
        .join(',');
  }

  @override
  String toString() {
    var params = parametersToString();
    return '$name($params)${toStringThen('.')}';
  }
}

/// Converts JSON node to a Trimmed [String].
class TTrim extends TOperation {
  static final String NAME = 'trim';

  TTrim([List? parameters]) : super(NAME, false, parameters);

  TTrim._register() : super._register(NAME);

  @override
  TTrim fromParameters([List? parameters]) => TTrim(parameters);

  @override
  String? computeOperation(Object? json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return s.trim();
  }
}

/// Converts JSON node to a Lower Case [String].
class TLowerCase extends TOperation {
  static final String NAME = 'lc';

  TLowerCase([List? parameters]) : super(NAME, false, parameters);

  TLowerCase._register() : super._register(NAME);

  @override
  TLowerCase fromParameters([List? parameters]) => TLowerCase(parameters);

  @override
  String? computeOperation(Object? json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return s.toLowerCase();
  }
}

/// Converts JSON node to an Upper Case [String].
class TUpperCase extends TOperation {
  static final String NAME = 'uc';

  TUpperCase([List? parameters]) : super(NAME, false, parameters);

  TUpperCase._register() : super._register(NAME);

  @override
  TUpperCase fromParameters([List? parameters]) => TUpperCase(parameters);

  @override
  String? computeOperation(Object? json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String;
    return s.toUpperCase();
  }
}

/// Converts JSON node encoding to a JSON [String].
///
/// Parameters:
/// - withIndent: If [true] encodes with indentation.
class TEncodeJSON extends TOperation {
  static final String NAME = 'encodeJson';

  TEncodeJSON([List? parameters]) : super(NAME, true, parameters);

  TEncodeJSON._register() : super._register(NAME);

  @override
  TEncodeJSON fromParameters([List? parameters]) => TEncodeJSON(parameters);

  @override
  String computeOperation(Object? json) {
    if (json == null) return 'null';
    var withIndent = getParameter(0, false, parseBool)!;
    return encodeJSON(json, withIndent: withIndent);
  }
}

/// Converts JSON node decoding to a JSON tree.
class TDecodeJSON extends TOperation {
  static final String NAME = 'decodeJson';

  TDecodeJSON([List? parameters]) : super(NAME, true, parameters);

  TDecodeJSON._register() : super._register(NAME);

  @override
  TDecodeJSON fromParameters([List? parameters]) => TDecodeJSON(parameters);

  @override
  String? computeOperation(Object? json) {
    if (json == null) return null;
    var s = TAsString(parameters).transform(json) as String?;
    return parseJSON(s);
  }
}

/// Converts JSON node to a [String].
///
/// Parameters:
/// - delimiter: The delimiter to use for [List.join] if needed.
class TAsString extends TOperation {
  static final String NAME = 'asString';

  TAsString([List? parameters]) : super(NAME, true, parameters);

  TAsString._register() : super._register(NAME);

  @override
  TAsString fromParameters([List? parameters]) => TAsString(parameters);

  @override
  String? computeOperation(Object? json) {
    if (json == null) {
      return '';
    } else if (json is String) {
      return json;
    } else if (json is List) {
      var delimiter = getParameter(0, '')!;
      return json.join(delimiter);
    } else if (json is Map) {
      var delimiterK = getParameter(0, '');
      var delimiterV = getParameter(1, '')!;
      return json.entries
          .map((e) => '${e.key}$delimiterK${e.value}')
          .join(delimiterV);
    } else {
      return parseString(json);
    }
  }
}

/// Converts JSON node, splitting to a [List<String>].
///
/// Parameters:
/// - delimiter: The delimiter [RegExp] for split call.
/// - limit: The split limit (optional).
class TSplit extends TOperation {
  static final String NAME = 'split';

  TSplit([List? parameters]) : super(NAME, false, parameters);

  TSplit._register() : super._register(NAME);

  @override
  TSplit fromParameters([List? parameters]) => TSplit(parameters);

  @override
  dynamic computeOperation(Object? json) {
    var s = TAsString(subParameters(2)).transform(json) as String;

    var delimiter = getParameter(0, null, (v) => parseString(v)!);
    var limit = getParameter(1, null, (v) => parseInt(v)!);

    var pattern =
        delimiter != null ? RegExp(delimiter) : _LIST_DELIMITER_PATTERN;

    return split(s, pattern, limit);
  }
}

/// Converts JSON node to a [MapEntry].
class TMapEntry extends TOperation {
  static final String NAME = 'mapEntry';

  TMapEntry([List? parameters]) : super(NAME, false, parameters);

  TMapEntry._register() : super._register(NAME);

  @override
  TMapEntry fromParameters([List? parameters]) => TMapEntry(parameters);

  @override
  MapEntry? computeOperation(Object? json) {
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
        var keyName = getParameter(0);
        var valName = getParameter(1);

        if (keyName == null || valName == null) {
          var keys = json.keys.toList();

          if (keyName != null) {
            keys.remove(keyName);
          }

          if (valName != null) {
            keys.remove(valName);
          }

          keyName ??= keys.removeAt(0);
          valName ??= keys.removeAt(0);
        }

        var key = _resolveMapValue(json, keyName);
        var val = _resolveMapValue(json, valName);

        return MapEntry(key, val);
      }
    } else {
      return MapEntry('/', json);
    }
  }

  dynamic _resolveMapValue(Map json, Object key) {
    if (key is JSONTransformer) {
      return key.transform(json);
    } else {
      var keyName = parseString(key);
      return json[keyName];
    }
  }
}

class TAsList extends TOperation {
  static final String NAME = 'asList';

  TAsList([List? parameters]) : super(NAME, true, parameters);

  TAsList._register() : super._register(NAME);

  @override
  TAsList fromParameters([List? parameters]) => TAsList(parameters);

  @override
  List? computeOperation(Object? json) {
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

  TAsMap([List? parameters]) : super(NAME, true, parameters);

  TAsMap._register() : super._register(NAME);

  @override
  TAsMap fromParameters([List? parameters]) => TAsMap(parameters);

  @override
  Map? computeOperation(Object? json) {
    if (json == null) {
      return {};
    } else if (json is Iterable) {
      var tMapEntry = TMapEntry(parameters);
      var entries = json
          .map((e) => tMapEntry.transform(e) as MapEntry?)
          .whereType<MapEntry>()
          .toList();
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

T? _getIndexValue<T>(List<T> list, int index) {
  if (list.isEmpty) return null;
  var length = list.length;

  if (index >= length) {
    index = length - 1;
  } else if (index < 0) {
    index = length + index;
  }

  return list[index];
}

V? _getKeyValue<K, V>(Map<K, V> map, K key) {
  if (map.isEmpty) return null;

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
