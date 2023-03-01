import 'package:brick_converter/common_libs.dart';
import 'package:brick_converter/logic/brick_converter_logic.dart';
import 'package:brick_converter/logic/bricklink_logic.dart';
import 'package:brick_converter/model/part_group.dart';
import 'package:brick_converter/router.dart';
import 'package:brick_converter/service/rebrickable_service.dart';
import 'package:brick_converter/ui/part_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

import 'logic/app_logic.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash screen up until app is finished bootstrapping
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Start app
  registerSingletons();

  runApp(MyApp());
  await appLogic.bootstrap();

  // Remove splash screen when bootstrap is complete
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget with GetItMixin {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      title: 'MOC Part Collector',
      theme: ThemeData.from(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xff562C2C), secondary: const Color(0xFF127475)))
          .copyWith(
              appBarTheme:
                  AppBarTheme.of(context).copyWith(backgroundColor: const Color(0xFF562C2C)),
              backgroundColor: const Color(0xFFF5DFBB),
              scaffoldBackgroundColor: const Color(0xFFF5DFBB)),
    );
  }
}

/// Create singletons (logic and services) that can be shared across the app.
void registerSingletons() {
  // Top level app controller
  GetIt.I.registerLazySingleton<AppLogic>(() => AppLogic());
  GetIt.I.registerLazySingleton<BrickConverterLogic>(() => BrickConverterLogic());
  GetIt.I.registerLazySingleton<RebrickableService>(() => RebrickableService());
  GetIt.I.registerLazySingleton<BricklinkLogic>(() => BricklinkLogic());
}

/// Add syntax sugar for quickly accessing the main "logic" controllers in the app
/// We deliberately do not create shortcuts for services, to discourage their use directly in the view/widget layer.
AppLogic get appLogic => GetIt.I.get<AppLogic>();

BrickConverterLogic get brickConverterLogic => GetIt.I.get<BrickConverterLogic>();

BricklinkLogic get bricklinkLogic => GetIt.I.get<BricklinkLogic>();

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
