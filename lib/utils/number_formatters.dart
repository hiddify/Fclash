import 'dart:math';

import 'package:intl/intl.dart';

String formatByteSize(double size) {
  const base = 1024;
  if (size <= 0) return "0 B";
  final units = ["B", "kB", "MB", "GB", "TB"];
  final int digitGroups = (log(size) / log(base)).round();
  return "${NumberFormat("#,##0.#").format(size / pow(base, digitGroups))} ${units[digitGroups]}";
}
