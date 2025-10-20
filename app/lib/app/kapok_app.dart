import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/teams/bloc/team_bloc.dart';
import '../features/tasks/bloc/task_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/team_repository.dart';
import '../data/repositories/task_repository.dart';
import '../data/sources/firebase_source.dart';
import '../data/sources/hive_source.dart';
import '../core/services/network_checker.dart';
import 'router.dart';
import 'home_page.dart';

class KapokApp extends StatelessWidget {
  const KapokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO: Replace with actual dependency injection
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(
              firebaseSource: FirebaseSource(),
              hiveSource: HiveSource(),
              networkChecker: NetworkChecker(),
            ),
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider<TeamBloc>(
          create: (context) => TeamBloc(
            teamRepository: TeamRepository(
              firebaseSource: FirebaseSource(),
              hiveSource: HiveSource(),
              networkChecker: NetworkChecker(),
            ),
          ),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(
            taskRepository: TaskRepository(
              firebaseSource: FirebaseSource(),
              hiveSource: HiveSource(),
              networkChecker: NetworkChecker(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Kapok',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(
            AppColors.primary.value,
            <int, Color>{
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
            },
          ),
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
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        onGenerateRoute: AppRouter.generateRoute,
        home: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
          } else if (state is AuthUnauthenticated) {
            Logger.auth('Redirecting to LoginPage');
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          return const HomePage();
        } else {
          return const Scaffold(
            body: Center(child: Text('Redirecting to login...')),
      );
    }
  },
),
),
);
}
}