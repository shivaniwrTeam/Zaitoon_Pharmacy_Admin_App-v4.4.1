import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoLocalization {
  DemoLocalization(this.locale);
  final Locale locale;
  static DemoLocalization? of(BuildContext context) {
    return Localizations.of<DemoLocalization>(context, DemoLocalization);
  }

  static late Map<String, String> _localizedValues;
  Future<void> load() async {
    print("path : lib/Language/${locale.languageCode}.json");
    final String jsonStringValues =
        await rootBundle.loadString('lib/Language/${locale.languageCode}.json');
    final Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues = mappedJson.map(
      (key, value) => MapEntry(
        key,
        value.toString(),
      ),
    );
  }

  String? translate(String key) {
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<DemoLocalization> delegate =
      _DemoLocalizationsDelegate();
}

class _DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalization> {
  const _DemoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      // 'zh',
      // 'es',
      // 'hi',
      'ar',
      // 'ru',
      // 'ja',
      // 'de',
    ].contains(locale.languageCode);
  }

  @override
  Future<DemoLocalization> load(Locale locale) async {
    final DemoLocalization localization = DemoLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalization> old) => false;
}
