import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:campus_os/main.dart';
import 'package:campus_os/services/storage_service.dart';
import 'package:campus_os/providers/campus_provider.dart';
import 'package:campus_os/providers/auth_provider.dart';
import 'package:campus_os/providers/chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CampusOSApp loads successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CampusProvider(storageService: storageService)),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const CampusOSApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Shahzaib Ahmad'), findsWidgets);
  });
}
