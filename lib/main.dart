import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:poster_maker/features/poster/providers/poster_provider.dart';
import 'package:poster_maker/features/poster/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeshiPosterMakerApp());
}

class DeshiPosterMakerApp extends StatelessWidget {
  const DeshiPosterMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosterProvider()..init(),
      child: MaterialApp(
        title: 'देसी पोस्टर मेकर',
        debugShowCheckedModeBanner: false,

        // Material 3 Theme with authentic Indian palette
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD84315), // Deep Indian Saffron / Kesariya
            primary: const Color(0xFFD84315),
            secondary: const Color(0xFF1B5E20), // Rich Forest Green
            tertiary: const Color(0xFFFFB300), // Marigold Gold
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF9F9FB),
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E1E1E),
            titleTextStyle: GoogleFonts.rozhaOne(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          cardTheme: CardThemeData(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.white,
          ),
        ),

        // Support for Hindi and Indian regional localizations
        supportedLocales: const [
          Locale('hi', 'IN'),
          Locale('en', 'IN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        home: const HomeScreen(),
      ),
    );
  }
}
