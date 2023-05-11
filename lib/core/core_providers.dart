import 'package:fclash/core/prefs/locale/locale.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class Core {
  static final translations = Provider(
    (ref) => ref.watch(LocaleController.provider).translations(),
  );
}
