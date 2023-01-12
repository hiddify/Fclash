// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fclash/main.dart';
import 'dart:io';

void main() {
  test("Yaml convert success", () async {
    final f = File("C:\\Users\\a1147\\Downloads\\douV2.yaml");
    final content = await f.readAsString();
    await convertConfig(content);
  });
}
