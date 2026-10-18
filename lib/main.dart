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
      child: Consumer<PosterProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'देसी पोस्टर मेकर',
            debugShowCheckedModeBanner: false,

            // Dynamic Light & Dark Mode
            themeMode: provider.themeMode,

            // Material 3 Light Theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFD84315), // Deep Indian Saffron
                primary: const Color(0xFFD84315),
                secondary: const Color(0xFF1B5E20), // Forest Green
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
                ThemeData.light().textTheme,
              ),
              cardTheme: CardThemeData(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Colors.white,
              ),
              segmentedButtonTheme: SegmentedButtonThemeData(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      const Color(0xFFD84315).withOpacity(0.15),
                  selectedForegroundColor: const Color(0xFFD84315),
                ),
              ),
            ),

            // Material 3 Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFD84315),
                primary: const Color(0xFFFF7043),
                secondary: const Color(0xFF4CAF50),
                tertiary: const Color(0xFFFFCA28),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121214),
              appBarTheme: AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 2,
                backgroundColor: const Color(0xFF1A1A1E),
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.rozhaOne(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
              cardTheme: CardThemeData(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: const Color(0xFF1E1E24),
              ),
              segmentedButtonTheme: SegmentedButtonThemeData(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      const Color(0xFFFF7043).withOpacity(0.25),
                  selectedForegroundColor: const Color(0xFFFF8A65),
                ),
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
          );
        },
      ),
    );
  }
}
