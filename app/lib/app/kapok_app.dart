import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/providers/language_provider.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/teams/bloc/team_bloc.dart';
import '../features/tasks/bloc/task_bloc.dart';
import '../injection_container.dart';
import '../core/widgets/kapok_loading.dart';
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
        BlocProvider<TeamBloc>(
          create: (context) => sl<TeamBloc>(),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => sl<TaskBloc>(),
        ),
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
              home: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } 
                  else if (state is AuthAuthenticated) {
                      Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Scaffold(
                        backgroundColor: AppColors.background,
                        body: KapokLoading(),
                      );
                    } else if (state is AuthAuthenticated) {
                       return const HomePage();
                    } else {
                      // Show a temporary screen while redirect happens
                      return const Scaffold(
                      body: Center(child: Text('Redirecting to login...')),
                    );
                  }
                },
              ),
              ),
            );
          },
        ),
      ),
    );
  }
}
