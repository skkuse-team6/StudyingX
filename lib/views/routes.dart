import 'pages/note_page.dart';
import 'pages/home_page.dart';
import 'pages/initial_page.dart';

// route names
const String initialPage = '/';
const String homePage = '/home';
const String notePage = '/note';

final routes = {
  initialPage: (context) => const InitialPage(),
  homePage: (context) => const HomePage(),
  notePage: (context) => const NotePage(),
};
