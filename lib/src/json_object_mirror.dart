import 'dart:mirrors';

import 'json_object_base.dart';

abstract class JSONObjectBaseImpl extends JSONObjectBase {
  static List<String> _getObjectFieldsNames(JSONObjectBase instance) {
    try {
      var names = <String>[];

      var instanceMirror = reflect(instance);
      var classMirror = instanceMirror.type;

      var declarations =
          classMirror.declarations.values.whereType<VariableMirror>();

      declarations.forEach((declarationMirror) {
        var key = MirrorSystem.getName(declarationMirror.simpleName);
        names.add(key);
      });

      return names;
    } catch (e, s) {
      print(e);
      print(s);

      return null;
    }
  }

  static List _getObjectFieldsValues(JSONObjectBase instance) {
    try {
      var values = [];

      var instanceMirror = reflect(instance);
      var classMirror = instanceMirror.type;

      var declarations =
          classMirror.declarations.values.whereType<VariableMirror>();

      declarations.forEach((declarationMirror) {
        //var key = MirrorSystem.getName(declarationMirror.simpleName);
        var val =
            instanceMirror.getField(declarationMirror.simpleName).reflectee;
        values.add(val);
      });

      return values;
    } catch (e, s) {
      print(e);
      print(s);

      return null;
    }
  }

  static bool _setObjectFieldsValues(JSONObjectBase instance, List values) {
    try {
      var instanceMirror = reflect(instance);
      var classMirror = instanceMirror.type;

      var declarations =
          classMirror.declarations.values.whereType<VariableMirror>();

      var i = 0;
      for (var declarationMirror in declarations) {
        var fieldSymbol = declarationMirror.simpleName;
        //var key = MirrorSystem.getName(fieldSymbol);
        var val = values[i];
        instanceMirror.setField(fieldSymbol, val);
        i++;
      }

      return true;
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  @override
  List<String> getObjectFieldsDefault() {
    return _getObjectFieldsNames(this);
  }

  @override
  List getObjectValues() {
    return _getObjectFieldsValues(this);
  }

  @override
  void setObjectValues(List values) {
    _setObjectFieldsValues(this, values);
  }
}
