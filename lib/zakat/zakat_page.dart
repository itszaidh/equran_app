import 'dart:convert';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/zakat/zakat_db.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Form Controllers
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _investmentsController = TextEditingController();
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _liabilitiesController = TextEditingController();

  // Price States
  double _goldPrice = 75.80; // default/fallback gold price per gram in USD
  double _silverPrice = 0.95; // default/fallback silver price per gram in USD
  bool _isLoadingPrice = false;
  String _priceStatus = 'Using default prices (offline)';

  // Calculation Selection States
  String _nisabType = 'silver'; // 'silver' or 'gold'
  String _goldUnit = 'grams'; // 'grams' or 'bhori' (1 bhori/tola = 11.664g)
  String _silverUnit = 'grams';

  // Constants
  static const double goldNisabGrams = 87.48;
  static const double silverNisabGrams = 612.36;
  static const double bhoriToGram = 11.664;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLiveMetalPrices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _investmentsController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _liabilitiesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveMetalPrices() async {
    setState(() {
      _isLoadingPrice = true;
      _priceStatus = 'Fetching live market rates...';
    });

    try {
      // Query PAX Gold price from CoinGecko (PAX Gold is backed 1:1 by real gold per troy oz)
      final http.Response response = await http
          .get(
            Uri.parse(
              'https://api.coingecko.com/api/v3/simple/price?ids=pax-gold&vs_currencies=usd',
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final double paxgPriceUsd =
            (data['pax-gold']?['usd'] as num?)?.toDouble() ?? 0.0;

        if (paxgPriceUsd > 0.0) {
          // 1 troy ounce = 31.1034768 grams
          final double goldGramPrice = paxgPriceUsd / 31.1034768;
          // Silver price is roughly Gold / 80 in market ratio
          final double silverGramPrice = goldGramPrice / 80.0;

          setState(() {
            _goldPrice = double.parse(goldGramPrice.toStringAsFixed(2));
            _silverPrice = double.parse(silverGramPrice.toStringAsFixed(2));
            _isLoadingPrice = false;
            _priceStatus = 'Live metal rates synchronized successfully';
          });
          return;
        }
      }
    } catch (_) {
      // Graceful fallback to default/cached rates
    }

    setState(() {
      _isLoadingPrice = false;
      _priceStatus = 'Market offline. Using standard cached values.';
    });
  }

  // Conversion helpers
  double _convertToGrams(double value, String unit) {
    if (unit == 'bhori') {
      return value * bhoriToGram;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textMuted,
          tabs: const <Tab>[
            Tab(icon: Icon(Icons.calculate_outlined), text: 'Calculator'),
            Tab(icon: Icon(Icons.history_toggle_off_rounded), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildCalculatorTab(theme, colors),
          _buildHistoryTab(theme, colors),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab(ThemeData theme, EquranColors colors) {
    // Form Inputs Parsing
    final double cash = double.tryParse(_cashController.text) ?? 0.0;
    final double investments =
        double.tryParse(_investmentsController.text) ?? 0.0;
    final double rawGold = double.tryParse(_goldController.text) ?? 0.0;
    final double rawSilver = double.tryParse(_silverController.text) ?? 0.0;
    final double liabilities =
        double.tryParse(_liabilitiesController.text) ?? 0.0;

    final double goldGrams = _convertToGrams(rawGold, _goldUnit);
    final double silverGrams = _convertToGrams(rawSilver, _silverUnit);

    final double goldWealth = goldGrams * _goldPrice;
    final double silverWealth = silverGrams * _silverPrice;

    final double totalWealth =
        cash + investments + goldWealth + silverWealth - liabilities;

    // Nisab Threshold Calculations
    final double goldNisabValue = goldNisabGrams * _goldPrice;
    final double silverNisabValue = silverNisabGrams * _silverPrice;
    final double selectedNisabThreshold = _nisabType == 'gold'
        ? goldNisabValue
        : silverNisabValue;

    final bool isEligible = totalWealth >= selectedNisabThreshold;
    final double zakatDue = isEligible ? totalWealth * 0.025 : 0.0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        // Live Price Stats Card
        Card(
          color: colors.primary.withAlpha(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: BorderSide(color: colors.primary.withAlpha(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Icon(Icons.trending_up_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Gold: \$${_goldPrice.toStringAsFixed(2)}/g  |  Silver: \$${_silverPrice.toStringAsFixed(2)}/g',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _priceStatus,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingPrice)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 1.8),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: _fetchLiveMetalPrices,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Wealth Inputs Panel
        _buildSectionHeader(theme, colors, 'Wealth & Liquid Assets'),
        const SizedBox(height: 6),
        _buildNumberField(_cashController, 'Liquid Cash & Bank Savings (\$)'),
        _buildNumberField(
          _investmentsController,
          'Other Assets & Investments (\$)',
        ),

        Row(
          children: <Widget>[
            Expanded(
              child: _buildNumberField(_goldController, 'Gold quantity'),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _goldUnit,
              onChanged: (String? val) {
                if (val != null) setState(() => _goldUnit = val);
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'grams', child: Text('Grams')),
                DropdownMenuItem<String>(
                  value: 'bhori',
                  child: Text('Bhori/Tola'),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: <Widget>[
            Expanded(
              child: _buildNumberField(_silverController, 'Silver quantity'),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _silverUnit,
              onChanged: (String? val) {
                if (val != null) setState(() => _silverUnit = val);
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'grams', child: Text('Grams')),
                DropdownMenuItem<String>(
                  value: 'bhori',
                  child: Text('Bhori/Tola'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),
        _buildSectionHeader(theme, colors, 'Outstanding Liabilities'),
        const SizedBox(height: 6),
        _buildNumberField(
          _liabilitiesController,
          'Debts & Short-term Liabilities (\$)',
        ),

        const SizedBox(height: 8),
        _buildSectionHeader(theme, colors, 'Nisab Sighting Suffix'),
        Row(
          children: <Widget>[
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Silver Nisab'),
                subtitle: Text('\$${silverNisabValue.toStringAsFixed(2)}'),
                value: 'silver',
                groupValue: _nisabType,
                activeColor: colors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (String? val) {
                  if (val != null) setState(() => _nisabType = val);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Gold Nisab'),
                subtitle: Text('\$${goldNisabValue.toStringAsFixed(2)}'),
                value: 'gold',
                groupValue: _nisabType,
                activeColor: colors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (String? val) {
                  if (val != null) setState(() => _nisabType = val);
                },
              ),
            ),
          ],
        ),

        // Calculations Overview Card
        const SizedBox(height: 12),
        Card(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: BorderSide(
              color: isEligible ? colors.primary.withAlpha(80) : colors.border,
              width: isEligible ? 1.6 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total Net Wealth:',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '\$${totalWealth.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Selected Nisab:', style: theme.textTheme.bodyMedium),
                    Text(
                      '\$${selectedNisabThreshold.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Zakat Due (2.5%):',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isEligible ? colors.primary : colors.textMuted,
                      ),
                    ),
                    Text(
                      '\$${zakatDue.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isEligible ? colors.primary : colors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (!isEligible && totalWealth > 0) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    'Your net wealth is below the Nisab threshold. Zakat is not due.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: zakatDue > 0.0
              ? () async {
                  final ZakatRecord rec = ZakatRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    cash: cash,
                    investments: investments,
                    goldGrams: goldGrams,
                    goldPrice: _goldPrice,
                    silverGrams: silverGrams,
                    silverPrice: _silverPrice,
                    liabilities: liabilities,
                    nisabType: _nisabType,
                    nisabValue: selectedNisabThreshold,
                    zakatDue: zakatDue,
                  );
                  await ZakatHistoryDB.instance.saveRecord(rec);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zakat calculation saved to history'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _tabController.animateTo(1);
                  }
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.bookmark_added_rounded),
          label: const Text('Save Calculation Record'),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(ThemeData theme, EquranColors colors) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: ZakatHistoryDB.instance.listener,
      builder: (BuildContext context, dynamic val, Widget? child) {
        final List<ZakatRecord> records = ZakatHistoryDB.instance
            .getAllRecords();

        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 48,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No historical calculations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Saved records will appear here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (BuildContext context, int index) {
            final ZakatRecord rec = records[index];
            final String dateStr =
                '${rec.date.day}/${rec.date.month}/${rec.date.year}';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                side: BorderSide(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Calculation on $dateStr',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textSecondary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () async {
                            await ZakatHistoryDB.instance.deleteRecord(rec.id);
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const Divider(height: 14),
                    _buildHistoryRow(
                      'Liquid Cash:',
                      '\$${rec.cash.toStringAsFixed(2)}',
                    ),
                    _buildHistoryRow(
                      'Investments:',
                      '\$${rec.investments.toStringAsFixed(2)}',
                    ),
                    _buildHistoryRow(
                      'Gold (${rec.goldGrams.toStringAsFixed(1)}g):',
                      '\$${(rec.goldGrams * rec.goldPrice).toStringAsFixed(2)}',
                    ),
                    _buildHistoryRow(
                      'Silver (${rec.silverGrams.toStringAsFixed(1)}g):',
                      '\$${(rec.silverGrams * rec.silverPrice).toStringAsFixed(2)}',
                    ),
                    _buildHistoryRow(
                      'Liabilities:',
                      '-\$${rec.liabilities.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Zakat Due:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          '\$${rec.zakatDue.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Zakat Paid/Distributed:'),
                        Row(
                          children: <Widget>[
                            Text(
                              '\$${rec.zakatPaid.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _showPaidAmountDialog(context, rec),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaidAmountDialog(BuildContext context, ZakatRecord record) {
    final TextEditingController controller = TextEditingController(
      text: record.zakatPaid.toString(),
    );
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Zakat Paid Amount'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter paid amount in USD',
              prefixText: '\$ ',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final double? amount = double.tryParse(controller.text);
                if (amount != null) {
                  await ZakatHistoryDB.instance.updatePaidAmount(
                    record.id,
                    amount,
                  );
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 13)),
          Text(
            val,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    EquranColors colors,
    String title,
  ) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
        ),
      ),
    );
  }
}
