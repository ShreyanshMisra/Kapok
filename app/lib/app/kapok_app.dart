import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/providers/language_provider.dart';
// import '../core/utils/logger.dart'; // Commented out - map logs disabled
import '../core/providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../core/enums/user_role.dart';
import '../features/teams/bloc/team_bloc.dart';
import '../features/teams/bloc/team_event.dart';
import '../features/tasks/bloc/task_bloc.dart';
import '../features/tasks/bloc/task_event.dart';
import '../features/map/bloc/map_bloc.dart';
import '../features/map/bloc/map_event.dart';
import '../injection_container.dart';
import '../features/auth/pages/login_page.dart';
import '../core/services/first_login_service.dart';
import 'router.dart';

class KapokApp extends StatefulWidget {
  const KapokApp({super.key});

  @override
  State<KapokApp> createState() => _KapokAppState();
}

class _KapokAppState extends State<KapokApp> {
  // GlobalKey gives the BlocListener direct access to the NavigatorState,
  // bypassing the limitation that MaterialApp.builder's context sits above
  // the Navigator in the widget tree (making Navigator.maybeOf(context) null).
  final _navigatorKey = GlobalKey<NavigatorState>();

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
              navigatorKey: _navigatorKey,
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
              supportedLocales: const [Locale('en'), Locale('es')],
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: '/',
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listenWhen: (previous, current) {
                    if (current is AuthUnauthenticated) return true;
                    if (current is AuthLoading || current is AuthError) {
                      return false;
                    }
                    if (current is AuthAuthenticated) {
                      if (previous is! AuthAuthenticated) return true;
                      final prevAuth = previous;
                      final currAuth = current;
                      if (prevAuth.isNewSignup != currAuth.isNewSignup) {
                        return true;
                      }
                      if (!prevAuth.needsOnboarding && currAuth.needsOnboarding) {
                        return true;
                      }
                      return false;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    // _navigatorKey.currentState is always valid regardless of
                    // where this BlocListener sits in the widget tree relative
                    // to the Navigator (MaterialApp.builder context is above it).
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final navigator = _navigatorKey.currentState;
                      if (navigator == null || !navigator.mounted) return;

                      if (state is AuthUnauthenticated) {
                        try {
                          if (context.mounted) {
                            context.read<MapBloc>().add(MapReset());
                            await Future.delayed(const Duration(milliseconds: 50));
                            context.read<TeamBloc>().add(TeamReset());
                            context.read<TaskBloc>().add(TaskReset());
                          }
                        } catch (_) {}
                        navigator.pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      } else if (state is AuthAuthenticated) {
                        if (state.isNewSignup) {
                          if (state.user.userRole == UserRole.teamLeader) {
                            navigator.pushNamedAndRemoveUntil(
                              '/create-team',
                              (route) => false,
                            );
                          } else if (state.user.userRole == UserRole.teamMember) {
                            navigator.pushNamedAndRemoveUntil(
                              '/join-team',
                              (route) => false,
                            );
                          } else {
                            navigator.pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          }
                        } else if (state.needsOnboarding) {
                          navigator.pushNamedAndRemoveUntil(
                            '/role-selection',
                            (route) => false,
                          );
                        } else {
                          final isFirstLogin = !FirstLoginService.instance
                              .hasLoggedInBefore(state.user.id);
                          if (isFirstLogin) {
                            await FirstLoginService.instance
                                .markLoggedIn(state.user.id);
                            if (navigator.mounted) {
                              navigator.pushNamedAndRemoveUntil(
                                '/about',
                                (route) => false,
                              );
                            }
                          } else {
                            navigator.pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          }
                        }
                      }
                    });
                  },
                  child: child ?? const SizedBox.shrink(),
                );
              },
              // Show a spinner for all states except unauthenticated.
              // The BlocListener above (via _navigatorKey) handles all
              // authenticated routing, so the home widget only needs to
              // provide the initial shell before auth resolves.
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthUnauthenticated) {
                    return const LoginPage();
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
