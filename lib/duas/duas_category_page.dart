import 'dart:async';

import 'package:equran/backend/library.dart' show DuaInteractionsDB, SettingsDB;
import 'package:equran/duas/hisn_al_muslim_models.dart';
import 'package:equran/duas/hisn_al_muslim_repository.dart';
import 'package:equran/duas/widgets/dua_card.dart';
import 'package:equran/duas/widgets/dua_settings_card.dart';
import 'package:equran/l10n/app_localizations.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';

class DuasCategoryPage extends StatefulWidget {
  const DuasCategoryPage({
    super.key,
    required this.categoryIndex,
    required this.repository,
    this.focusDuaId,
  });

  final DuaCategoryIndex categoryIndex;
  final HisnAlMuslimRepository repository;
  final String? focusDuaId;

  @override
  State<DuasCategoryPage> createState() => _DuasCategoryPageState();
}

class _DuasCategoryPageState extends State<DuasCategoryPage> {
  late final Future<DuaCategory> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _categoryFuture = widget.repository.loadCategoryByAsset(
      widget.categoryIndex.asset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryIndex.localizedTitle(context),
          textDirection: Directionality.of(context),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
        actionsIconTheme: IconThemeData(color: colors.textSecondary),
      ),
      body: FutureBuilder<DuaCategory>(
        future: _categoryFuture,
        builder: (BuildContext context, AsyncSnapshot<DuaCategory> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            );
          }

          if (snapshot.hasError) {
            final AppLocalizations localizations = AppLocalizations.of(
              context,
            )!;
            return _CategoryMessage(
              icon: Icons.error_outline_rounded,
              title: localizations.categoryUnavailable,
              message: localizations.hisnCategoryCouldNotLoad,
            );
          }

          final DuaCategory? category = snapshot.data;
          if (category == null || category.duas.isEmpty) {
            final AppLocalizations localizations = AppLocalizations.of(
              context,
            )!;
            return _CategoryMessage(
              icon: Icons.menu_book_outlined,
              title: localizations.noDuasFound,
              message: localizations.categoryContainsNoDuas,
            );
          }

          return _CategoryContent(
            category: category,
            focusDuaId: widget.focusDuaId,
          );
        },
      ),
    );
  }
}

class _CategoryContent extends StatefulWidget {
  const _CategoryContent({required this.category, this.focusDuaId});

  final DuaCategory category;
  final String? focusDuaId;

  @override
  State<_CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends State<_CategoryContent> {
  late final ScrollController _scrollController;
  bool _showSettings = true;
  double _lastOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        DuaInteractionsDB().recordCategoryView(
          categoryId: widget.category.id,
          categoryTitle: widget.category.title,
          duaCount: widget.category.duas.length,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double offset = _scrollController.offset;
    final double delta = offset - _lastOffset;
    _lastOffset = offset;

    if (offset <= 0) {
      if (!_showSettings) {
        setState(() {
          _showSettings = true;
        });
      }
    } else if (delta > 3 && _showSettings && offset > 30) {
      setState(() {
        _showSettings = false;
      });
    } else if (delta < -3 && !_showSettings) {
      setState(() {
        _showSettings = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final DuaCategory category = widget.category;

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                category.localizedTitle(context),
                                textDirection: Directionality.of(context),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.45,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showSettings = !_showSettings;
                                });
                              },
                              tooltip: _showSettings ? 'Hide settings' : 'Show settings',
                              icon: AnimatedRotation(
                                duration: const Duration(milliseconds: 250),
                                turns: _showSettings ? 0.25 : 0.0,
                                child: Icon(
                                  _showSettings ? Icons.tune_rounded : Icons.tune_outlined,
                                  color: _showSettings ? colors.primary : colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.duaCount(
                            category.duas.length,
                            category.duas.length == 1
                                ? localizations.dua
                                : localizations.duasLabel,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: DuaTypographySettingsCard(),
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _showSettings ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                  sizeCurve: Curves.easeInOutCubic,
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${localizations.translationLanguage}:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: SettingsDB().get(
                                "dua_language",
                                defaultValue: "app",
                              ),
                              onChanged: (String? val) async {
                                if (val != null) {
                                  await SettingsDB().put("dua_language", val);
                                  setState(() {});
                                }
                              },
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'app',
                                  child: Text(localizations.systemDefault),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'en',
                                  child: Text(localizations.english),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'bn',
                                  child: Text(localizations.bengali),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'ur',
                                  child: Text(localizations.urdu),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'id',
                                  child: Text(localizations.indonesian),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'tr',
                                  child: Text(localizations.turkish),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('${localizations.translation} '),
                                Switch(
                                  value: SettingsDB().get(
                                    "dua_show_translation",
                                    defaultValue: true,
                                  ),
                                  activeThumbColor: colors.primary,
                                  onChanged: (bool val) async {
                                    await SettingsDB().put(
                                      "dua_show_translation",
                                      val,
                                    );
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('${localizations.transliterationOption} '),
                                Switch(
                                  value: SettingsDB().get(
                                    "dua_show_transliteration",
                                    defaultValue: true,
                                  ),
                                  activeThumbColor: colors.primary,
                                  onChanged: (bool val) async {
                                    await SettingsDB().put(
                                      "dua_show_transliteration",
                                      val,
                                    );
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (int index = 0; index < category.duas.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        border:
                            category.duas[index].id == widget.focusDuaId ||
                                category.duas[index].legacyFavouriteId ==
                                    widget.focusDuaId
                            ? Border.all(color: colors.primary, width: 2)
                            : null,
                      ),
                      child: DuaCard(
                        dua: category.duas[index],
                        number: index + 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryMessage extends StatelessWidget {
  const _CategoryMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: colors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
