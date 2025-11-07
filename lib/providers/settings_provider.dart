import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool isDarkMode;
  final String currency;
  final String language;
  final bool notificationsEnabled;
  final int defaultTenureMonths;

  const SettingsState({
    this.isDarkMode = false,
    this.currency = 'INR',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.defaultTenureMonths = 12,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? currency,
    String? language,
    bool? notificationsEnabled,
    int? defaultTenureMonths,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultTenureMonths: defaultTenureMonths ?? this.defaultTenureMonths,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void setDefaultTenureMonths(int months) {
    state = state.copyWith(defaultTenureMonths: months);
  }

  void resetToDefaults() {
    state = const SettingsState();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
