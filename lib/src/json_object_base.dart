/// Basic methods to handle a JSON [Object].
abstract class JSONObjectBase {
  /// Returns the names of the fields of this class.
  ///
  /// This method should be overwritten if you want to explicitly define
  /// the JSON fields.
  ///
  /// Bu default it uses [getObjectFieldsDefault] implementation.
  List<String> getObjectFields() {
    return getObjectFieldsDefault();
  }

  /// Default implementation of [getObjectFields].
  List<String> getObjectFieldsDefault();

  /// Returns the values of the fields of this instance,
  /// in the same order of fields from [getObjectFields].
  List getObjectValues();

  /// Sets this instances fields with [values],
  /// in the same order of fields from [getObjectFields].
  void setObjectValues(List values);
}
