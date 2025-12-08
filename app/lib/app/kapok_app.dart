import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/providers/language_provider.dart';
import '../core/utils/logger.dart';
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
      child: ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return MaterialApp(
              key: ValueKey(languageProvider.currentLocale.languageCode),
              title: 'Kapok',
              debugShowCheckedModeBanner: false,
              locale: languageProvider.currentLocale,
              theme: ThemeData(
                primarySwatch:
                    MaterialColor(AppColors.primary.value, <int, Color>{
                      50: AppColors.primary.withOpacity(0.1),
                      100: AppColors.primary.withOpacity(0.2),
                      200: AppColors.primary.withOpacity(0.3),
                      300: AppColors.primary.withOpacity(0.4),
                      400: AppColors.primary.withOpacity(0.5),
                      500: AppColors.primary,
                      600: AppColors.primaryDark,
                      700: AppColors.primaryDark,
                      800: AppColors.primaryDark,
                      900: AppColors.primaryDark,
                    }),
                scaffoldBackgroundColor: AppColors.background,
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  elevation: 0,
                ),
                useMaterial3: true,
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('es')],
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listenWhen: (previous, current) {
                    // Only navigate on significant state changes, not on every update
                    if (current is AuthUnauthenticated) {
                      return true; // Always navigate on logout
                    }
                    if (current is AuthAuthenticated) {
                      // Only navigate if:
                      // 1. This is the first authentication (previous was not authenticated)
                      // 2. This is a new signup
                      // 3. Onboarding status changed from false to true
                      if (previous is! AuthAuthenticated) {
                        return true; // First authentication
                      }
                      final prevAuth = previous;
                      final currAuth = current;
                      // Navigate if signup status changed or onboarding became needed
                      if (prevAuth.isNewSignup != currAuth.isNewSignup) {
                        return true;
                      }
                      if (!prevAuth.needsOnboarding &&
                          currAuth.needsOnboarding) {
                        return true; // User now needs onboarding
                      }
                      // Don't navigate on profile updates (like joining a team)
                      return false;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    // Use post-frame callback to ensure Navigator is available
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (state is AuthUnauthenticated) {
                        // Reset all BLoCs on logout to stop map and clear state
                        Logger.auth('Resetting BLoCs on logout');
                        try {
                          // Reset map first to stop it immediately
                          // This will emit MapLoading state which triggers map disposal
                          context.read<MapBloc>().add(MapReset());
                          // Give time for map to dispose
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                          // Reset other BLoCs
                          context.read<TeamBloc>().add(TeamReset());
                          context.read<TaskBloc>().add(TaskReset());
                        } catch (e) {
                          Logger.auth('Error resetting BLoCs', error: e);
                        }

                        // Navigate to login page - this will dispose MapPage widget
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      } else if (state is AuthAuthenticated) {
                        // New signup: navigate based on role immediately
                        if (state.isNewSignup) {
                          if (state.user.userRole == UserRole.teamLeader) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/create-team',
                              (route) => false,
                            );
                          } else if (state.user.userRole ==
                              UserRole.teamMember) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/join-team',
                              (route) => false,
                            );
                          } else {
                            // Admin
                            Navigator.of(context).pushNamedAndRemoveUntil(
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
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/role-selection',
                              (route) => false,
                            );
                          }
                        } else {
                          // Fully set up user - only navigate if on login/signup pages
                          final currentRoute = ModalRoute.of(
                            context,
                          )?.settings.name;
                          if (currentRoute == '/login' ||
                              currentRoute == '/signup' ||
                              currentRoute == '/role-selection') {
                            Navigator.of(context).pushNamedAndRemoveUntil(
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
