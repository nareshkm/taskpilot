import 'package:flutter/material.dart';

// Slack-inspired theme definitions
const ColorScheme slackLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF4A154B),      // Slack brand purple
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF1264A3),    // Slack blue accent
  onSecondary: Color(0xFFFFFFFF),
  background: Color(0xFFF8F8F8),   // Light grey background
  onBackground: Color(0xFF1D1C1D),
  surface: Color(0xFFFFFFFF),      // White surfaces
  onSurface: Color(0xFF1D1C1D),
  error: Color(0xFFECB22E),        // Slack yellow
  onError: Color(0xFF000000),      
  tertiary: Color(0xFF2EB67D),     // Slack green
  onTertiary: Color(0xFFFFFFFF),
);

const ColorScheme slackDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF4A154B),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF1264A3),
  onSecondary: Color(0xFFFFFFFF),
  background: Color(0xFF1D1C1D),   // Dark background
  onBackground: Color(0xFFCCCCCC),
  surface: Color(0xFF2A2A2B),      // Dark surface
  onSurface: Color(0xFFFFFFFF),
  error: Color(0xFFECB22E),
  onError: Color(0xFF000000),
  tertiary: Color(0xFF2EB67D),     
  onTertiary: Color(0xFFFFFFFF),
);

/// Slack-style ThemeData using Material3
final ThemeData slackLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: slackLightColorScheme,
  scaffoldBackgroundColor: slackLightColorScheme.background,
);

final ThemeData slackDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: slackDarkColorScheme,
  scaffoldBackgroundColor: slackDarkColorScheme.background,
);