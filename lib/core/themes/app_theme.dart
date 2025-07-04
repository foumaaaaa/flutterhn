// TODO: Implementer le code pour core/themes/app_theme
import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';
import '../../app.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../database/database_helper.dart';
import '../../presentation/providers/article_provider.dart';
import '../../presentation/providers/comment_provider.dart';
import '../../presentation/providers/favorites_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../services/background_service.dart';

class AppTheme {
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;
}

// Mise à jour du main.dart pour inclure les timeago locales

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure timeago locale
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize background services
  await BackgroundService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const HackerNewsApp(),
    ),
  );
}
