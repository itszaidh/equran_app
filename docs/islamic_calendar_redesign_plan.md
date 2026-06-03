# Islamic (Hijri) Calendar Redesign Plan

**Date**: April 2026  
**Task**: Complete UI/UX overhaul of `lib/prayer/islamic_calendar_page.dart` (and supporting `hijri_calendar.dart`)  
**Status**: Fresh planning session (different task from prior Zakat work). Existing session plan files are state-only or irrelevant (Zakat).

## 1. Current State Analysis (Problems Identified)

### Core File: `lib/prayer/islamic_calendar_page.dart`
- **Stiff & Dated (2000s feel)**:
  - Raw `Card` + `GridView.builder` with fixed `childAspectRatio` (1.0 for days, 1.5 for headers).
  - Hardcoded English weekday labels ("Mon", "Tue"...).
  - Tiny fonts (12px Gregorian, 10px Hijri) in tight 2px margin cells.
  - Basic `Row` navigation with chevrons + plain text month label.
  - Top settings row is ugly: plain "Offset:" text + `DropdownButton` + "Fasting Alerts" + `Switch` crammed together.
  - No use of premium components (`EquranGradientCard`, `EquranSurfaceCard`, `EquranIconBadge`, `EquranSectionHeader`).
  - No responsiveness: fixed 7-col grid breaks on very small phones (cells too tiny) or large tablets (wasted space).
  - No animations, no delight, no Islamic visual language beyond the data.

- **Highlight Priority Bug (User's #1 Complaint)**:
  - `_getDayHighlightColor` returns strong `colors.primary` for Eids (full strength) and `primary.withAlpha(20)` / `mint.withAlpha(50/25)` for Ramadan/Ashura/Ayyam al-Bid.
  - In the grid rendering:
    - Selected day: `primary.withAlpha(40)` bg + primary border.
    - Event days often win on border color and Hijri day text color (primary for highlighted days).
    - **Result**: Important religious events (Eid especially) visually overpower the "current/today" or user-selected date. Feels wrong — today should be the strongest anchor.
  - No dedicated "today" ring/dot/badge treatment separate from selection.

- **Limited Functionality & Polish**:
  - Gregorian-month navigation only (Hijri dates overlaid). Cannot easily browse by true Hijri month.
  - Very basic occasion detection (`_getIslamicOccasion`, `_getFastingReason`) — hardcoded English strings, limited events.
  - Details card is a plain `Card` with basic text + optional star icon.
  - Fasting reminders exist but UI for them is buried in the ugly top bar.
  - No visual legend for event types.
  - No moon phases, no quick-jump to major dates (1 Ramadan, 1 Shawwal, 10 Dhu al-Hijjah, etc.).
  - Hijri helper is approximate (Meeus/Julian formula) with only -1/0/+1 sighting offset.

### Supporting: `lib/prayer/hijri_calendar.dart`
- Functional but narrow: one-way Gregorian → Hijri, English-only month names, no Arabic, no bidirectional math, no variants (Umm al-Qura, etc.).
- Used by: this page + fasting notification scheduling.

### Broader App Context (Why This Page Feels Out of Place)
From deep exploration of the codebase:
- The rest of the app (prayer times hero/thumbs, dashboard journey cards, reading plans, Zakat redesign in progress, stats) feels **premium, calm, modern Islamic**: deep teal primary (#176B55 / #1E7A61), rich `accentGold` (#D6A84F), mint/paleGreen soft accents, `Equran*` components, heavy w800/w900 typography, subtle shadows, low-opacity decorative assets, gold for "special/emphasis" (streaks, active numbers, ornaments), primary tints for current/selected states, responsive `LayoutBuilder` + breakpoints.
- **Gold is sacred for emphasis** (streaks use `goldSoft` + `accentGold` + fire icon; active diamond badges have stronger gold borders).
- Current/selected states use **primary** tints/borders/dots + stronger shadows + animation.
- Events/holidays would naturally use gold or a tasteful primary variant, but never stronger than "today".
- Rigid grids and raw Cards are anti-patterns (the old Islamic calendar and some older grids are the only offenders).

**Result**: The calendar is the weakest, most dated screen in an otherwise elegant app. It fails on small phones (critical for a mobile-first spiritual tool) and violates visual hierarchy.

## 2. Goals for the Redesign

- **World-Class Beautiful Experience**: Users should say "wow" — elegant, serene, unmistakably Islamic yet modern and delightful. Matches (and elevates) the rest of the app.
- **Fix Hierarchy**: Today/selected date is **always the strongest visual anchor**. Events are beautiful but secondary (subtle gold dots, small badges, or elegant bottom indicators that never overpower the day number or today ring).
- **Mobile-First / Small Layout Optimized**: Excellent on 320–400px widths. Adaptive cells, smart typography scaling, perhaps a compact week-strip + full month, generous touch targets (min 44–48px effective), no cramped text.
- **True Islamic Calendar Feel**:
  - Smooth month navigation (swipeable `PageView` preferred over buttons).
  - Optional true Hijri-month view or clear dual labeling.
  - Rich, accurate-feeling event highlighting with legend.
  - Moon phase indicators (simple, beautiful icons or custom paint — big Islamic touch).
  - Quick access to major blessed nights/days.
- **Premium Components Only**: Every card, badge, header must use or extend `EquranGradientCard` / `EquranSurfaceCard` / `EquranIconBadge` / proper typography.
- **Power + Ease**: Keep sighting offset + fasting reminders, but make them elegant (beautiful bottom sheet or integrated pill controls). Add "Jump to..." for Ramadan, Eid, Ashura, etc.
- **Educational & Delightful**: Tap any day for rich details (Gregorian + Hijri + occasion + fasting note + moon phase + "recommended actions"). Subtle animations (page transitions, day press scale, highlight fades).
- **Technical**: Improve `HijriCalendar` helper for Arabic names + better structure (without over-claiming astronomical accuracy). Keep backward compat for notifications.

## 3. Proposed UI/UX Architecture (High-Level)

### Top Bar / Header (Elegant, Not Cramped)
- Use `EquranSectionHeader` or custom premium header with title "Hijri Calendar" + Arabic "التقويم الهجري".
- Integrated elegant controls (not raw dropdown + switch):
  - Beautiful segmented/pill control for sighting offset (-1 / 0 / +1) with icons.
  - Subtle toggle or pill for "Fasting Reminders" (with info icon that opens a nice explanation sheet).
- Current focused month/year in large, bold typography (with Hijri equivalent when possible).

### The Calendar Grid — The Star of the Show (Small-Screen Optimized)
- **Swipeable Months**: `PageView` (or `PageView.builder`) of month grids for buttery navigation. Each "page" is a full month view.
- **7-column grid**, but highly adaptive:
  - Use `LayoutBuilder` + width-based `childAspectRatio` and font scaling.
  - On very small phones: slightly smaller cells but larger touch via `InkWell` + padding strategy; consider a "compact" mode that shows week numbers or collapses some labels.
  - Generous minimum cell size (~44–52px target).
- **Day Cell Design (Premium)**:
  - Built on `EquranSurfaceCard` or a custom high-quality container (consistent radii 12–16, subtle border/shadow).
  - **Today treatment (strongest)**: Primary or gold-tinged ring/border + small "Today" pill or dot in primary. Big day number in w900.
  - **Selected treatment**: Clear primary tint bg + thicker primary border (animated).
  - **Event days (beautiful but subordinate)**:
    - Subtle gold `accentGold` or `goldSoft` bottom accent bar / small elegant dot or crescent icon (never full bg takeover).
    - For major Eids: slightly stronger but still secondary gold treatment + small "Eid" badge.
    - Ramadan days: very soft mint/gold wash or left edge accent.
    - Layering order: Today/selected always wins on border + ring.
  - Dual dates: Large Gregorian (or prominent), smaller elegant Hijri below or in corner (gold tint on event days).
  - Optional: Tiny moon phase icon per cell (new moon, crescent, full — using simple icons or 4–8 custom assets/painter).
- **Week Header**: Elegant, not plain text. Use premium typography or small badges. Support RTL if needed (though app is mostly LTR).
- **Legend**: Collapsible or bottom sheet with beautiful color/icon key (Today, Eid, Ramadan, Ashura, Laylat al-Qadr, Ayyam al-Bid, etc.). Use `EquranIconBadge` + gold accents.

### Details / Selected Day Panel
- When a day is tapped: Smooth expand or dedicated beautiful `EquranSurfaceCard` / modal sheet (or persistent bottom panel on larger layouts).
- Content (rich, not stiff):
  - Large dual date display (Gregorian prominent + Hijri in elegant Arabic-capable style if we add support).
  - Big occasion name with gold star/crescent icon (if any).
  - Fasting recommendation + reason.
  - Moon phase visual + name.
  - "Recommended for this day" short guidance (e.g., "Sunnah to fast", "Night of Power — pray Tahajjud").
  - Quick actions: Set reminder, Add to personal notes (future), Share beautiful date card.
- Use `EquranGradientCard` for the most blessed nights (Laylat al-Qadr, etc.) for extra delight.

### Additional World-Class Touches
- **Quick Jump Bar or FAB menu**: Chips or elegant bottom sheet: "1 Ramadan", "Eid al-Fitr", "Day of Arafah", "Ashura", "Islamic New Year", "Laylat al-Qadr (est.)".
- **Year Overview** (optional advanced): Mini 12-month strip or list of key events in the current Hijri year.
- **Settings elegantly housed**: Bottom sheet or integrated "Customize" that explains sighting offset with good copy ("Adjust for local moon sighting...").
- **Subtle Animations**: Month page transitions (slide/fade), day tap scale + color morph, highlight pulse on major events.
- **Accessibility & Polish**: High contrast, large tap targets, proper semantics, BouncingScrollPhysics, max-width centering for tablets.
- **Dark/Light + Theme Variants**: Full support (gold pops beautifully on dark).

### Data & Logic Improvements
- Extend `HijriCalendar`:
  - Add Arabic month names (or use existing l10n patterns).
  - Helper for "isBlessedNight", "isFastingDay", "getMoonPhaseEstimate" (simple phase from day of month is acceptable for UI beauty; note it's approximate).
  - Better month navigation helpers (next/prev Hijri month).
- Keep notification logic; enhance with richer payload if needed.
- Event data: Move from hardcoded methods to a small, maintainable map or list for easier future expansion (Laylat al-Qadr estimates, etc.).

## 4. Implementation Strategy (Phased, Safe)

**Phase 0: Foundations (no UI breakage)**
- Improve/extend `HijriCalendar` helper (Arabic names, helper methods, moon phase estimate). Add unit tests if easy.
- Create new models: `HijriEvent`, `HijriDayInfo`, `MoonPhase`.
- Extract pure functions for occasions/fasting (from existing logic).

**Phase 1: Core Calendar View Overhaul**
- Replace rigid Grid + Cards with responsive, swipeable `PageView` + premium day cells using `EquranSurfaceCard` + custom paint for rings/dots.
- Implement correct visual hierarchy (today strongest → selected → major events in gold → minor in mint/gold tint).
- Add moon phase indicators (start simple with Unicode or existing icons; upgrade to subtle painter if time).
- Responsive scaling via `LayoutBuilder` (breakpoints at ~360, 480, 700px for fonts, aspect, padding).

**Phase 2: Navigation, Details & Polish**
- Elegant header + integrated settings controls (pills, not raw dropdown).
- Rich selected-day `EquranSurfaceCard` / expandable panel with full info.
- Quick-jump chips for major dates.
- Legend + subtle animations.
- Full theme/gold/primary/mint harmony.

**Phase 3: Power Features & Delight**
- True Hijri-month aware navigation option (or clear dual display).
- Enhanced details (recommended ibadah, shareable beautiful card preview).
- Fasting reminders UI polish (move to elegant sheet).
- Edge cases: very small screens, wide tablets, RTL considerations, accessibility.

**Phase 4: Cleanup & Testing**
- Remove old raw Card/Grid code.
- Update any callers if needed.
- Manual testing on small devices + dark/light.
- Optional: Add to dashboard or prayer page as a teaser if it fits.

**Risks & Mitigations**
- Hijri accuracy: Always document "approximate — based on sighting offset". Never claim perfect astronomical.
- Performance: `PageView` of 12–36 months pre-built is fine; virtualize if needed.
- Scope creep: Prioritize visual hierarchy fix + beautiful month view first.
- No new packages (stay consistent with app — no fl_chart, no heavy calendar libs).

**Success Criteria (Qualitative)**
- The calendar now feels like it belongs in the same app as the prayer hero cards and journey UI.
- On a 360px phone, every cell is comfortable to tap and beautiful.
- Tapping today feels special; tapping Eid feels celebratory but subordinate.
- Gold accents make blessed nights pop tastefully.
- Users want to swipe and explore months for fun.

## 5. Open Questions / Decisions for Clarification (if needed later)
- Should we support full bidirectional Hijri ↔ Gregorian picker, or keep Gregorian months with strong Hijri labels?
- How ambitious on moon phases (simple icons vs nice custom painter)?
- Any specific additional events or madhhab notes to surface?
- Do we want a "year at a glance" mini view?
- Localization priority for Arabic month names in this release?

## 6. File Touchpoints
- `lib/prayer/islamic_calendar_page.dart` — major rewrite (UI + logic).
- `lib/prayer/hijri_calendar.dart` — enhancements.
- Possibly new small widgets in `lib/prayer/` or reuse/extend `widgets/common/`.
- Minor: settings keys stay the same for notifications.
- Docs: Update any references in `docs/` if they exist.
- L10n: May need a few new keys (or keep English-first like current).

This redesign will turn one of the app's weakest screens into one of its most delightful and "blow away" experiences — calm, elegant, deeply Islamic, and perfectly optimized for the small screens where it matters most.

---

## 7. Recent Exploration Notes & Confirmed Patterns (April 2026)

- **Gold for "Special/Blessed"**: Confirmed across the app — `accentGold` + `goldSoft` used for streaks (fire icon + border), read ornaments/dividers, active number badges (stronger gold border when selected), Asma header ornaments, and premium card accents. **Perfect for major events** (Eid, Laylat al-Qadr) without overpowering "Today".
- **Today/Selected vs Events**: Prayer thumbs and journey cards show clear precedent: **primary tints + borders + dots + stronger shadow for "now/active"**, gold reserved for premium/special numeric or streak emphasis. The current Islamic calendar violates this (Eid primary wins over selection).
- **Decorative Assets Pattern**: Many premium cards use low-opacity right-aligned webp (e.g., `design.webp` at 0.03–0.20, prayer time banners). We can use or suggest a subtle crescent/mosque motif asset for the calendar header.
- **Moon/Phase Ideas**: No existing moon assets. Feasible via `Icons.nightlight_round`, `Icons.brightness_2`, or a tiny 4-state custom painter (very low cost, high delight). Phase can be estimated from Hijri day (good enough for UI beauty; note approximation).
- **Responsive Grid Lessons**: Prayer time thumbs use fixed `mainAxisExtent` + `LayoutBuilder` at 700px for 3-col. Reading presets at 620px for 2-col. We should be more aggressive for the calendar (breakpoints ~340px, 480px, 700px) with dynamic `childAspectRatio` and font scaling to guarantee usability on the smallest phones.
- **Hijri Helper**: Remains the main technical debt. Enhancements (Arabic names via a const list + helpers for `isMajorEvent`, simple phase) are low-risk and high-value.

These confirm the direction in sections 2–4 is sound and aligned with the rest of the app.

## 8. Immediate Next Steps (Post-Approval)
1. Read this plan + the current `islamic_calendar_page.dart` + `hijri_calendar.dart` one more time.
2. Implement Phase 0 (helper improvements + models) in a small, reviewable PR/changeset.
3. Tackle the calendar grid + hierarchy fix (biggest visual win).
4. Layer on the rest.

*Plan created fresh for this task (different from prior Zakat work). Overwrote irrelevant session state. Ready for user review and approval via exit_plan_mode.*