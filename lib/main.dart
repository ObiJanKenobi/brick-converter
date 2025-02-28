import 'package:brick_converter/common_libs.dart';
import 'package:brick_lib/logic/brick_converter_logic.dart';
import 'package:brick_lib/logic/bricklink_logic.dart';
import 'package:brick_lib/model/part_group.dart';
import 'package:brick_converter/router.dart';
import 'package:brick_lib/service/rebrickable_service.dart';
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
                  seedColor: const Color(0xffA3B18A), secondary: const Color(0xFF344E41), tertiary: const Color(0xFF588157)))
          .copyWith(
              appBarTheme: AppBarTheme.of(context).copyWith(backgroundColor: const Color(0xFFA3B18A)),
              // backgroundColor: const Color(0xFFDAD7CD),
              scaffoldBackgroundColor: const Color(0xFFDAD7CD)),
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
