import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

const Map<String, String> _dartFileToResourceId = <String, String>{
  'en_saheeh.dart': 'en_saheeh',
  'en_clear_quran.dart': 'en_clear_quran',
  'tr_saheeh.dart': 'tr_saheeh',
  'ml_abdulhameed.dart': 'ml_abdul_hameed',
  'fa_hussein_dari.dart': 'fa_hussein_dari',
  'fr_hamidullah.dart': 'fr_hamidullah',
  'it_piccardo.dart': 'it_piccardo',
  'nl_siregar.dart': 'nl_siregar',
  'portuguese.dart': 'portuguese',
  'ru_kuliev.dart': 'ru_kuliev',
  'urdu.dart': 'urdu',
  'bengali.dart': 'bengali',
  'chinese.dart': 'chinese',
  'indonesian.dart': 'indonesian',
  'spanish.dart': 'spanish',
  'swedish.dart': 'swedish',
};

const Map<String, String> _resourceNames = <String, String>{
  'en_saheeh': 'English Saheeh',
  'en_clear_quran': 'English Clear Quran',
  'tr_saheeh': 'Turkish Saheeh',
  'ml_abdul_hameed': 'Malayalam Abdul Hameed',
  'fa_hussein_dari': 'Persian Hussein Dari',
  'fr_hamidullah': 'French Hamidullah',
  'it_piccardo': 'Italian Piccardo',
  'nl_siregar': 'Dutch Siregar',
  'portuguese': 'Portuguese',
  'ru_kuliev': 'Russian Kuliev',
  'urdu': 'Urdu',
  'bengali': 'Bengali',
  'chinese': 'Chinese',
  'indonesian': 'Indonesian',
  'spanish': 'Spanish',
  'swedish': 'Swedish',
};

const Map<String, String> _resourceLanguages = <String, String>{
  'en_saheeh': 'en',
  'en_clear_quran': 'en',
  'tr_saheeh': 'tr',
  'ml_abdul_hameed': 'ml',
  'fa_hussein_dari': 'fa',
  'fr_hamidullah': 'fr',
  'it_piccardo': 'it',
  'nl_siregar': 'nl',
  'portuguese': 'pt',
  'ru_kuliev': 'ru',
  'urdu': 'ur',
  'bengali': 'bn',
  'chinese': 'zh',
  'indonesian': 'id',
  'spanish': 'es',
  'swedish': 'sv',
};

const List<int> _verseCounts = <int>[
  7,
  286,
  200,
  176,
  120,
  165,
  206,
  75,
  129,
  109,
  123,
  111,
  43,
  52,
  99,
  128,
  111,
  110,
  98,
  135,
  112,
  78,
  118,
  64,
  77,
  227,
  93,
  88,
  69,
  60,
  34,
  30,
  73,
  54,
  45,
  83,
  182,
  88,
  75,
  85,
  54,
  53,
  89,
  59,
  37,
  35,
  38,
  29,
  18,
  45,
  60,
  49,
  62,
  55,
  78,
  96,
  29,
  22,
  24,
  13,
  14,
  11,
  11,
  18,
  12,
  12,
  30,
  52,
  52,
  44,
  28,
  28,
  20,
  56,
  40,
  31,
  50,
  40,
  46,
  42,
  29,
  19,
  36,
  25,
  22,
  17,
  19,
  26,
  30,
  20,
  15,
  21,
  11,
  8,
  8,
  19,
  5,
  8,
  8,
  11,
  11,
  8,
  3,
  9,
  5,
  4,
  7,
  3,
  6,
  3,
  5,
  4,
  5,
  6,
];

Future<void> main(List<String> args) async {
  final _Options options = _Options.parse(args);
  if (options.help) {
    stdout.writeln(_usage);
    return;
  }

  final Directory source = Directory(options.sourceDirectory);
  if (!source.existsSync()) {
    stderr.writeln('Source directory does not exist: ${source.path}');
    exitCode = 64;
    return;
  }

  final Directory output = Directory(options.outputDirectory);
  final Directory jsonRoot = Directory('${output.path}/translations');
  final Directory zipRoot = Directory('${output.path}/zips');
  await jsonRoot.create(recursive: true);
  await zipRoot.create(recursive: true);

  final List<Map<String, Object?>> manifestEntries = <Map<String, Object?>>[];
  final List<String> skipped = <String>[];

  for (final MapEntry<String, String> item in _dartFileToResourceId.entries) {
    final File sourceFile = File('${source.path}/${item.key}');
    if (!sourceFile.existsSync()) {
      stdout.writeln('Skipping missing ${item.key}');
      continue;
    }

    final String resourceId = item.value;
    final Directory languageDirectory = Directory(
      '${jsonRoot.path}/$resourceId',
    );
    if (languageDirectory.existsSync()) {
      await languageDirectory.delete(recursive: true);
    }
    await languageDirectory.create(recursive: true);

    final int ayahCount;
    try {
      ayahCount = await _writePerSurahJson(
        sourceFile: sourceFile,
        outputDirectory: languageDirectory,
      );
    } on FormatException catch (error) {
      skipped.add('${item.key}: ${error.message}');
      await languageDirectory.delete(recursive: true);
      stdout.writeln('Skipping ${item.key}: ${error.message}');
      continue;
    }

    final File zipFile = File('${zipRoot.path}/$resourceId.zip');
    if (zipFile.existsSync()) {
      await zipFile.delete();
    }
    final ZipFileEncoder encoder = ZipFileEncoder();
    encoder.create(zipFile.path);
    await encoder.addDirectory(languageDirectory, includeDirName: false);
    encoder.close();

    final int sizeBytes = await zipFile.length();
    final String digest = await sha256
        .bind(zipFile.openRead())
        .first
        .then((Digest value) => value.toString());
    manifestEntries.add(<String, Object?>{
      'id': resourceId,
      'type': 'translation',
      'name': _resourceNames[resourceId] ?? resourceId,
      'language': _resourceLanguages[resourceId],
      'version': options.version,
      'url': '${options.baseUrl}/$resourceId.zip',
      'sha256': digest,
      'sizeBytes': sizeBytes,
    });

    stdout.writeln(
      'Wrote $resourceId: $ayahCount ayahs, ${zipFile.path}, $sizeBytes bytes',
    );
  }

  manifestEntries.sort((a, b) {
    return (a['id'] as String).compareTo(b['id'] as String);
  });
  final File manifestFile = File(
    '${output.path}/translation_manifest_entries.json',
  );
  await manifestFile.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(manifestEntries)}\n',
  );
  stdout.writeln('Manifest entries: ${manifestFile.path}');
  if (skipped.isNotEmpty) {
    stdout.writeln('\nSkipped incomplete or invalid files:');
    for (final String message in skipped) {
      stdout.writeln('- $message');
    }
  }
}

Future<int> _writePerSurahJson({
  required File sourceFile,
  required Directory outputDirectory,
}) async {
  final String raw = await sourceFile.readAsString();
  final Map<int, List<Map<String, Object?>>> bySurah =
      <int, List<Map<String, Object?>>>{};

  for (final RegExpMatch match in _translationEntryPattern.allMatches(raw)) {
    final int surah = int.parse(match.group(1)!);
    final int ayah = int.parse(match.group(2)!);
    final String text = _decodeDartString(match.group(3)!);
    bySurah.putIfAbsent(surah, () => <Map<String, Object?>>[]).add(
      <String, Object?>{'surah': surah, 'ayah': ayah, 'text': text},
    );
  }

  if (bySurah.length != 114) {
    throw FormatException(
      'Expected 114 surahs in ${sourceFile.path}, found ${bySurah.length}.',
    );
  }

  int ayahCount = 0;
  for (int surah = 1; surah <= 114; surah++) {
    final List<Map<String, Object?>> ayahs = bySurah[surah]!
      ..sort((a, b) => (a['ayah']! as int).compareTo(b['ayah']! as int));
    final int expectedAyahs = _verseCounts[surah - 1];
    if (ayahs.length != expectedAyahs) {
      throw FormatException(
        'Surah $surah expected $expectedAyahs ayahs, found ${ayahs.length}.',
      );
    }
    ayahCount += ayahs.length;
    await File('${outputDirectory.path}/$surah.json').writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'ayahs': ayahs})}\n',
    );
  }
  return ayahCount;
}

final RegExp _translationEntryPattern = RegExp(
  r'\{\s*"surah_number":\s*(\d+),\s*"verse_number":\s*(\d+),\s*"content":\s*("(?:[^"\\]|\\.)*")\s*,?\s*\}',
  multiLine: true,
  dotAll: true,
);

String _decodeDartString(String rawLiteral) {
  try {
    return jsonDecode(rawLiteral) as String;
  } on FormatException {
    final String sanitized = rawLiteral
        .replaceAll('\t', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ');
    return jsonDecode(sanitized) as String;
  }
}

class _Options {
  const _Options({
    required this.sourceDirectory,
    required this.outputDirectory,
    required this.baseUrl,
    required this.version,
    required this.help,
  });

  factory _Options.parse(List<String> args) {
    String sourceDirectory = Directory.current.path;
    String outputDirectory = 'build/quran_translation_packs';
    String baseUrl =
        'https://github.com/ya27hw/equran-assets/releases/latest/download';
    String version = '1.0.0';
    bool help = false;

    for (int i = 0; i < args.length; i++) {
      final String arg = args[i];
      String readValue(String name) {
        if (i + 1 >= args.length) {
          throw ArgumentError('Missing value for $name');
        }
        return args[++i];
      }

      if (arg == '--help' || arg == '-h') {
        help = true;
      } else if (arg == '--source') {
        sourceDirectory = readValue(arg);
      } else if (arg == '--out') {
        outputDirectory = readValue(arg);
      } else if (arg == '--base-url') {
        baseUrl = readValue(arg).replaceFirst(RegExp(r'/+$'), '');
      } else if (arg == '--version') {
        version = readValue(arg);
      } else {
        sourceDirectory = arg;
      }
    }

    return _Options(
      sourceDirectory: sourceDirectory,
      outputDirectory: outputDirectory,
      baseUrl: baseUrl,
      version: version,
      help: help,
    );
  }

  final String sourceDirectory;
  final String outputDirectory;
  final String baseUrl;
  final String version;
  final bool help;
}

const String _usage = '''
JSON-ify quran package translation Dart files and ZIP each language.

Usage:
  dart run tool/jsonify_quran_translations.dart [translations_dir]

Options:
  --source <dir>    Directory containing quran package translation .dart files.
                   Defaults to the current directory.
  --out <dir>       Output directory. Defaults to build/quran_translation_packs.
  --base-url <url>  Base URL used in generated manifest snippets.
  --version <ver>   Resource version. Defaults to 1.0.0.

Examples:
  dart run tool/jsonify_quran_translations.dart \\
    /home/yousuf/.pub-cache/hosted/pub.dev/quran-1.4.1/lib/translations

  cd /home/yousuf/.pub-cache/hosted/pub.dev/quran-1.4.1/lib/translations
  dart run /home/yousuf/Documents/Personal\\ Projects/equran-app/tool/jsonify_quran_translations.dart \\
    --out /home/yousuf/Documents/Personal\\ Projects/equran-app/build/quran_translation_packs
''';
