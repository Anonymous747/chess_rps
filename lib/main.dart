import 'package:chess_rps/screen/mode_selector.dart';
import 'package:chess_rps/utils/app_routes.dart';
import 'package:chess_rps/utils/custom_router.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Root());

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: routerKey,
      routes: appRoutes,
      initialRoute: ModeSelector.routeName,
      onGenerateRoute: (settings) {
        final route = settings.name;

        if (route == null || route.isEmpty || !appRoutes.containsKey(route)) {
          return null;
        }

        return MaterialPageRoute(
            builder: (context) => appRoutes[route]!(context));
      },
    );
  }
}
