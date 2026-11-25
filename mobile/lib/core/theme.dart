import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colors — merah donor darah
  static const Color primary      = Color(0xFFC62828); // merah tua
  static const Color primaryLight = Color(0xFFEF5350); // merah muda
  static const Color primaryDark  = Color(0xFF8E0000); // merah gelap
  static const Color onPrimary    = Color(0xFFFFFFFF);
  static const Color secondary    = Color(0xFFFFFFFF); // putih
  static const Color background   = Color(0xFFF5F5F5);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color error        = Color(0xFFB00020);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness:       Brightness.light,
      primary:          primary,
      onPrimary:        onPrimary,
      primaryContainer: Color(0xFFFFDAD6),
      onPrimaryContainer: Color(0xFF410001),
      secondary:        Color(0xFF775652),
      onSecondary:      onPrimary,
      secondaryContainer: Color(0xFFFFDAD6),
      onSecondaryContainer: Color(0xFF2C1512),
      tertiary:         Color(0xFF755A2F),
      onTertiary:       onPrimary,
      tertiaryContainer: Color(0xFFFFDDAE),
      onTertiaryContainer: Color(0xFF291800),
      error:            error,
      onError:          onPrimary,
      errorContainer:   Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410001),
      surface:          surface,
      onSurface:        Color(0xFF201A19),
      surfaceContainerHighest: Color(0xFFEDE0DE),
      outline:          Color(0xFF857370),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: surface,
    ),
    scaffoldBackgroundColor: background,
  );
}
