# app_preference

[![Star this Repo](https://img.shields.io/github/stars/timnew/app_preference)](https://github.com/timnew/app_preference)
[![Pub Package](https://img.shields.io/pub/v/app_preference)](https://pub.dev/packages/app_preference)
[![Build Status](https://img.shields.io/github/actions/workflow/status/timnew/app_preference/test.yml)](https://github.com/timnew/app_preference/actions/workflows/test.yml)

Ever found yourself juggling between [shared_preferences] and [flutter_secure_storage] to manage user preferences? Or maybe you've been wrestling with inconsistent APIs, async issues, custom serialization, or unit testing? Or simply want to be reactive on preference value changes. Say hello to [app_preference], your one-stop solution for all these headaches.

## Get Started in a Flash 🚀

```
> flutter pub add shared_preferences app_preference_shared_preferences app_preference_secure_storage
```

- **shared_preferences:** The core of the library
- **app_preference_shared_preferences:** Adapter for [shared_preferences]
- **app_preference_secure_storage:** Adapter for [flutter_secure_storage]

### Effortless Preferences with [shared_preferences]

```dart
import 'package:app_preference/app_preference.dart';
import 'package:app_preference_shared_preferences/app_preference_shared_preferences.dart';

final SharedPreferences sharedPreferences = getSharedPreference();
final AppPreferenceAdapter sharedPreferencesAdapter = SharedPreferencesAdapter(sharedPreferences);

final userNamePref = AppPreference<String>.direct(
  adapter: sharedPreferencesAdapter
  key: 'user_name',
  defaultValue: '<unknown>',
);

print(userPref.value); // prints '<unknown>' if first time use or 'my_name' for returned user.

// Update the value and persisted it back to shared preferences in background.
userPref.value = 'my_name';

print(userPref.value); // prints 'my_name'
```

### Fort Knox Security with [flutter_secure_storage]

```dart
import 'package:app_preference_secure_storage/app_preference_secure_storage.dart';

final FlutterSecureStorage secureStorage = getSecureStorage();
final AppPreferenceAdapter secureStorageAdapter = SecureStorageAdapter(secureStorage)

final userTokenPref = AppPreference<String?>.direct(
  adapter: secureStorageAdapter
  key: 'user_token',
  defaultValue: null,
);

userTokenPref.value = await authenticateUser(userId, password);

await invokeApi(userToken: userTokenPref.value);
```

### Everyone loves JSON

```dart
class UserTokens {
  final String idToken;
  final String accessToken;
  final String refreshToken;

  const UserTokens(this.idToken, this.accessToken, this.refreshToken);

  factory UserTokens.fromJson(Map<String, dynamic> json) => ....
  Map<String, dynamic>  toJson() => ....

  @override
  bool operator ==(dynamic other) => ...

  @override
  int get hashCode => ...

  static const empty = UserTokens("", "", "");
}

final userTokenPref = AppPreference<UserTokens>.serialized(
  adapter: adapter
  key: 'user_tokens',
  defaultValue: UserTokens.empty,
  serializer: (tokens) => tokens.toJson(),
  deserializer: UserTokens.fromJson,
);
```

### Serialize Like a Pro 🎩

Given you want to serialize `UserTokens.empty` as `null`, which would remove the stored value.

```dart

final userTokenPref = AppPreference<UserTokens>.customSerialized(
  adapter: adapter
  key: 'user_tokens',
  serializer: (UserTokens tokens) {
    if(tokens == UserTokens.empty) {
      return null;
    } else {
      return jsonEncode(tokens.toJson());
    }
  },
  deserializer: (String? data) {
    if(data == null) {
      return UserTokens.empty;
    } else {
      return UserTokens.fromJson(jsonDecode(data!) as Map<String, dynamic>);
    }
  }
);

```

## Unleash the Power ⚡

### Async? No Sweat!

```dart
final userTokenPref = AppPreference<String?>.direct(
  adapter: secureStorageAdapter
  key: 'user_token',
  defaultValue: null,
);

await userTokenPref.ready; // wait until `flutter_secure_storage` returned the value.

print(userTokenPref.value); // Value is loaded
```

### Ensured async read

```dart
print(await userTokenPref.ensuredRead());
```

### Ensured async createion

```dart
final userTokenPref = await AppPreference<String?>.direct(
  adapter: secureStorageAdapter
  key: 'user_token',
  defaultValue: null,
).ensuredCreation();
```

## Reactivity: Your UI's Best Friend

```dart
// With Mobx
class UserNameWidget extends StatelessWidget {
  final AppPreference<String> userNamePref;

  const UserNameWidget({super.key, required this.userNamePref});

  @override
  Widget build(BuildContext context) => Observer(
    builder: (_) => Text(
      '${userNamePref.value}',
    ),
  );
}
```

```dart
// Mobx isn't an option? No problem!
class UserNameWidget extends StatelessWidget {
  final AppPreference<String> userNamePref;

  const UserNameWidget({super.key, required this.userNamePref});

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: userNamePref.valueStream()
    builder: (_, snapshot) => Text(
      '${snapshot.data}',
    ),
  );
}
```

### The magic of reaction!

```dart
late final AppPreference<UserSessions> _userSessionPref;

@override
void initState() {
  super.initState();

  _userSessionPref = getUserSessionPref();

  _userSessionPref.subscribeChanges((session) {
    // session changed!
    if(session == UserSessions.empty) {
      // Session changed to empty!;
      Navigator.restorablePushReplacementNamed(context, '/unauthorized',);
    }
  });
}
```

## Logging & Error Handling: Keep Calm and Log On

[app_preference] uses [Logging] library to do log and error reporting.

If the app uses [logging] too, nothing you need to do, the integration has been done automatically.

Or you can access the `AppPreference.logger` to more granular setup.

### We don't use `logging`

```dart
AppPreference.onLog((log) {
  print('${log.time} [${log.loggerName}](${log.level}): ${log.message})');
  if(log.error != null) print('Error: ${log.error}');
  if(log.stackTrace !=null) print('StackTrace: ${log.stackTrace}');
});
```

### Just care about error

```dart
AppPreference.onError((message, error, stackTrace) {
  Crashlytics.instance.recordError(error, stackTrace, reason: message);
});
```

[app_preference]: https://pub.dev/packages/app_preference
[flutter_secure_storage]: https://pub.dev/packages/futter_secure_storage
[shared_preferences]: https://pub.dev/packages/shared_preferences
[logging]: https://pub.dev/packages/logging
[null object pattern]: https://en.wikipedia.org/wiki/Null_object_pattern
[mobx]: https://pub.dev/packages/mobx
