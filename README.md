# Reset

Reset is a focused iPhone app for one small daily ritual: reset your desk. Clear the cups and clutter, then swipe across the confirmation control. A clean surface becomes a calmer start, and consistency grows a more pleasant workspace scene.

## Development

```sh
swift test
xcodebuild -project Reset.xcodeproj -scheme Reset -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

The app is local-first, account-free and iPhone-only. Its custom URL scheme is `reset://` for MaxLab.
