# V5 validation and product parity

## Scope

Native SwiftUI / Canvas presentation rebuild. No new dependencies. Signing, URL schemes, MaxLab, persistence schema and repository layout are unchanged. The only domain extension is reversible historical completion, guarded to past local days. Completion uniqueness and derived streak/level/XP semantics remain intact.

## Product parity

| Capability | Gamefy | Reset |
| --- | --- | --- |
| Today interaction | Rightward duvet pull | Rightward desktop sweep |
| Cancelled/vertical drag | No completion; progress resets | Same |
| Accessible completion | VoiceOver action on habit object | Same |
| Companion tap | Alternating curiosity/stretch or celebration/pride | Same |
| Seven-day history | Tappable, today emphasized | Same source |
| See more / Show week | Expand to last 28 days and collapse | Same source |
| Past day | Detail, confirmed add and confirmed removal | Same source |
| Today / future in history | Informational only | Same source |
| Today undo | Existing undo action | Existing undo action |
| Progression | Plant at 5, print at 10, reading detail at 15 | Plant at 5, print at 10, bookshelf at 15 |
| Short-term challenge | Seven total mornings | Seven total resets |
| Metrics | Streak, best streak, level, XP | Streak, best streak, level; intentionally no XP |
| Navigation | Today / Progress / Settings | Same |
| Light / dark | Morning blue / dawn blue | Calm green / evening teal |

`WorldPrimitives.swift`, `HistoryPresentation.swift`, and `SceneInteraction.swift` are identical in the independently vendored foundation targets. Domain types and product art remain app-owned. This avoids a new cross-repository dependency and does not duplicate domain code.

## Verification

Xcode 26.6, iOS Simulator 26.5. iPhone 17-size Simulator. 5 core tests pass. UI automation also starts vertical drags inside the actual habit object at accessibility text sizes, then asserts the lower instruction is reachable. It exercises real drags, short-pull cancellation, completion, undo, calendar expansion/collapse, confirmed add/remove, and date protection. Gamefy also tests rollback on failed historical removal. Reset history add/remove recalculates its existing derived snapshot.

The captured matrix in [qa/v5](qa/v5) covers light/dark Today before and after; companion reaction; compact/expanded history; add/remove detail; future protection; milestone detail; lower progression objects; onboarding; Settings; and accessibility-size text. The midpoint capture explicitly uses a debug-only 55% presentation fixture; it is not a captured physical finger gesture. Real drag behavior is exercised separately by UI tests.

The screenshot review led to fixes for compressed room proportions, unsupported furniture, low-contrast onboarding buttons, sheet background coverage, singular counts, calendar sizing and vertical scrolling through the gesture region. At accessibility sizes, the day strip scrolls horizontally, titles/metrics reflow, and the main pages scroll vertically. Expanded history adapts its column count to readable touch targets.

## Limits

No physical-device 60/120 Hz, tactile haptic, VoiceOver spoken-output or Instruments battery profiling was performed. Idle animation uses cancellable irregular tasks rather than a frame timer; Reduce Motion disables expressive transforms and idle tasks. Sound remains intentionally absent. Artwork is original maintainable vector composition; a dedicated illustrator could refine texture and pose transitions further without replacing domain behavior.

Pre-existing local Xcode project edits were preserved and excluded from V5 commits.
