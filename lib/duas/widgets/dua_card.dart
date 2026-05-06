import 'package:equran/backend/dua_favourites_db.dart';
import 'package:equran/duas/hisn_al_muslim_models.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

enum _DuaOverflowAction { copy, share }

class DuaCard extends StatelessWidget {
  const DuaCard({
    super.key,
    required this.dua,
    this.number,
    this.categoryTitle,
    this.onTap,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 18),
  });

  final HisnDua dua;
  final int? number;
  final String? categoryTitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    final List<String> metadata = <String>[
      if (dua.count != null && dua.count! > 1) 'Repeat ${dua.count}x',
      if (dua.reference != null) dua.reference!,
      if (dua.source != null) dua.source!,
      if (dua.notes != null) dua.notes!,
    ];

    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: DuaFavouritesDB().listener,
      builder: (BuildContext context, Box<dynamic> box, Widget? child) {
        final bool isFavourite = DuaFavouritesDB().contains(dua.id);

        return Card(
          elevation: isLight ? 3 : 0,
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: BorderSide(
              color: isLight
                  ? colors.primary.withAlpha(26)
                  : colors.outlineVariant.withAlpha(86),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.medium),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color.alphaBlend(
                      colors.primary.withAlpha(isLight ? 10 : 16),
                      theme.cardTheme.color ?? colors.surfaceContainerLow,
                    ),
                    Color.alphaBlend(
                      colors.tertiary.withAlpha(isLight ? 8 : 12),
                      theme.cardTheme.color ?? colors.surfaceContainerLow,
                    ),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withAlpha(isLight ? 10 : 20),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _DuaCardHeader(
                      dua: dua,
                      number: number,
                      categoryTitle: categoryTitle,
                      isFavourite: isFavourite,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      dua.text,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Hafs',
                        height: 1.95,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        color: colors.onSurface,
                      ),
                    ),
                    if (dua.transliteration != null) ...<Widget>[
                      const SizedBox(height: 14),
                      Text(
                        dua.transliteration!,
                        textAlign: TextAlign.justify,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withAlpha(190),
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (dua.translation != null) ...<Widget>[
                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: colors.outlineVariant.withAlpha(118),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        dua.translation!,
                        textAlign: TextAlign.justify,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                    if (metadata.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: metadata
                            .map((String item) => _DuaMetadataPill(text: item))
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DuaCardHeader extends StatelessWidget {
  const _DuaCardHeader({
    required this.dua,
    required this.number,
    required this.categoryTitle,
    required this.isFavourite,
  });

  final HisnDua dua;
  final int? number;
  final String? categoryTitle;
  final bool isFavourite;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Row(
      children: <Widget>[
        if (number != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(14),
              borderRadius: BorderRadius.circular(AppRadii.medium),
              border: Border.all(color: colors.primary.withAlpha(24)),
            ),
            child: Text(
              'Dua $number',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant.withAlpha(205),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (categoryTitle != null) ...<Widget>[
          if (number != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              categoryTitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant.withAlpha(190),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ] else
          const Spacer(),
        const SizedBox(width: 10),
        _DuaIconButton(
          tooltip: isFavourite ? 'Remove favourite' : 'Favourite',
          icon: isFavourite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isFavourite ? colors.primary : colors.onSurface.withAlpha(168),
          onPressed: () => _toggleFavourite(context, isFavourite),
        ),
        const SizedBox(width: 6),
        _DuaMoreMenu(dua: dua),
      ],
    );
  }

  void _toggleFavourite(BuildContext context, bool isFavourite) {
    if (isFavourite) {
      DuaFavouritesDB().delete(dua.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from dua favourites.')),
      );
      return;
    }

    DuaFavouritesDB().put(dua.id, DateTime.now().toIso8601String());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to dua favourites.')));
  }
}

class _DuaMoreMenu extends StatelessWidget {
  const _DuaMoreMenu({required this.dua});

  final HisnDua dua;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 34,
      width: 34,
      child: PopupMenuButton<_DuaOverflowAction>(
        tooltip: 'More actions',
        position: PopupMenuPosition.under,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(
          Icons.more_horiz_rounded,
          size: 19,
          color: colors.onSurface.withAlpha(168),
        ),
        onSelected: (action) async {
          switch (action) {
            case _DuaOverflowAction.copy:
              await Clipboard.setData(ClipboardData(text: dua.shareText));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Dua copied.')));
              break;
            case _DuaOverflowAction.share:
              await SharePlus.instance.share(
                ShareParams(
                  title: 'Hisn al Muslim dua',
                  subject: dua.categoryTitle,
                  text: dua.shareText,
                ),
              );
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return const <PopupMenuEntry<_DuaOverflowAction>>[
            PopupMenuItem<_DuaOverflowAction>(
              value: _DuaOverflowAction.copy,
              child: _OverflowMenuItem(
                icon: Icons.copy_rounded,
                label: 'Copy text',
              ),
            ),
            PopupMenuItem<_DuaOverflowAction>(
              value: _DuaOverflowAction.share,
              child: _OverflowMenuItem(
                icon: Icons.ios_share_outlined,
                label: 'Share text',
              ),
            ),
          ];
        },
      ),
    );
  }
}

class _DuaIconButton extends StatelessWidget {
  const _DuaIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            height: 34,
            width: 34,
            child: Icon(icon, size: 19, color: color),
          ),
        ),
      ),
    );
  }
}

class _DuaMetadataPill extends StatelessWidget {
  const _DuaMetadataPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          text,
          textDirection: _looksArabic(text)
              ? TextDirection.rtl
              : TextDirection.ltr,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.25,
          ),
        ),
      ),
    );
  }

  bool _looksArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}

class _OverflowMenuItem extends StatelessWidget {
  const _OverflowMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 19, color: colors.onSurface.withAlpha(190)),
        const SizedBox(width: 12),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
