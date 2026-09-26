# Reset architecture

`ResetCore` owns the one SwiftData model (`ResetRecord`), local-date uniqueness and derived streak/level progression. `ResetApp` owns SwiftUI presentation, onboarding, haptics and navigation. AppFoundation supplies generic adaptive surfaces and tokens. The custom URL scheme is an app-shell concern and does not enter the core module.
