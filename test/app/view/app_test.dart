import 'package:flutter_test/flutter_test.dart';
import 'package:helios/app/app.dart';
import 'package:helios/app/welcome/view/welcome_view.dart';

void main() {
  group('App', () {
    testWidgets('renders welcomePage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(WelcomeView), findsOneWidget);
    });
  });
}
