bool isSameType<T1, T2>() => T1 == T2;
bool isSameTypeOrNullable<T1, T2>() => isSameType<T1, T2>() || isSameType<T1, T2?>();
