import 'dart:async';

import 'package:flutter/material.dart';

/// Класс запуска приложения
mixin MainRunner {
  static T? _runZoned<T>(T Function() body) => runZoned(body);

  static void run({required Future<Widget> Function() appBuilder}) {
    _runZoned(() async {
      runApp(await appBuilder.call());
    });
  }
}
