# V7 — research and implementation plan

Reviewed 28 September 2026 before implementation.

## References
- [Finch](https://finchcare.com): the care relationship makes a small action emotionally meaningful; character response is the reward's focal point.
- [Plant Nanny](https://sparkful.app/plant-nanny): visible growth and a collection of future environmental rewards make repetition tangible.
- [Waterful](https://waterfulapp.com): a companion and short challenges support a fast daily action. Adopt concise feedback, not its branding or health claims.
- [Open SwiftUI Animations](https://github.com/amosgyamfi/open-swiftui-animations): inspected `JumpAndFallWithKeyframes.swift` and `SlideWithSpring.swift`. Adopt finite, event-triggered transform tracks. Reject extreme squash/stretch, hue cycling, per-letter shimmer and forever timers.
- [HorizonCalendar](https://github.com/airbnb/HorizonCalendar): selection and semantic date states remain separate from decoration. Preserve our existing calendar; no dependency.
- [Apple motion guidance](https://developer.apple.com/design/human-interface-guidelines/motion) and [keyframe animator](https://developer.apple.com/documentation/swiftui/view/keyframeanimator(initialvalue:trigger:content:keyframes:)): motion should explain the result of an action, with a static equivalent for Reduce Motion.

These are public product/reference reviews, not hands-on competitive usability tests. No proprietary art or copy is imported.

## Decisions
1. Keep V6 scenes, semantic palettes and native type roles. Remove repeated instructions below the scene; one short on-object cue carries direction.
2. Use sparse, cancellable cue/window motion, finite companion reactions and a brief completion flourish. No render-loop timers, audio dependency or weather permissions.
3. Fix Mochi press opacity, use one 150:160 artboard ratio at all sizes, and use a bounded nod/hop rather than stretched rendering.
4. Show earned/next/later physical objects with five milestones at 5/10/15/20/30 completions. Derive visual unlocks from existing levels/counts; no new persistent state or economy. Add the last two objects to both actual environments.
5. Shorten Progress header; retain week/expanded history. Make the next reward conspicuous and preview every future item with an illustrated detail sheet.
6. Center historical day identity/status together, anchor actions consistently, reserve confirmation footprint, and use a larger useful detent with scrolling at accessibility sizes.
7. Validate both products with actual Simulator gestures, light/dark screenshots, history add/remove/cancel, future protection, large text, reward previews and Reduce Motion. Mid-gesture debug fixture is supplemental, not proof of frame rate.
