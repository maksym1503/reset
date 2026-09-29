# V7 visual and interaction QA

Reviewed native iOS 26.5 Simulator captures on 28–29 September 2026, using Xcode 26.6. Gamefy: iPhone 13 mini. Reset: iPhone 17. Disposable simulators only; UI tests reset their sample history.

## Evidence

| State | Captures |
| --- | --- |
| Today before / after | [Light before](Light-before.png), [Light after](Light-after.png), [Dark before](Dark-before.png), [Dark after](Dark-after.png) |
| During interaction | [55% gesture fixture](dark-gesture-midpoint-fixture.png) |
| Progress | [Light](Light-progress-overview.png), [Dark](Dark-progress-overview.png), [Mochi and next reward](progress-mochi.png) |
| Expanded history | [Light](Light-expanded.png), [Dark](Dark-expanded.png) |
| Historical editing | [Add](history-add.png), [Remove](history-remove.png), [Confirmation](history-remove-confirmation.png), [Removed](history-removed.png) |
| Collection | [Today preview](today-reward-detail.png), [Later rewards](later-rewards.png), [Window garden](window-garden-detail.png) |
| Accessibility text size 3 | [Today](accessibility-today.png), [Scrolled content](accessibility-instruction.png), [Progress](accessibility-progress.png) |

Screenshots were opened and inspected, not just exported. Recorded sequences of actual XCTest drags were also sampled to inspect the scene transformation, raised-arm reaction and settled pose. The 55% still is explicitly a debug fixture; it is not a recording of touch tracking. It predates the final cloud contour adjustment, which does not affect the gesture state.

## Findings addressed

- Removed repeated Today instruction/status paragraphs in favor of one cue and an illustrated next object.
- Moved Reset's white sweep cue onto the desk apron, clear of the pen and loose papers.
- Bounded visual cue Dynamic Type to prevent it crowding the artwork; the accessible action retains its full label/hint. Product text continues to scale and scroll.
- Fixed companion press dimming and removed implicit mood-wide Canvas animation. The 150:160 companion artboard is fitted consistently, with finite transform reactions.
- Preserved the environment's aspect ratio on Progress instead of compressing furniture vertically.
- Surfaced the next unlock above the scene; collection previews and seven stitched leaves use the lower floor area.
- Rebalanced date sheets, corrected weekday/month ordering and reserved the confirmation footprint. UI assertions verify that the edit button does not jump when confirming, cancelling or removing.

## Parity

Both apps: immediate horizontal ritual gesture; natural cancellation; Today undo; week/28-day history; past add/remove with confirmation; future/today protection; five unlocks at 5/10/15/20/30 completions; reward previews from Today and Progress; tappable Mochi on both screens; light/dark and accessibility layouts.

Intentional differences: bedroom vs workspace; pulling vs sweeping; morning vs calm palette; woven throw vs daybook at 20; Gamefy's existing XP display. Rules and persistence are unchanged.

## Validation and limits

- `./dev check` passes in both repos (Gamefy 10 core tests plus tooling checks; Reset 5 core tests; unsigned Simulator builds).
- Five UI workflows pass per app. Targeted visual/reward reruns pass after screenshot-driven refinements.
- Reviewed short recorded Simulator sequences for motion; no physical-iPhone haptic or 120 Hz measurement is claimed.
- Reduce Motion disables cue travel, window drift, companion idle/transform motion and moving completion particles. Sheet/background/disappearance lifecycle gates suspend the relevant tasks.
- No spoken VoiceOver audit or long-term battery profile. The largest text sizes intentionally require scrolling; the collection changes to a vertical layout.
- No sound, weather service, location permission, new runtime dependency or persisted unlock state.

Reset Reduce Motion: enabled the Simulator accessibility preference, relaunched, and compared two separated captures. Scene pixels stayed identical; [static appearance](reduce-motion.png) inspected. Restored the setting afterwards.
