# V6 focused design plan

Research reviewed before implementation (27 September 2026):
- [Prism](https://github.com/aheze/Prism): spatial hierarchy, consistent perspective and grounded shadows; preserve our native Canvas artwork rather than add a renderer.
- [HorizonCalendar](https://github.com/airbnb/HorizonCalendar): separation of calendar content and interaction; preserve the approved calendar and concentrate on its surrounding composition.
- [ScreenPets](https://github.com/sealovesky/ScreenPets): contextual character presence; retain Mochi's existing irregular, lifecycle-aware behavior rather than introduce continuous frame timers.
- [Apple gestures guidance](https://developer.apple.com/design/human-interface-guidelines/gestures): expose direction at the object and retain an accessible alternative.

Decisions:
1. Continue the existing wall behind the greeting and the floor beneath the status/rewards. Extend floorboard perspective into the foreground. No new containers or replacement illustration style.
2. Place a grip, short directional trace and concise instruction on the duvet/desktop. Hide the cue as the user takes over. Preserve drag recognition and completion thresholds.
3. Frame existing 5/10/15 rewards as the next change to the room/workspace. Explain that any recorded days count, with no new rules.
4. Center history details in the available sheet and anchor its actions consistently. Use an inline confirmation at the same detent rather than presenting a second action sheet. Keep add/remove/error behavior unchanged.
5. Validate light/dark, completion, Progress, history confirmation/cancel/save and accessibility text using native Simulator captures.

No weather data, sound, dependencies, domain or persistence changes. Existing colors, typography, Mochi and calendar layout remain the foundation.
