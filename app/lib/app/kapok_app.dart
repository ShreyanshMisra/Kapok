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
              supportedLocales: const [Locale('en'), Locale('es')],
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: '/',
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listenWhen: (previous, current) {
                    // Only navigate on significant state changes, not on every update
                    if (current is AuthUnauthenticated) {
                      return true; // Always navigate on logout
                    }
                    // NEVER navigate on AuthLoading or AuthError - user should stay where they are
                    if (current is AuthLoading || current is AuthError) {
                      return false; // Don't navigate on loading or errors
                    }
                    if (current is AuthAuthenticated) {
                      // Only navigate if:
                      // 1. This is the first authentication (previous was not authenticated)
                      // 2. This is a new signup
                      // 3. Onboarding status changed from false to true (not when completed)
                      if (previous is! AuthAuthenticated) {
                        return true; // First authentication - always navigate
                      }
                      final prevAuth = previous;
                      final currAuth = current;
                      // Navigate if signup status changed
                      if (prevAuth.isNewSignup != currAuth.isNewSignup) {
                        return true;
                      }
                      // Only navigate if onboarding became needed (not when it's completed)
                      // This prevents navigation when user joins/creates team
                      if (!prevAuth.needsOnboarding &&
                          currAuth.needsOnboarding) {
                        return true; // User now needs onboarding
                      }
                      // Don't navigate on profile updates (like joining/creating team)
                      // This includes when needsOnboarding changes from true to false
                      // This includes when teamId is updated
                      return false;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    // Use post-frame callback to ensure Navigator is available
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      // Check if context is still mounted and has a Navigator
                      if (!context.mounted) return;
                      final navigator = Navigator.maybeOf(context);
                      if (navigator == null) return;

                      if (state is AuthUnauthenticated) {
                        // Reset all BLoCs on logout to stop map and clear state
                        // Logger.auth('Resetting BLoCs on logout'); // Commented out - map logs disabled
                        try {
                          // Reset map first to stop it immediately
                          // This will emit MapLoading state which triggers map disposal
                          context.read<MapBloc>().add(MapReset());
                          // Give minimal time for map to dispose
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );
                          // Reset other BLoCs
                          context.read<TeamBloc>().add(TeamReset());
                          context.read<TaskBloc>().add(TaskReset());
                        } catch (e) {
                          // Logger.auth('Error resetting BLoCs', error: e); // Commented out - map logs disabled
                        }

                        // Only navigate if not already navigated (settings page handles its own navigation)
                        // This is a fallback for other logout scenarios
                        if (context.mounted &&
                            Navigator.maybeOf(context) != null) {
                          final currentRoute = ModalRoute.of(context);
                          if (currentRoute?.settings.name != '/login') {
                            navigator.pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        }
                      } else if (state is AuthAuthenticated) {
                        // Check again before navigation
                        if (!context.mounted ||
                            Navigator.maybeOf(context) == null) {
                          return;
                        }

                        // New signup: navigate based on role immediately
                        if (state.isNewSignup) {
                          if (state.user.userRole == UserRole.teamLeader) {
                            navigator.pushNamedAndRemoveUntil(
                              '/create-team',
                              (route) => false,
                            );
                          } else if (state.user.userRole ==
                              UserRole.teamMember) {
                            navigator.pushNamedAndRemoveUntil(
                              '/join-team',
                              (route) => false,
                            );
                          } else {
                            // Admin
                            navigator.pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          }
                        } else if (state.needsOnboarding) {
                          // Existing user needs onboarding (missing team or role)
                          final currentRoute = ModalRoute.of(
                            context,
                          )?.settings.name;
                          // Only navigate if not already on onboarding pages
                          if (currentRoute != '/role-selection' &&
                              currentRoute != '/create-team' &&
                              currentRoute != '/join-team') {
                            navigator.pushNamedAndRemoveUntil(
                              '/role-selection',
                              (route) => false,
                            );
                          }
                        } else {
                          // Fully set up user - only navigate to home if:
                          // 1. Not already on home
                          // 2. Not on create-team or join-team pages (let them handle their own navigation)
                          final currentRoute = ModalRoute.of(
                            context,
                          )?.settings.name;
                          // Don't navigate if we're on onboarding pages - they handle their own navigation
                          if (currentRoute != '/home' &&
                              currentRoute != '/create-team' &&
                              currentRoute != '/join-team' &&
                              currentRoute != '/role-selection') {
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
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuthAuthenticated) {
                    return const HomePage();
                  } else if (state is AuthUnauthenticated) {
                    return const LoginPage();
                  } else {
                    // For AuthError or other states, default to login
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
