import 'dart:convert';
import 'dart:io';

void main() {
  // Read page_data.dart
  final pageDataContent = File('lib/page_data.dart').readAsStringSync();
  // wait, it's in third_party/quran_lite/lib/page_data.dart
}
