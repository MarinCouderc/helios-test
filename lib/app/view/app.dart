import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helios/l10n/l10n.dart';
import 'package:helios/welcome/view/welcome_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  GoRouter router() {
    return GoRouter(routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeView(),
      ),
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => child!,
      routerConfig: router(),
    );
  }
}
