import 'package:flutter_test/flutter_test.dart';
import 'package:first_flutter_project/main.dart';

void main() {
  testWidgets('AI Football Coach app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AIFootballCoachApp());

    expect(find.text('AI FOOTBALL COACH'), findsOneWidget);
  });
}
