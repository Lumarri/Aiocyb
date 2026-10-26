import 'package:flutter/material.dart';

const mint = Color(0xFF57E5C0);
const ink = Color(0xFF0B1018);

enum NeonTheme { cyan, violet }

class NeonStyle extends ThemeExtension<NeonStyle> {
  const NeonStyle({required this.glow});
  final bool glow;
  @override
  NeonStyle copyWith({bool? glow}) => NeonStyle(glow: glow ?? this.glow);
  @override
  NeonStyle lerp(covariant NeonStyle? other, double t) =>
      t < .5 ? this : other ?? this;
}

ThemeData academyTheme(
  bool dark, {
  NeonTheme palette = NeonTheme.cyan,
  bool glow = true,
}) {
  final accent = palette == NeonTheme.cyan
      ? (dark ? const Color(0xFF67E8F9) : const Color(0xFF006578))
      : (dark ? const Color(0xFFC4B5FD) : const Color(0xFF6544A5));
  final scheme =
      ColorScheme.fromSeed(
        seedColor: accent,
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: accent,
        onPrimary: dark ? ink : Colors.white,
        surface: dark ? const Color(0xFF131C28) : Colors.white,
      );
  return ThemeData(
    useMaterial3: true,
    extensions: [NeonStyle(glow: glow)],
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? ink : const Color(0xFFF2F5F6),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? ink : const Color(0xFFF2F5F6),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: dark
              ? accent.withValues(alpha: .22)
              : scheme.outlineVariant.withValues(alpha: .65),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -1.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -.6,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.65),
      bodyMedium: TextStyle(fontSize: 14, height: 1.55),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.all(18),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: .15),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.primary.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(6),
      linearMinHeight: 6,
    ),
  );
}
