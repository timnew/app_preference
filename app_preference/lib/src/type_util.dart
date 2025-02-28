/// Check if two type parameters are the same type.
bool isSameType<T1, T2>() => T1 == T2;

/// Check if two type parameters are the same type or nullable of the same type.
bool isSameTypeOrNullable<T1, T2>() =>
    isSameType<T1, T2>() || isSameType<T1, T2?>();
