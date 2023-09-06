typedef RawValueSerializer<T> = String? Function(T value);
typedef RawValueDeserializer<T> = T Function(String? data);

typedef JsonSerializer<T> = Map<String, dynamic> Function(T value);
typedef JsonDeserializer<T> = T Function(Map<String, dynamic> jsonObject);

typedef Predict<T> = bool Function(T value);
typedef ValueListener<T> = void Function(T value);
typedef ErrorListener = void Function(String message, Object error, StackTrace? stackTrace);
