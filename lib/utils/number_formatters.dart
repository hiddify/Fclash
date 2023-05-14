import 'dart:math';

import 'package:intl/intl.dart';

String formatByteSize(int size) {
  const base = 1024;
  if (size <= 0) return "0 B";
  final units = ["B", "kB", "MB", "GB", "TB"];
  final int digitGroups = (log(size) / log(base)).round();
  return "${NumberFormat("#,##0.#").format(size / pow(base, digitGroups))} ${units[digitGroups]}";
}

String formatTrafficByteSize(int consumption, int total) {
  const base = 1024;
  if (total <= 0) return "0 B";
  final formatter = NumberFormat("#,##0.#");
  return "${formatter.format(consumption / pow(base, 3))} / ${formatter.format(total / pow(base, 3))} GB";
}
