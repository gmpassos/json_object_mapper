import 'dart:convert';

import 'json_object_generic.dart'
    if (dart.library.html) 'json_object_html.dart'
    if (dart.library.io) 'json_object_mirror.dart';

/// Base class for an [Object] that can be converted to JSON.
abstract class JSONObject extends JSONObjectBaseImpl {
  /// Converts [this] instance to a JSON String.
  String toJson() {
    var jsonObject = toMap();
    var json = jsonEncode(jsonObject);
    return json;
  }

  /// Converts [this] instance to a [Map<String,dynamic>], containing
  /// the current fields values.
  Map<String, dynamic> toMap() {
    var jsonMap = <String, dynamic>{};

    var fields = getObjectFields();
    var fieldsValues = getObjectValues();

    var fieldsValuesLength = fieldsValues.length;

    for (var i = 0; i < fields.length; ++i) {
      var k = fields[i];
      var v = i < fieldsValuesLength ? fieldsValues[i] : null;
      jsonMap[k] = v;
    }

    return jsonMap;
  }

  /// Initializes this instance from a Map.
  void initializeFromMap(Map? jsonMap) {
    var fields = getObjectFields();

    var values = [];

    for (var k in fields) {
      var v = jsonMap![k];
      values.add(v);
    }

    setObjectValues(values);
  }

  /// Initializes this instance from a JSON String.
  void initializeFromJson(String json) {
    var obj = jsonDecode(json);
    initializeFromMap(obj);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JSONObject &&
          runtimeType == other.runtimeType &&
          toJson() == other.toJson();

  @override
  int get hashCode => toJson().hashCode;
}
