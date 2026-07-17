# Online music integration

This build adds a private-use JioSaavn-compatible search and stream page.
The configured default endpoint is an unofficial API and can stop working or
change without notice. No offline downloading is implemented.

Override the endpoint when running or building:

```bash
flutter run --dart-define=JIOSAAVN_API_BASE_URL=https://your-endpoint.example
```

The app code and original interface may belong to the app owner. Music,
artwork, metadata, artist names, and third-party services remain the property
of their respective rights holders.
