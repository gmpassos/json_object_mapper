
import 'json_object_base.dart';

abstract class JSONObjectBaseImpl extends JSONObjectBase {

  List<String> getObjectFieldsDefault() {
    return [] ;
  }

  List getObjectValues() {
    return [] ;
  }

  void setObjectValues(List values) {

  }

}

