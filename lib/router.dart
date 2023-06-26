import 'package:brick_converter/screens/add_file_screen.dart';
import 'package:brick_converter/screens/blicklink_screen.dart';
import 'package:brick_converter/screens/ordered_screen.dart';
import 'package:brick_converter/screens/part_group_screen.dart';
import 'package:brick_converter/ui/back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:brick_converter/common_libs.dart';

/// Shared paths / urls used across the app
class ScreenPaths {
  static String splash = '/';
  static String home = '/home';
  static String settings = '/settings';
  static String ordered = '/ordered';
  static String bricklink = '/bricklink';

  static String partGroup(String partNum) => '/partgroup/$partNum';
}

/// Routing table, matches string paths to UI Screens, optionally parses params from the paths
final appRouter = GoRouter(
  redirect: _handleRedirect,
  // navigatorBuilder: (_, __, child) => Scaffold(body: child),
  routes: [
    AppRoute(ScreenPaths.splash, (_) => Container(color: const Color(0xFF562C2C))),
    // This will be hidden
    AppRoute(ScreenPaths.home, (_) => AddFileScreen()),
    AppRoute(ScreenPaths.bricklink, (_) => const BricklinkScreen()),
    AppRoute(ScreenPaths.ordered, (_) => const OrderedScreen()),
    AppRoute('/partgroup/:partNum', (s) {
      final group = s.extra! as PartGroup;
      return PartGroupScreen(group);
    }, showAppBar: true, useFade: true),
  ],
);

/// Custom GoRoute sub-class to make the router declaration easier to read
class AppRoute extends GoRoute {
  AppRoute(String path, Widget Function(GoRouterState s) builder,
      {List<GoRoute> routes = const [], this.useFade = false, this.showAppBar = false})
      : super(
          path: path,
          routes: routes,
          pageBuilder: (context, state) {
            final pageContent = Scaffold(
              appBar: showAppBar
                  ? AppBar(
                      title: Text(_getAppBarTitle(state)),
                      leading: const MyBackButton(),
                    )
                  : null,
              body: builder(state),
              resizeToAvoidBottomInset: false,
            );
            if (useFade) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return MaterialPage(child: pageContent);
          },
        );
  final bool useFade;
  final bool showAppBar;

  static String _getAppBarTitle(GoRouterState state) {
    if (state.extra is PartGroup) {
      final group = state.extra! as PartGroup;
      return group.partName;
    }

    return "Zurück";
  }
}

String? _handleRedirect(BuildContext context, GoRouterState state) {
  // Prevent anyone from navigating away from `/` if app is starting up.
  if (!appLogic.isBootstrapComplete && state.location != ScreenPaths.splash) {
    return ScreenPaths.splash;
  }
  debugPrint('Navigate to: ${state.location}');
  return null; // do nothing
}
