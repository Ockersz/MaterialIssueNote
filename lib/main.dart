import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mri/data/fa_items/fa_items_details.dart';
import 'package:mri/data/fa_items/fa_items_repository.dart';
import 'package:mri/data/mri_items/mri_items_details.dart';
import 'package:mri/data/user/user_details.dart';
import 'package:mri/data/user/user_repository.dart';
import 'package:mri/login/view.dart';
import 'package:mri/mri/view.dart';
import 'package:mri/register/view.dart';
import 'package:mri/settings/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Hive.initFlutter();
  Hive.registerAdapter(UserDetailsAdapter());
  Hive.registerAdapter(FaItemsDetailsAdapter());
  Hive.registerAdapter(MriItemsDetailsAdapter());

  // Initialize repositories
  await UserRepository().init();
  await FaItemsRepository().init();

  // Check login status
  final bool isLoggedIn = await UserRepository().isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material Issue Note',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
          shadow: Colors.black,
          secondary: Colors.grey,
          error: Colors.red,
          surface: Colors.white,
          primary: Colors.black,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      initialRoute:
          isLoggedIn ? MaterialIssueNote.routeName : LoginPage.routeName,
      onGenerateRoute: (RouteSettings routeSettings) {
        WidgetBuilder builder;
        switch (routeSettings.name) {
          case LoginPage.routeName:
            builder = (BuildContext _) => const LoginPage();
            break;
          case RegisterPage.routeName:
            builder = (BuildContext _) => const RegisterPage();
            break;
          case MaterialIssueNote.routeName:
            builder = (BuildContext _) => const MaterialIssueNote();
            break;
          case Settings.routeName:
            builder = (BuildContext _) => const Settings();
            break;
          default:
            builder = (BuildContext _) => const MaterialIssueNote();
            break;
        }
        return MaterialPageRoute<void>(
          builder: builder,
          settings: routeSettings,
        );
      },
    );
  }
}
