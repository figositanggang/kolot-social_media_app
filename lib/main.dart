import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kolot/auth/auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolot/firebase_options.dart';
import 'package:kolot/provider/add_post_navigation_provider_.dart';
import 'package:kolot/provider/bottom_navigation_provider.dart';
import 'package:kolot/provider/auth_provider.dart';
import 'package:kolot/provider/search_bar_provider.dart';
import 'package:kolot/provider/text_field_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TextFieldProvider()),
        ChangeNotifierProvider(create: (context) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (context) => SearchBarProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) => AddPostNavigationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kolot",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Color.fromARGB(255, 8, 20, 25),
        textTheme:
            GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        dialogTheme:
            DialogTheme(backgroundColor: Color.fromARGB(255, 8, 20, 25)),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.withOpacity(.05),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        snackBarTheme:
            SnackBarThemeData(backgroundColor: Color.fromARGB(255, 0, 0, 0)),
        buttonTheme: ButtonThemeData(buttonColor: Colors.blue),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.black,
          elevation: 16,
          // splashColor: Colors.white.withOpacity(.5),
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(.5),
          ),
          errorStyle: TextStyle(color: Colors.amber),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 59, 178, 229),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.blue.withOpacity(.25),
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(fontSize: 10),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.blue,
          refreshBackgroundColor: Colors.black,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.blue),
          ),
        ),
        splashColor: Colors.transparent,
      ),
      home: AuthPage(),
    );
  }
}
