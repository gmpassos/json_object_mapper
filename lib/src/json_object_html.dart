
import 'dart:js';
import 'dart:js_util';
import 'dart:math';

import 'json_object_base.dart';

abstract class JSONObjectBaseImpl extends JSONObjectBase {

  static bool _initializedJS = false ;

  static void _initializeJS() {
    if (_initializedJS) return ;
    _initializedJS = true ;

    context.callMethod('eval', ['''
    
    function _JsonObject_get_fields_keys(obj) {    
        var o = obj.o ;
        
        if (o == null) {
          return null ;
        }
        
        var keys = Object.keys(o);
        
        var keys2 = [] ;
        
        for (var i = 0; i < keys.length; i++) {
          var k = keys[i];
          if ( /^\\w+\$/.test(k) ) { 
            keys2.push(k);
          }
        }
        
        return keys2 ;
    }
    
    function _JsonObject_get_fields_values(obj) {    
        var o = obj.o ;
        
        if (o == null) {
          return null ;
        }
        
        var keys = _JsonObject_get_fields_keys(o);
        
        var values = [] ;
        
        for (var i = 0; i < keys.length; i++) {
          var k = keys[i] ; 
          var v = o[k] ;
          values.push(v) ;
        }
        
        return values ;
    }
    
    function _JsonObject_set_fields_values(obj, values) {   
        var o = obj.o ;
        if (o == null) return null ;
             
        var sz = values.length ;
        
        var keys = _JsonObject_get_fields_keys(o);
        
        for (var i = 0; i < sz; i++) {
          var k = keys[i];
          var v = values[i] ;
          
          o[k] = v ;
        }
        
        return keys ;
    }
    
    ''']);
  }

  //////////////////////////////////////////////////////////////////////////////

  static List _getObjectFieldsNames(JSONObjectBase instance) {
    _initializeJS();
    _checkObjectType(instance);

    return _getObjectFieldsNamesImpl(instance);
  }

  static List _getObjectFieldsNamesImpl(JSONObjectBase instance) {
    try {
      List fieldsKeys = context.callMethod('_JsonObject_get_fields_keys', [instance]);

      if (fieldsKeys == null) {
        fieldsKeys = instance.getObjectFields();
      }

      return fieldsKeys ;
    }
    catch (e,s) {
      print(e);
      print(s);

      throw StateError("Can't get fields keys using JS or Mirrors: $instance") ;
    }
  }

  static List _getObjectFieldsValues(JSONObjectBase instance) {
    _initializeJS();
    _checkObjectType(instance);

    return _getObjectFieldsValuesImpl(instance);
  }

  static List _getObjectFieldsValuesImpl(JSONObjectBase instance) {
    try {
      var fieldsValues = context.callMethod('_JsonObject_get_fields_values', [instance]);

      if (fieldsValues == null) {
        List fields = instance.getObjectFields();

        fieldsValues = [] ;

        fields.forEach( (f) {
          var v = getProperty(instance, f) ;
          fieldsValues.add(v);
        }) ;
      }

      return fieldsValues ;
    }
    catch (e,s) {
      print(e);
      print(s);

      throw StateError("Can't get fields values using JS or Mirrors: $instance") ;
    }
  }

  static void _setObjectFieldsValues(JSONObjectBase instance, List values) {
    _initializeJS();
    _checkObjectType(instance);

    _setObjectFieldsValuesImpl(instance, values);
  }

  static void _setObjectFieldsValuesImpl(JSONObjectBase instance, List values) {
    try {
      var jsValues = JsObject.jsify(values);
      var keys = context.callMethod('_JsonObject_set_fields_values', [instance, jsValues]);

      if (keys == null) {
        List fields = instance.getObjectFields();

        for (var i = 0; i < fields.length; ++i) {
          var k = fields[i];
          var v = values[i];
          setProperty(instance, k, v) ;
        }
      }

    }
    catch (e,s) {
      print(e);
      print(s);

      throw StateError("Can't set field values using JS: $instance ; $values") ;
    }
  }

  static final Map<String,bool> _checkedObjectTypes = {} ;

  static bool _checkObjectType(JSONObjectBase instance) {
    String runtimeType = "${ instance.runtimeType }";

    bool check = _checkedObjectTypes[runtimeType];
    if ( check != null ) return check ;

    String checkError = _isValidObjectType(instance) ;

    check = checkError == null ;

    _checkedObjectTypes[runtimeType] = check ;

    if (!check) {
      throw StateError("Not a valid JsonObject type '$runtimeType': $checkError") ;
    }

    return check ;
  }

  static String _isValidObjectType(JSONObjectBase instance) {
    List fields = instance.getObjectFields();
    if (fields == null) return 'null fields' ;

    List values = _getObjectFieldsValuesImpl(instance);
    if (values == null) return 'null values' ;

    if (fields.length != values.length) return 'fields.length != values.length' ;

    List checkValues1 = [] ;
    List checkValues2 = [] ;

    var random = Random();

    for (int i = 0; i < values.length; i++) {
      var v = random.nextInt(999999)*100+i;
      checkValues1.add(v);
      checkValues2.add(v);
    }

    _setObjectFieldsValuesImpl(instance, checkValues1) ;

    List checkValues3 = _getObjectFieldsValuesImpl(instance) ;

    if ( !_isEqualsList(checkValues2, checkValues3) ) return 'check values error' ;

    _setObjectFieldsValuesImpl(instance, values) ;

    return null ;
  }

  static bool _isEqualsList(List l1, List l2) {
    if (l1 == l2) return true ;

    if (l1 == null) return false ;
    if (l2 == null) return false ;

    if ( l1.length != l2.length ) return false ;

    for (var i = 0; i < l1.length; ++i) {
      var v1 = l1[i];
      var v2 = l2[i];
      if (v1 != v2) return false ;
    }

    return true ;
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

