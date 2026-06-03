import 'dart:convert';
import 'dart:io';

void main() {
  final File input = File('assets/data/quran/qpc-hafs.json');
  final Directory output = Directory('assets/data/quran/text/qpc-hafs');

  final Object? decoded = jsonDecode(input.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('qpc-hafs.json must be a JSON object.');
  }

  final Map<int, Map<int, Map<String, Object?>>> grouped =
      <int, Map<int, Map<String, Object?>>>{};
  for (final MapEntry<String, dynamic> entry in decoded.entries) {
    final Object? rawValue = entry.value;
    if (rawValue is! Map) {
      throw FormatException('Verse ${entry.key} is not an object.');
    }
    final Map<String, Object?> verse = rawValue.map(
      (dynamic key, dynamic value) =>
          MapEntry<String, Object?>(key.toString(), value),
    );
    final int surah = _readInt(verse['surah'], 'surah', entry.key);
    final int ayah = _readInt(verse['ayah'], 'ayah', entry.key);
    final String text = _stripTrailingAyahNumber(
      verse['text']?.toString() ?? '',
    );

    grouped.putIfAbsent(surah, () => <int, Map<String, Object?>>{})[ayah] =
        <String, Object?>{'surah': surah, 'ayah': ayah, 'text': text};
  }

  if (grouped.values.fold<int>(0, (int total, ayahs) => total + ayahs.length) !=
      6236) {
    throw StateError('Expected 6236 ayahs in qpc-hafs.json.');
  }

  output.createSync(recursive: true);
  for (int surah = 1; surah <= 114; surah++) {
    final Map<int, Map<String, Object?>>? ayahs = grouped[surah];
    if (ayahs == null) {
      throw StateError('Missing surah $surah.');
    }

    final List<int> ayahNumbers = ayahs.keys.toList()..sort();
    for (int index = 0; index < ayahNumbers.length; index++) {
      final int expected = index + 1;
      if (ayahNumbers[index] != expected) {
        throw StateError('Surah $surah is missing ayah $expected.');
      }
    }

    final Map<String, Object?> shard = <String, Object?>{
      'ayahs': <Map<String, Object?>>[
        for (final int ayah in ayahNumbers) ayahs[ayah]!,
      ],
    };
    final JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    File(
      '${output.path}/$surah.json',
    ).writeAsStringSync('${encoder.convert(shard)}\n');
  }
}

int _readInt(Object? value, String field, String key) {
  final int? parsed = value is int ? value : int.tryParse(value.toString());
  if (parsed == null) {
    throw FormatException('Verse $key has invalid $field.');
  }
  return parsed;
}

String _stripTrailingAyahNumber(String text) {
  return text.replaceFirst(RegExp(r'[\s\u00a0]*[0-9٠-٩]+$'), '');
}
