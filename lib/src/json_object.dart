import 'dart:convert';

import "json_object_generic.dart"
if (dart.library.html) "json_object_html.dart"
if (dart.library.io) "json_object_mirror.dart" ;

abstract class JSONObject extends JSONObjectBaseImpl {

  String toJSON() {
    var jsonObject = toMap();
    var json = jsonEncode(jsonObject);
    return json;
  }

  Map toMap() {
    Map jsonMap = {} ;

    var fields = this.getObjectFields() ;
    var fieldsValues = this.getObjectValues() ;

    var fieldsValuesLength = fieldsValues.length;

    for (var i = 0; i < fields.length; ++i) {
      var k = fields[i];
      var v = i < fieldsValuesLength ? fieldsValues[i] : null ;
      jsonMap[k] = v ;
    }

    return jsonMap;
  }

  void initializeFromMap(Map jsonMap) {
    var fields = this.getObjectFields() ;

    List values = [] ;

    for (var k in fields) {
      var v = jsonMap[k] ;
      values.add(v) ;
    }

    this.setObjectValues(values) ;
  }

  void initializeFromJSON(String json) {
    var obj = jsonDecode(json);
    initializeFromMap(obj);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JSONObject &&
          runtimeType == other.runtimeType &&
          toJSON() == other.toJSON();

  @override
  int get hashCode => toJSON().hashCode;

}

