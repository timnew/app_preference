typedef NullableStringSerializer<T> = String? Function(T value);
typedef NullableStringDeserializer<T> = T Function(String? data);

typedef JsonSerializer<T> = Map<String, dynamic> Function(T value);
typedef JsonDeserializer<T> = T Function(Map<String, dynamic> jsonObject);
