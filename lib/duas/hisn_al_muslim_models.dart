class HisnCategory {
  const HisnCategory({
    required this.id,
    required this.index,
    required this.title,
    required this.duas,
  });

  final String id;
  final int index;
  final String title;
  final List<HisnDua> duas;

  bool matches(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    if (title.toLowerCase().contains(normalizedQuery)) return true;
    return duas.any((HisnDua dua) => dua.matches(normalizedQuery));
  }

  HisnCategory filtered(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty ||
        title.toLowerCase().contains(normalizedQuery)) {
      return this;
    }

    return HisnCategory(
      id: id,
      index: index,
      title: title,
      duas: duas
          .where((HisnDua dua) => dua.matches(normalizedQuery))
          .toList(growable: false),
    );
  }
}

class HisnDua {
  const HisnDua({
    required this.id,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIndex,
    required this.index,
    required this.text,
    this.reference,
    this.count,
    this.translation,
    this.transliteration,
    this.notes,
    this.source,
  });

  final String id;
  final String categoryId;
  final String categoryTitle;
  final int categoryIndex;
  final int index;
  final String text;
  final String? reference;
  final int? count;
  final String? translation;
  final String? transliteration;
  final String? notes;
  final String? source;

  bool matches(String normalizedQuery) {
    return text.toLowerCase().contains(normalizedQuery) ||
        (reference?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (translation?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (transliteration?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (notes?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (source?.toLowerCase().contains(normalizedQuery) ?? false);
  }

  String get shareText {
    return <String>[
      text,
      ?translation,
      ?transliteration,
      ?reference,
      ?source,
      ?notes,
      'Hisn al Muslim - $categoryTitle',
    ].join('\n\n');
  }
}
