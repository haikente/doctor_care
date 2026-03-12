import 'package:doctor_care/presentation/bloc/locale/locale_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'app_locale';

  LocaleCubit() : super(const LocaleInitial()) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'vi';
    emit(LocaleChanged(Locale(languageCode)));
  }

  Future<void> changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    emit(LocaleChanged(locale));
  }

  bool get isVietnamese => state.locale.languageCode == 'vi';
  bool get isEnglish => state.locale.languageCode == 'en';
  String get currentLanguageName => isVietnamese ? 'Tiếng Việt' : 'English';
}
