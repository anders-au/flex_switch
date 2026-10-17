# Flex Switch example

The showcase exercises boolean, enum, custom-option, and arbitrary-value
controls. Its settings demonstrate disabled options, RTL layout, drag commit
policies, thumb-only dragging, proportional widths, dividers, and ripple styles.
The enum control switches the app between system, light, and dark themes.

Run it from this directory:

```sh
flutter pub get
flutter run -d macos
# Or use Chrome:
flutter run -d chrome
```

The integration test operates the actual showcase and verifies controlled values,
rendered themes, proportional segment geometry, keyboard navigation, RTL,
semantics actions, disabled inputs, drag timing and cancellation, and style
changes. Run it on macOS:

```sh
flutter test integration_test/showcase_test.dart -d macos
```

For the WebAssembly browser path, start a ChromeDriver version compatible with
Chrome on port 4444, then run:

```sh
flutter drive -d web-server --wasm \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/showcase_test.dart \
  --browser-name=chrome --headless
```

The repository's CI repeats these desktop and browser checks.
