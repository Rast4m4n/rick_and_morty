import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/app/app.dart';
import 'package:rick_and_morty/core/di/di_scope.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/core/di/i_di_scope.dart';

abstract interface class IAppBuilder {
  /// Метод сборки приложения
  Future<Widget> build();

  Widget getApp();

  /// Метод для инициализации асинхронных операций перед запуском приложения
  Future<void> init();
}

class AppBuilder implements IAppBuilder {
  late final IDiScope diScope;
  late final bool isAuth;
  @override
  Future<Widget> build() async {
    await init();
    return getApp();
  }

  @override
  Widget getApp() {
    return DiScopeProvider(diScope: diScope, child: App());
  }

  @override
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    diScope = DiScope();
    await diScope.init();
  }
}
