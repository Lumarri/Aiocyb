import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/academy_screens.dart';
import 'state/academy_store.dart';
import 'theme.dart';

class AiocybApp extends StatelessWidget {
  const AiocybApp({super.key, required this.store});
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'Aiocyb · Aprende a protegerte',
      debugShowCheckedModeBanner: false,
      theme: academyTheme(
        false,
        palette: store.neonTheme,
        glow: store.neonGlow,
      ),
      darkTheme: academyTheme(
        true,
        palette: store.neonTheme,
        glow: store.neonGlow,
      ),
      themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: store.onboarded
          ? AcademyShell(store: store)
          : PresentationScreen(store: store),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1) * (store.largeText ? 1.15 : 1),
            ),
          ),
          child: Column(
            children: [
              Expanded(child: child ?? const SizedBox.shrink()),
              if (store.storageError != null)
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(child: Text(store.storageError!)),
                          TextButton(
                            onPressed: store.retrySave,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
