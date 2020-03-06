import 'dart:mirrors';

import 'json_object_base.dart';

abstract class JSONObjectBaseImpl extends JSONObjectBase {

  static List<String> _getObjectFieldsNames(JSONObjectBase instance) {
    try {
      List<String> names = [] ;

      InstanceMirror instanceMirror = reflect(instance);
      ClassMirror classMirror = instanceMirror.type;

      var declarations = classMirror.declarations.values.whereType<VariableMirror>();

      declarations.forEach((declarationMirror) {
        var key = MirrorSystem.getName(declarationMirror.simpleName);
        names.add("$key");
      });

      return names ;
    }
    catch (e,s) {
      print(e);
      print(s);

      return null ;
    }
  }

  static List _getObjectFieldsValues(JSONObjectBase instance) {
    try {
      List values = [] ;

      InstanceMirror instanceMirror = reflect(instance);
      ClassMirror classMirror = instanceMirror.type;

      var declarations = classMirror.declarations.values.whereType<VariableMirror>();

      declarations.forEach((declarationMirror) {
        //var key = MirrorSystem.getName(declarationMirror.simpleName);
        var val = instanceMirror.getField(declarationMirror.simpleName).reflectee;
        values.add(val);
      });

      return values ;
    }
    catch (e,s) {
      print(e);
      print(s);

      return null ;
    }
  }

  static bool _setObjectFieldsValues(JSONObjectBase instance, List values) {
    try {
      InstanceMirror instanceMirror = reflect(instance);
      ClassMirror classMirror = instanceMirror.type;

      Iterable<VariableMirror> declarations = classMirror.declarations.values.whereType() ;

      int i = 0;
      for (var declarationMirror in declarations) {
        Symbol fieldSymbol = declarationMirror.simpleName;
        //var key = MirrorSystem.getName(fieldSymbol);
        var val = values[i];
        instanceMirror.setField(fieldSymbol, val);
        i++;
      }

      return true ;
    }
    catch (e,s) {
      print(e);
      print(s);
      return false ;
    }
  }

  //////////////////////////////////////////////////////

  List<String> getObjectFieldsDefault() {
    return _getObjectFieldsNames(this);
  }
  
  List getObjectValues() {
    return _getObjectFieldsValues(this);
  }

  void setObjectValues(List values) {
    _setObjectFieldsValues(this, values) ;
  }

}

