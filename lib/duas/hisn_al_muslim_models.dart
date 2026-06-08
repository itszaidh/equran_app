import 'package:equran/duas/hisn_category_translations.dart';
import 'package:flutter/material.dart';

enum DuaGroup {
  dailyAthkar,
  prayer,
  hajjUmrah,
  travel,
  protectionHardship,
  healthIllness,
  deathFunerals,
  repentance,
  natureWeather,
  marriageFamily,
  remembrancePraise,
  socialEtiquette,
  misc,
}

class DuaCategoryIndex {
  const DuaCategoryIndex({
    required this.id,
    required this.index,
    required this.title,
    required this.duaCount,
    required this.footnoteCount,
    required this.asset,
  });

  final String id;
  final int index;
  final String title;
  final int duaCount;
  final int footnoteCount;
  final String asset;

  String localizedTitle(BuildContext context) {
    return getLocalizedCategoryTitle(context, id, title);
  }

  bool matches(String query, BuildContext context) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    final String localized = localizedTitle(context).toLowerCase();
    return title.toLowerCase().contains(normalizedQuery) ||
        localized.contains(normalizedQuery);
  }

  DuaGroup get group => DuaCategoryGroupMapper.groupFor(id);
}

class DuaCategoryGroupMapper {
  static DuaGroup groupFor(String id) {
    // Quick range checks for common groups
    final int n = int.tryParse(id) ?? 0;

    // Hajj & Umrah: 117-123
    if (n >= 117 && n <= 123) return DuaGroup.hajjUmrah;

    // Death & Funerals: 049-062
    if (n >= 49 && n <= 62) return DuaGroup.deathFunerals;

    // Protection & Hardship: 036-041, 090, 127-128, 130
    if (n >= 36 && n <= 41) return DuaGroup.protectionHardship;
    if (n == 90 || n == 127 || n == 128 || n == 130) {
      return DuaGroup.protectionHardship;
    }

    // Health & Illness: 042-045, 051-055, 085, 126
    if (n >= 42 && n <= 45) return DuaGroup.healthIllness;
    if (n == 51 || n == 52 || n == 53 || n == 54 || n == 85 || n == 126) {
      return DuaGroup.healthIllness;
    }

    // Repentance & Forgiveness: 046-048, 094, 131
    if (n == 46 || n == 47 || n == 48 || n == 94 || n == 131) {
      return DuaGroup.repentance;
    }

    // Nature & Weather: 063-069
    if (n >= 63 && n <= 69) return DuaGroup.natureWeather;

    // Marriage & Family: 049-050, 081-083
    // 049 is handled by deathFunerals above (newborn), but 049-050 is in death range
    // Redefine: 081-083 for marriage, 049-050 for family (newborn/children)
    // Since 049-062 is deathFunerals, override 049-050
    if (n == 49 || n == 50) return DuaGroup.marriageFamily;
    if (n >= 81 && n <= 83) return DuaGroup.marriageFamily;

    // Travel: 097-107
    if (n >= 97 && n <= 107) return DuaGroup.travel;

    // Prayer: 010-016, 017-027, 028, 034-035, 044
    if (n >= 10 && n <= 16) return DuaGroup.prayer;
    if (n >= 17 && n <= 27) return DuaGroup.prayer;
    if (n == 28 || n == 34 || n == 35 || n == 44) return DuaGroup.prayer;

    // Morning & Evening / Daily Athkar: 003, 029-033
    if (n == 3) return DuaGroup.dailyAthkar;
    if (n >= 29 && n <= 33) return DuaGroup.dailyAthkar;

    // Remembrance & Praise: 002, 109-116, 132-133
    if (n == 2) return DuaGroup.remembrancePraise;
    if (n >= 109 && n <= 116) return DuaGroup.remembrancePraise;
    if (n >= 132 && n <= 134) return DuaGroup.remembrancePraise;

    // Social Etiquette: 070-080, 086-089, 091-093, 095-096, 114-116, 124-125
    if (n >= 70 && n <= 80) return DuaGroup.socialEtiquette;
    if (n >= 86 && n <= 89) return DuaGroup.socialEtiquette;
    if (n == 91 || n == 92 || n == 93 || n == 95 || n == 96) {
      return DuaGroup.socialEtiquette;
    }
    if (n == 114 || n == 115 || n == 116) return DuaGroup.socialEtiquette;
    if (n == 124 || n == 125) return DuaGroup.socialEtiquette;

    // Introduction: 001
    if (n == 1) return DuaGroup.dailyAthkar;

    return DuaGroup.misc;
  }

  static List<DuaGroup> get orderedGroups => <DuaGroup>[
    DuaGroup.dailyAthkar,
    DuaGroup.prayer,
    DuaGroup.hajjUmrah,
    DuaGroup.travel,
    DuaGroup.protectionHardship,
    DuaGroup.healthIllness,
    DuaGroup.deathFunerals,
    DuaGroup.repentance,
    DuaGroup.natureWeather,
    DuaGroup.marriageFamily,
    DuaGroup.remembrancePraise,
    DuaGroup.socialEtiquette,
    DuaGroup.misc,
  ];
}

class DuaCategory {
  const DuaCategory({
    required this.id,
    required this.index,
    required this.title,
    required this.duas,
    required this.asset,
    required this.footnoteCount,
  });

  final String id;
  final int index;
  final String title;
  final List<DuaEntry> duas;
  final String asset;
  final int footnoteCount;

  String localizedTitle(BuildContext context) {
    return getLocalizedCategoryTitle(context, id, title);
  }
}

class DuaEntry {
  const DuaEntry({
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
    this.translations = const <String, String>{},
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
  final Map<String, String> translations;

  String get legacyFavouriteId {
    return 'hisn-c${categoryIndex + 1}-d${index + 1}';
  }

  /// Returns the best translation for the given locale tag (e.g. 'en', 'bn').
  /// Falls back to the legacy singular [translation] field if no map entry is found.
  String? localizedTranslation(String localeTag) {
    final String normalized = localeTag.trim().toLowerCase().split(RegExp(r'[-_]')).first;
    return translations[normalized] ?? translation;
  }

  bool matches(String normalizedQuery) {
    return text.toLowerCase().contains(normalizedQuery) ||
        (reference?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (translation?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (transliteration?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (notes?.toLowerCase().contains(normalizedQuery) ?? false) ||
        (source?.toLowerCase().contains(normalizedQuery) ?? false) ||
        translations.values.any(
          (String t) => t.toLowerCase().contains(normalizedQuery),
        );
  }

  Map<String, Object?> toFavouriteSnapshot() {
    return <String, Object?>{
      'id': id,
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
      'categoryIndex': categoryIndex,
      'index': index,
      'text': text,
      if (reference != null) 'reference': reference,
      if (count != null) 'count': count,
      if (translation != null) 'translation': translation,
      if (transliteration != null) 'transliteration': transliteration,
      if (notes != null) 'notes': notes,
      if (source != null) 'source': source,
      if (translations.isNotEmpty) 'translations': translations,
    };
  }

  static DuaEntry? fromFavouriteSnapshot(Object? value) {
    if (value is! Map) return null;

    final String? id = _stringOrNull(value['id']);
    final String? categoryId = _stringOrNull(value['categoryId']);
    final String? categoryTitle = _stringOrNull(value['categoryTitle']);
    final int? categoryIndex = _intOrNull(value['categoryIndex']);
    final int? index = _intOrNull(value['index']);
    final String? text = _stringOrNull(value['text']);

    if (id == null ||
        categoryId == null ||
        categoryTitle == null ||
        categoryIndex == null ||
        index == null ||
        text == null ||
        text.trim().isEmpty) {
      return null;
    }

    return DuaEntry(
      id: id,
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      categoryIndex: categoryIndex,
      index: index,
      text: text,
      reference: _stringOrNull(value['reference']),
      count: _intOrNull(value['count']),
      translation: _stringOrNull(value['translation']),
      transliteration: _stringOrNull(value['transliteration']),
      notes: _stringOrNull(value['notes']),
      source: _stringOrNull(value['source']),
      translations: _stringMapOrNull(value['translations']),
    );
  }

  String get shareText {
    return <String>[
      text,
      // ignore: use_null_aware_elements
      if (translation != null) translation!,
      // ignore: use_null_aware_elements
      if (transliteration != null) transliteration!,
      // ignore: use_null_aware_elements
      if (reference != null) reference!,
      // ignore: use_null_aware_elements
      if (source != null) source!,
      // ignore: use_null_aware_elements
      if (notes != null) notes!,
      'Hisn al Muslim - $categoryTitle',
    ].join('\n\n');
  }

  static String? _stringOrNull(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) return value.toString();
    return null;
  }

  static Map<String, String> _stringMapOrNull(Object? value) {
    if (value is! Map) return const <String, String>{};
    return value
        .map(
          (dynamic k, dynamic v) =>
              MapEntry<String, String>(k.toString(), v.toString()),
        )
        .cast<String, String>();
  }

  static int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
