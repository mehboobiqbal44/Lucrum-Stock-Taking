import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/utils/app_colors.dart';
import 'src/core/routes/app_router.dart';
import 'src/features/auth/bloc/auth_bloc.dart';

class LucrumStockTaking extends StatelessWidget {
  const LucrumStockTaking({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'Lucrum Stock Taking',
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
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
