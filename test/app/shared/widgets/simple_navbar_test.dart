import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:helios/app/shared/shared.dart';

void main() {
  group('SimpleNavbar', () {
    testWidgets('renders navbar with two buttons', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Accueil')),
              bottomNavigationBar: SimpleNavbar(),
            ),
          ),
          GoRoute(
            path: '/user-list',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Utilisateurs')),
              bottomNavigationBar: SimpleNavbar(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      expect(find.byType(SimpleNavbar), findsOneWidget);
      
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('highlights active route correctly', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Welcome Page')),
              bottomNavigationBar: SimpleNavbar(),
            ),
          ),
          GoRoute(
            path: '/user-list',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Users Page')),
              bottomNavigationBar: SimpleNavbar(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();
      
      expect(find.text('Users Page'), findsOneWidget);
      
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });
  });
}
