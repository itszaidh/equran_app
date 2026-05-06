import 'package:equran/backend/dua_favourites_db.dart';
import 'package:equran/duas/duas_category_page.dart';
import 'package:equran/duas/hisn_al_muslim_models.dart';
import 'package:equran/duas/widgets/dua_card.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DuasFavouritesPage extends StatelessWidget {
  const DuasFavouritesPage({super.key, required this.categories});

  final List<HisnCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourite duas')),
      body: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: DuaFavouritesDB().listener,
        builder: (BuildContext context, Box<dynamic> box, Widget? child) {
          final List<HisnDua> favourites = _favouriteDuas();

          if (favourites.isEmpty) {
            return const _FavouritesEmptyState();
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final _FavouriteDuaGroup group in _groupByCategory(
                        favourites,
                      )) ...<Widget>[
                        _FavouriteCategoryHeader(group: group),
                        const SizedBox(height: 10),
                        for (final HisnDua dua in group.duas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DuaCard(
                              dua: dua,
                              number: dua.index + 1,
                              categoryTitle: group.category.title,
                              onTap: () => _openCategory(context, group, dua),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<HisnDua> _favouriteDuas() {
    final Set<String> favouriteIds = DuaFavouritesDB()
        .getKeys()
        .whereType<String>()
        .toSet();

    return categories
        .expand((HisnCategory category) => category.duas)
        .where((HisnDua dua) => favouriteIds.contains(dua.id))
        .toList(growable: false);
  }

  List<_FavouriteDuaGroup> _groupByCategory(List<HisnDua> duas) {
    final Map<String, _FavouriteDuaGroup> groups =
        <String, _FavouriteDuaGroup>{};
    final Map<String, HisnCategory> categoriesById = <String, HisnCategory>{
      for (final HisnCategory category in categories) category.id: category,
    };

    for (final HisnDua dua in duas) {
      final HisnCategory? category = categoriesById[dua.categoryId];
      if (category == null) continue;
      groups.putIfAbsent(
        category.id,
        () => _FavouriteDuaGroup(category: category, duas: <HisnDua>[]),
      );
      groups[category.id]!.duas.add(dua);
    }

    return groups.values.toList(growable: false);
  }

  void _openCategory(
    BuildContext context,
    _FavouriteDuaGroup group,
    HisnDua dua,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return DuasCategoryPage(category: group.category, focusDuaId: dua.id);
        },
      ),
    );
  }
}

class _FavouriteDuaGroup {
  _FavouriteDuaGroup({required this.category, required this.duas});

  final HisnCategory category;
  final List<HisnDua> duas;
}

class _FavouriteCategoryHeader extends StatelessWidget {
  const _FavouriteCategoryHeader({required this.group});

  final _FavouriteDuaGroup group;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: <Widget>[
            Icon(Icons.folder_special_rounded, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                group.category.title,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${group.duas.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavouritesEmptyState extends StatelessWidget {
  const _FavouritesEmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.favorite_border_rounded,
              size: 42,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No favourite duas yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any dua card to save it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
