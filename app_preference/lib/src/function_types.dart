/// Serialize a value to a string or null
typedef RawValueSerializer<T> = String? Function(T value);

/// Deserialize a string or null to a value.
typedef RawValueDeserializer<T> = T Function(String? data);

/// Serialize a value to a json object.
typedef JsonSerializer<T> = Map<String, dynamic> Function(T value);

/// Deserialize a json object to a value.
typedef JsonDeserializer<T> = T Function(Map<String, dynamic> jsonObject);

/// Predict if a certain criteria is met.
typedef Predict<T> = bool Function(T value);

/// A listener that is called when a value is changed.
typedef ValueListener<T> = void Function(T value);

/// A listener that is called when an error occurs.
typedef ErrorListener = void Function(
    String message, Object error, StackTrace? stackTrace);
