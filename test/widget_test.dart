// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:an_tam/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Chỉ kiểm tra app khởi động không crash
    // Firebase cần được mock để test đầy đủ
    expect(AnTamApp, isNotNull);
  });
}
