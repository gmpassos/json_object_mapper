import 'json_object_base.dart';

abstract class JSONObjectBaseImpl extends JSONObjectBase {
  @override
  List<String> getObjectFieldsDefault() {
    return [];
  }

  @override
  List getObjectValues() {
    return [];
  }

  @override
  void setObjectValues(List values) {}
}
