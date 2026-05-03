# Integration Tests

## Running Tests

### Windows
```
flutter test integration_test/app_test.dart -d windows
```

### Android
```
flutter test integration_test/app_test.dart -d <device_id>
```

## Notes
- Integration tests require a connected device or emulator
- The `integration_test` package must be in pubspec.yaml dev_dependencies
