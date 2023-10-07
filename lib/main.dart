import 'package:flutter/material.dart';
import 'package:studyingx/routes/pages/initial_page.dart';
import 'package:studyingx/routes/routes.dart';

void main() {
  runApp(const StudyingXApp());
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
