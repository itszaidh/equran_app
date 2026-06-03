// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  // Read page_data.dart
  final file = File('lib/page_data.dart');
  if (file.existsSync()) {
    final pageDataContent = file.readAsStringSync();
    print('Length: ${pageDataContent.length}');
  }
}
