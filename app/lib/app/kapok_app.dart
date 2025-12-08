import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/providers/language_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/teams/bloc/team_bloc.dart';
import '../features/tasks/bloc/task_bloc.dart';
import '../features/map/bloc/map_bloc.dart';
import '../injection_container.dart';
import '../features/auth/pages/login_page.dart';
import 'router.dart';
import 'home_page.dart';

class KapokApp extends StatelessWidget {
  const KapokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<TeamBloc>(create: (context) => sl<TeamBloc>()),
        BlocProvider<TaskBloc>(create: (context) => sl<TaskBloc>()),
        BlocProvider<MapBloc>(create: (context) => sl<MapBloc>()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: Consumer2<LanguageProvider, ThemeProvider>(
          builder: (context, languageProvider, themeProvider, _) {
            return MaterialApp(
              key: ValueKey(languageProvider.currentLocale.languageCode),
              title: 'Kapok',
              debugShowCheckedModeBanner: false,
              locale: languageProvider.currentLocale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
              ],
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    // Use post-frame callback to ensure Navigator is available
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (state is AuthUnauthenticated) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      } else if (state is AuthAuthenticated) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      }
                    });
                  },
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuthAuthenticated) {
                    return const HomePage();
                  } else {
                    // Default to login page for unauthenticated users
                    return const LoginPage();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
