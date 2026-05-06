import 'package:equran/duas/hisn_al_muslim_models.dart';
import 'package:equran/duas/widgets/dua_card.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';

class DuasCategoryPage extends StatelessWidget {
  const DuasCategoryPage({super.key, required this.category, this.focusDuaId});

  final HisnCategory category;
  final String? focusDuaId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.title,
          textDirection: TextDirection.rtl,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
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
                          Text(
                            category.title,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.45,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${category.duas.length} ${category.duas.length == 1 ? 'dua' : 'duas'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (category.duas.isEmpty)
                    _CategoryMessage(
                      icon: Icons.menu_book_outlined,
                      title: 'No duas found',
                      message: 'This category does not contain any duas.',
                    )
                  else
                    for (int index = 0; index < category.duas.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppRadii.medium,
                            ),
                            border: category.duas[index].id == focusDuaId
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
      ),
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

    return Padding(
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
    );
  }
}
