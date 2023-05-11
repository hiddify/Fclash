import 'package:fclash/core/prefs/locale/app_locale.dart';
import 'package:fclash/data/data_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocaleController extends Notifier<AppLocale> with AppLogger {
  static final provider =
      NotifierProvider<LocaleController, AppLocale>(LocaleController.new);

  @override
  AppLocale build() {
    return AppLocale.en;
  }

  Preferences get _prefs => ref.read(Data.preferences);

  Future<void> init() async {
    loggy.debug('initializing');
    state = AppLocale.values[_prefs.getInt('locale', 0)];
  }

  Future<void> change(AppLocale locale) async {
    loggy.debug('changing locale to [$locale]');
    _prefs.setInt('locale', locale.index);
    state = locale;
  }
}
