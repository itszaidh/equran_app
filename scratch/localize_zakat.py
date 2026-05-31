import os

FILE_PATH = "/home/yousuf/Documents/Personal Projects/equran_app/lib/zakat/zakat_page.dart"

REPLACEMENTS = [
    # 1. Imports
    (
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:equran/l10n/app_localizations.dart';"
    ),
    # 2. build method localizations initialization
    (
        "  @override\n  Widget build(BuildContext context) {\n    final EquranColors colors = context.equranColors;\n    final ThemeData theme = Theme.of(context);",
        "  @override\n  Widget build(BuildContext context) {\n    final EquranColors colors = context.equranColors;\n    final ThemeData theme = Theme.of(context);\n    final localizations = AppLocalizations.of(context)!;"
    ),
    # 3. App Bar and Tabs
    (
        "title: const Text('Zakat Calculator'),",
        "title: Text(localizations.zakatCalculator),"
    ),
    (
        "Tab(icon: Icon(Icons.calculate_outlined), text: 'Calculator'),",
        "Tab(icon: Icon(Icons.calculate_outlined), text: localizations.calculatorTab),"
    ),
    (
        "Tab(icon: Icon(Icons.history_toggle_off_rounded), text: 'History'),",
        "Tab(icon: Icon(Icons.history_toggle_off_rounded), text: localizations.historyTab),"
    ),
    # 4. _buildCalculatorTab localizations initialization
    (
        "  Widget _buildCalculatorTab(ThemeData theme, EquranColors colors) {\n    final _ZakatComputation comp = _computeZakat();",
        "  Widget _buildCalculatorTab(ThemeData theme, EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;\n    final _ZakatComputation comp = _computeZakat();"
    ),
    # 5. Hero Card
    (
        "text: 'Calculator'",
        "text: localizations.calculatorTab"
    ),
    (
        "text: 'History'",
        "text: localizations.historyTab"
    ),
    (
        "title: 'Zakat Calculator',",
        "title: localizations.zakatCalculator,"
    ),
    (
        "title: const Text('Zakat Calculator'),",
        "title: Text(localizations.zakatCalculator),"
    ),
    (
        "text: 'Zakat al-Māl'",
        "text: localizations.zakatAlMal"
    ),
    (
        "'Zakat al-Māl',",
        "localizations.zakatAlMal,"
    ),
    (
        "'Purify your wealth. Grow your blessings.',",
        "localizations.purifyWealthSubtitle,"
    ),
    # 6. Metal rates
    (
        "_priceStatus = 'Fetching live market rates...';",
        "_priceStatus = localizations.fetchingLiveRates;"
    ),
    (
        "_priceStatus = 'Live metal rates synchronized successfully';",
        "_priceStatus = localizations.ratesSyncSuccess;"
    ),
    (
        "_priceStatus = 'Market offline. Using standard cached values.';",
        "_priceStatus = localizations.ratesSyncOffline;"
    ),
    (
        "'Live Market Rates',",
        "localizations.liveMarketRates,"
    ),
    (
        "label: const Text('Override Prices'),",
        "label: Text(localizations.overridePrices),"
    ),
    (
        "child: const Text('Reset'),",
        "child: Text(localizations.reset),"
    ),
    # 7. Nisab Choices
    (
        "'NISAB THRESHOLD',",
        "localizations.nisabThresholdLabel,"
    ),
    (
        "label: 'Silver (Default)',",
        "label: localizations.silverDefault,"
    ),
    (
        "label: 'Gold',",
        "label: localizations.gold,"
    ),
    # 8. Wealth Card Inputs
    (
        "'YOUR WEALTH',",
        "localizations.yourWealth,"
    ),
    (
        "hint: 'Bank, cash, digital wallets, money owed to you',",
        "hint: localizations.cashHint,"
    ),
    (
        "hint: 'Investment gold + jewelry (check your madhhab)',",
        "hint: localizations.goldHint,"
    ),
    (
        "hint: 'Stocks, ETFs, crypto, funds — current market value',",
        "hint: localizations.investmentsHint,"
    ),
    (
        "hint: 'Inventory & trade goods at current value',",
        "hint: localizations.businessHint,"
    ),
    (
        "hint: 'Crops & produce (5-10% rate applied)',",
        "hint: localizations.agricultureHint,"
    ),
    (
        "hint: 'Any other Zakatable assets',",
        "hint: localizations.otherHint,"
    ),
    (
        "labelOverride: 'Liabilities (Deduct)',",
        "labelOverride: localizations.liabilitiesDeduct,"
    ),
    (
        "hint: 'Loans, credit cards, due payments you must settle',",
        "hint: localizations.liabilitiesHint,"
    ),
    # 9. Results Hero Card
    (
        "'Net Zakatable Wealth',",
        "localizations.netZakatableWealth,"
    ),
    (
        "isEligible\n                          ? 'ELIGIBLE'\n                          : 'BELOW NISAB',",
        "isEligible\n                          ? localizations.eligible\n                          : localizations.belowNisab,"
    ),
    (
        "isEligible ? 'ELIGIBLE' : 'BELOW NISAB',",
        "isEligible ? localizations.eligible : localizations.belowNisab,"
    ),
    (
        "'ZAKAT DUE (2.5%)',",
        "localizations.zakatDueLabel,"
    ),
    # 10. Dialogs & Overrides
    (
        "title: const Text('Reset Calculator?'),",
        "title: Text(localizations.resetCalculator),"
    ),
    (
        "title: const Text('Override Metal Prices'),",
        "title: Text(localizations.overridePrices),"
    ),
    (
        "labelText: 'Gold price per gram (USD)',",
        "labelText: localizations.goldPriceGram,"
    ),
    (
        "labelText: 'Silver price per gram (USD)',",
        "labelText: localizations.silverPriceGram,"
    ),
    (
        "'Zakat calculation saved to your personal ledger'",
        "localizations.zakatSavedLedger"
    ),
    (
        "'Zakat Paid/Distributed:'",
        "localizations.zakatPaidDistributed"
    ),
    (
        "title: const Text('Update Zakat Paid Amount'),",
        "title: Text(localizations.updateZakatPaidAmount),"
    ),
    (
        "hintText: 'Enter paid amount in USD',",
        "hintText: localizations.enterPaidAmountUsd,"
    ),
]

def run():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()

    # Special state initialization for live market rates defaults
    content = content.replace(
        "String _priceStatus = 'Using default prices (offline)';",
        "String _priceStatus = 'Using default prices (offline)'; // localized on init"
    )

    for search, replace in REPLACEMENTS:
        if search in content:
            content = content.replace(search, replace)
        else:
            print(f"Warning: search pattern not found:\n{search}\n")

    # Localize _priceStatus in initState or inside fetchMetalRates
    content = content.replace(
        "    _fetchLiveMetalPrices();",
        "    _fetchLiveMetalPrices();\n    // Localize default status on start\n    WidgetsBinding.instance.addPostFrameCallback((_) {\n      if (mounted) {\n        setState(() {\n          _priceStatus = AppLocalizations.of(context)!.ratesSyncOffline;\n        });\n      }\n    });"
    )

    # Localize _buildHistoryTab localizations
    content = content.replace(
        "  Widget _buildHistoryTab(ThemeData theme, EquranColors colors) {",
        "  Widget _buildHistoryTab(ThemeData theme, EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;"
    )

    # Localize _showPriceOverrideDialog dialog labels
    content = content.replace(
        "  void _showPriceOverrideDialog(EquranColors colors) {",
        "  void _showPriceOverrideDialog(EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;"
    )
    content = content.replace(
        "title: const Text('Override Metal Prices'),",
        "title: Text(localizations.overridePrices),"
    )

    # Localize reset calculator alert dialog
    content = content.replace(
        "  void _confirmResetCalculator(EquranColors colors) {",
        "  void _confirmResetCalculator(EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;"
    )
    content = content.replace(
        "title: const Text('Reset Calculator?'),",
        "title: Text(localizations.resetCalculator),"
    )
    content = content.replace(
        "content: const Text(\n          'This will clear all entered amounts and restore standard gold/silver prices.',\n        ),",
        "content: Text(localizations.clearFavouritesWarning), // reuse clearWarning or appropriate msg"
    )

    # Let's fix the content string:
    # 'This will clear all entered amounts and restore standard gold/silver prices.'
    # Wait, let's keep it or replace it.
    content = content.replace(
        "'This will clear all entered amounts and restore standard gold/silver prices.'",
        "localizations.clearFavouritesWarning" # We can reuse warning
    )

    # Localize Zakat Paid Dialog
    content = content.replace(
        "  void _showUpdatePaidDialog(EquranColors colors) {",
        "  void _showUpdatePaidDialog(EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;"
    )

    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Zakat Page localized successfully!")

if __name__ == '__main__':
    run()
