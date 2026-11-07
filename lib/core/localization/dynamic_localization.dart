import 'package:flutter/widgets.dart';

/// Reads localized values from Firestore without requiring a network translator.
/// Supports plain strings, {ar,en,fr} maps, and sibling nameEn/nameFr fields.
String localizedValue(
  dynamic value,
  Locale locale, {
  String fallback = '',
}) {
  final language = locale.languageCode.toLowerCase();
  if (value is Map) {
    final direct = _nonEmpty(value[language]);
    if (direct != null) return direct;
    final alias = _nonEmpty(value[language == 'en' ? 'english' : language == 'fr' ? 'french' : 'arabic']);
    if (alias != null) return alias;
    final name = _nonEmpty(value['name']);
    if (name != null) return name;
    return fallback;
  }
  return _nonEmpty(value) ?? fallback;
}

String localizedField(
  Map<String, dynamic> data,
  String field,
  Locale locale, {
  String fallback = '',
}) {
  final language = locale.languageCode.toLowerCase();
  final localized = language == 'en'
      ? ['${field}En', '${field}_en', '${field}English']
      : language == 'fr'
          ? ['${field}Fr', '${field}_fr', '${field}French']
          : ['${field}Ar', '${field}_ar', '${field}Arabic'];
  for (final key in localized) {
    final candidate = _nonEmpty(data[key]);
    if (candidate != null) return candidate;
  }
  final translations = data['translations'];
  if (translations is Map) {
    final translated = _nonEmpty(translations[language]);
    if (translated != null) return translated;
  }
  return localizedValue(data[field], locale, fallback: fallback);
}

String? _nonEmpty(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
