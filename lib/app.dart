import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/utils/app_colors.dart';
import 'src/core/routes/app_router.dart';
import 'src/core/network/dio_client.dart';
import 'src/features/auth/data/auth_service.dart';
import 'src/features/auth/data/auth_repository.dart';
import 'src/features/auth/bloc/auth_bloc.dart';
import 'src/features/auth/bloc/auth_event.dart';
import 'src/features/auth/bloc/auth_state.dart';

class LucrumStockTaking extends StatefulWidget {
  const LucrumStockTaking({super.key});

  @override
  State<LucrumStockTaking> createState() => _LucrumStockTakingState();
}

class _LucrumStockTakingState extends State<LucrumStockTaking> {
  late final DioClient _dioClient;
  late final AuthService _authService;
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient();
    _authService = AuthService(_dioClient);
    _authRepository = AuthRepository(_authService);
    _authBloc = AuthBloc(
      repository: _authRepository,
      dioClient: _dioClient,
    )..add(CheckSavedSession());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DioClient>.value(value: _dioClient),
      ],
      child: BlocProvider<AuthBloc>.value(
        value: _authBloc,
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (prev, curr) =>
              curr is AuthCheckingSession ||
              curr is AuthAuthenticated ||
              curr is AuthInitial,
          builder: (context, state) {
            if (state is AuthCheckingSession) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  backgroundColor: AppColors.background,
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading…',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final initialRoute = state is AuthAuthenticated
                ? AppRouter.main
                : AppRouter.login;

            return MaterialApp(
              key: ValueKey(initialRoute),
              title: 'Lucrum Stock Management',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: AppColors.background,
                primaryColor: AppColors.primary,
                fontFamily: 'Poppins',
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  secondary: AppColors.primaryLight,
                  surface: AppColors.surface,
                  error: AppColors.errorText,
                  onPrimary: Colors.white,
                  onSecondary: AppColors.primary,
                  onSurface: AppColors.textHigh,
                  onError: Colors.white,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: AppColors.surface,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.textHigh),
                  titleTextStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textHigh,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                dividerColor: AppColors.border,
              ),
              initialRoute: initialRoute,
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
