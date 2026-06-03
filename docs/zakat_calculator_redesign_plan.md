# Zakat (Zakah) Calculator Redesign Plan

> **Status (2026-04)**: User approved **Full ambitious redesign**. Implementation in progress.

## Current State Analysis
- **File**: `lib/zakat/zakat_page.dart` (~735 LOC) + `zakat_db.dart`
- Very basic textbook form:
  - Cash + Investments + Gold (g/bhori) + Silver (g/bhori) + Liabilities
  - 2.5% flat on net if above chosen Nisab (gold 85g or silver 595g approx)
  - Live price hack via PAX Gold on CoinGecko
  - Simple Card + RadioListTile + TextField + Dropdown UI (feels dated)
  - History tab with basic save + paid tracking
- **Problems**: Too simplistic for real Muslim financial life, ugly repetitive inputs, no educational depth, no currency support, no breakdowns, poor visual hierarchy for such an important ibadah.

## Design Goals
1. **Beautiful & Themed**: Sleek modern Islamic aesthetic matching the app (deep teal primary #176B55 / #1E7A61 + rich `accentGold` #D6A84F, mint surfaces, elegant typography, generous cards with subtle shadows/gradients).
2. **Powerful & Comprehensive**: Support real-world Zakatable assets a practicing Muslim owns today:
   - Cash & equivalents (incl. digital wallets, receivables)
   - Gold (investment vs personal jewelry distinction)
   - Silver
   - Marketable securities (stocks, ETFs, mutual funds, crypto, REITs)
   - Business inventory / trade goods / merchandise
   - Livestock (traditional categories with authentic simplified Nisab tables)
   - Agricultural produce (basic support)
   - Other / Custom
3. **Intelligent UX**:
   - Live reactive calculations (current app pattern is acceptable).
   - Prominent, satisfying "Zakat Due" hero result (use `EquranGradientCard`).
   - Visual breakdown (simple bars/chips, not full charts to avoid deps).
   - Per-category rates and fiqh notes surfaced inline + via elegant info sheets.
   - Price overrides + better market status.
   - Nisab choice with live threshold values + short scholarly context.
   - Save rich scenarios to history with payment progress.
4. **Educational & Trustworthy**: Inline explanations, "i" buttons opening beautiful bottom sheets with references (Qur'an 9:60, relevant hadith, common madhhab notes). No legal advice — "general guidance".
5. **Fits App Patterns**:
   - Heavy use of `EquranSurfaceCard`, `EquranGradientCard`, `EquranIconBadge`, `EquranSectionHeader`.
   - `BouncingScrollPhysics`, consistent padding/radii, max-width centering on wide screens.
   - Primary color for key positive/important numbers when eligible.
   - History as reactive tab using `ValueListenableBuilder` + Hive.
   - TabController (Calculator | History) — keep or evolve.

## Proposed Information Architecture (Calculator Tab)

### Top
- Elegant header (gradient or surface + gold accents): "Zakat al-Mal" + Arabic "الزكاة", last price sync status, refresh.
- **Global Controls** (beautiful compact row or segmented control in a card):
  - Nisab base: Silver (most common) / Gold — with live computed threshold value in chosen currency.
  - (Future) Base Currency selector (start with USD + note; store pref in SettingsDB).

### Live Market Ticker (improved Card)
- Gold $/g + Silver $/g (live or cached)
- Last updated + manual "Edit prices" (power user override — critical for trust).
- Loading/refresh affordance.

### Wealth Builder (main interactive area)
Series of beautiful **expandable / tappable category cards** (use `EquranSurfaceCard` + leading `EquranIconBadge` with relevant icons: attach_money, gold, show_chart, inventory_2, pets, agriculture, etc.).

Each category card shows:
- Category name + current contribution to total wealth
- Quick summary of Zakat attributable from it
- Tap to expand detailed inputs (or always show tasteful inputs to reduce taps).

**Categories (v1)**:

1. **Cash, Savings & Receivables**
   - Bank accounts, cash, PayPal, Wise, crypto stablecoins held as cash, money owed to you that is likely collectible.
   - Single currency input for now.

2. **Gold**
   - Investment gold (bars, coins, ETFs) — full market value.
   - Personal jewelry (user can choose % or full; common scholarly views differ — surface note).
   - Quantity (grams or tola/bhori) + live price, or direct USD value input (power).

3. **Silver** (similar to gold, simpler).

4. **Investments & Securities**
   - Stocks, shares, mutual funds, ETFs, crypto (non-stable), P2P lending, etc.
   - User enters "Current Zakatable Market Value" (they check their brokerage/app).
   - Note about growth assets vs principal.

5. **Business Assets & Trade Goods (Urud al-Tijarah)**
   - Inventory, raw materials, finished goods for sale.
   - Input: current market/wholesale value of Zakatable stock.

6. **Livestock (An'am)**
   - Powerful sub-calculator:
     - Steppers / number inputs for: Sheep/Goats, Cows/Buffalo, Camels.
     - Auto-computes traditional Nisab and Zakat due in animals (or approximate cash equivalent using local market if we add price).
     - Shows the rule applied (e.g. "1 sheep for every 40-120 head").
   - Big educational win — feels truly useful.

7. **Agricultural Produce & Crops**
   - Simplified: value of harvest or % rate selector (5% irrigated / 10% rain-fed).
   - Or direct amount.

8. **Other Zakatable Assets**
   - Free-form "description + amount" rows (add multiple).

**Deductions**
- Clean "Liabilities & Deductible Debts" section (loans, credit cards, due Zakat from previous years, etc.). Clear guidance: only debts you are obligated to pay soon.

### Prominent Results Panel (always visible near top or as sticky-feeling card)
- Total Net Zakatable Wealth
- Applied Nisab Threshold + "You are $X above threshold" (beautiful status pill)
- **Hero Zakat Due** (very large, in `EquranGradientCard` with gold/green treatment when >0)
  - "2.5% of net eligible wealth" (or note if mixed rates from livestock/crops)
- Visual breakdown: horizontal segmented bar or Wrap of colored mini-cards showing % or $ per category.
- One-sentence spiritual note: "This purifies and grows your wealth, by Allah's permission."

### Actions Footer
- Primary: "Save to History & Record Payment" (opens paid amount prompt or saves 0)
- Secondary: Reset form, "Duplicate scenario", Share (text summary for now)
- "Learn the Fiqh behind this calculation" button → bottom sheet

## History Tab Enhancements
- Keep reactive `ValueListenableBuilder`
- Richer cards showing:
  - Date + total due / paid progress (linear progress + % paid)
  - Mini breakdown or top 3 categories
  - Edit paid amount (existing dialog pattern)
  - Delete
- Future: filter by year, export CSV (not in v1)

## Data Model Changes (`zakat_db.dart`)
- Keep `ZakatRecord` mostly backward compatible.
- Add `Map<String, dynamic> details` (or specific fields) for new categories.
- Version the box name if breaking (`zakah_history_box_v2`).
- Migration on read for old records.
- New model concept internally: `ZakatLineItem { categoryKey, label, amount, rateApplied, notes }`

## Implementation Phases (within this task)
1. **Foundation** — Update models, extract pure computation logic (`computeZakat`), improve price service (better fallbacks + overrides).
2. **UI Shell** — New header, market ticker, global Nisab controls using existing components.
3. **Category System** — Build `_AssetCategoryCard` reusable widget + 6-7 implementations.
4. **Livestock Special UI** — Fun + accurate.
5. **Results + Breakdown** — Hero + visual summary.
6. **Educational Layer** — Bottom sheets with good copy.
7. **History evolution** + save flow.
8. **Polish** — Animations (subtle), empty states, accessibility, wide screen, dark mode (already via theme extension).

## Technical Notes & Trade-offs
- **No new packages** preferred (keep bundle small). Use existing `http`, Hive, `intl` if already there for dates.
- Live prices: Enhance current CoinGecko approach or add a second source. Allow easy manual override.
- Currency: Start USD-centric with clear labeling + future hook for `SettingsDB().zakatBaseCurrency`.
- Computation: Extract to top-level functions or a small `ZakatEngine` class for testability.
- Fiqh notes: Be humble and general ("According to many scholars...", "Please consult a qualified local scholar for your specific situation").
- Length: File will grow. Consider splitting private widgets into `lib/zakat/widgets/` later if it exceeds ~1200 LOC.
- Testing: Manual + analyzer for now (no existing widget tests for this page).

## Success Metrics (qualitative)
- Feels premium and respectful of the topic.
- User can accurately model a realistic portfolio (e.g. "I have salary in bank + 10 tola gold + 300 shares of X + 45 goats").
- History becomes a useful personal Zakat ledger over years.
- Educational elements reduce anxiety ("Am I doing this right?").

## Open Questions for User (if needed)
- Preferred default Nisab (Silver is more accessible for most)?
- Should we support multiple currencies in v1 or defer?
- Any specific madhhab to optimize for (Hanafi common for Zakat calculations)?
- Livestock prices: should we attempt live local prices or keep pure headcount + manual value?

This redesign transforms the page from "textbook form" into a trusted daily companion tool for one of the Five Pillars.

---

*Plan written during exploration. Ready for refinement + implementation.*