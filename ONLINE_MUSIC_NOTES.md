# HQ Audio integration

The online tab uses the HQ Audio service at:

- API base: `https://hqaudio.suvojeetsengupta.in`
- Interactive documentation: `https://hqaudio.suvojeetsengupta.in/docs/`

The client accepts `HQAUDIO_API_BASE_URL` and `HQAUDIO_SEARCH_PATH` through
`--dart-define` so the endpoint can be changed without editing Dart source.

Example:

```bash
flutter run \
  --dart-define=HQAUDIO_API_BASE_URL=https://hqaudio.suvojeetsengupta.in \
  --dart-define=HQAUDIO_SEARCH_PATH=/search
```

The response parser supports common list wrappers (`data`, `results`, `songs`,
`tracks`, and `items`) and common stream URL fields in both camelCase and
snake_case. Online tracks are resolved again if a previously saved stream URL
has expired.
