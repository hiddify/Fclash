import 'package:fclash/bootstrap.dart';
import 'package:flutter/widgets.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  return lazyBootstrap(widgetsBinding);
}
