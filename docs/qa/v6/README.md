# V6 native visual review

Captured on iPhone 17, iOS 26.5 Simulator. These are native app captures, not mockups.

| State | Evidence |
| --- | --- |
| Today, light | [Before](light-today-before.png) · [Completed](light-today-after.png) |
| Today, dark | [Before](Dark-before.png) · [Completed](Dark-after.png) |
| Progress | [Light](light-progress.png) · [Dark](Dark-progress-overview.png) |
| Progression foreground | [Next reward and ritual](progress-rewards.png) |
| Expanded calendar | [History](expanded-history.png) |
| History edit | [Add](history-add.png) · [Completed date](history-remove.png) |
| Stable removal flow | [Confirmation](history-remove-confirmation.png) · [After removal](history-removed.png) |
| Dark date detail | [Detail](Dark-today-detail.png) |
| Accessibility text | [Today](accessibility-today.png) · [Scrolled instruction](accessibility-instruction.png) |

Review focus: continuous wall/floor across Today and Progress; no highlighted scene container; readable object-anchored gesture hints; full room illustrations rather than cropped window edges; next unlock emphasis; stable sheet height and action position through confirmation/cancellation/removal.

Existing UI workflows exercise real short/cancelled drags, full completion, today undo, calendar expansion/collapse, historical add/remove, removal cancellation, future protection, milestone interaction and vertical scrolling starting on the ritual surface. The history workflow asserts that the edit action does not move vertically through confirmation and removal.

No physical-iPhone haptic/refresh-rate test or spoken VoiceOver audit was performed. No sound or runtime dependency was added. See [design decisions and references](../../V6-DESIGN.md).
