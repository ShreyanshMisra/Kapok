import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/constants/app_colors.dart';
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
      child: MaterialApp(
        title: 'Kapok',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(AppColors.primary.value, <int, Color>{
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
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              // Use post-frame callback to ensure Navigator is available
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (state is AuthUnauthenticated) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                } else if (state is AuthAuthenticated) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
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
      ),
    );
  }
}
