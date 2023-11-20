import 'package:flutter/material.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:studyingx/data/prefs.dart';
import 'package:studyingx/data/file_manager.dart';

void main() {
  initializeDateFormatting().then((_) {
    WidgetsFlutterBinding.ensureInitialized();

    Prefs.init();
    FileManager.init();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PencilKitState()),
        ],
        child: const StudyingXApp(),
      ),
    );
  });
}

class StudyingXApp extends StatelessWidget {
  const StudyingXApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyingX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: routes,
    );
  }
}
