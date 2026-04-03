import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucrum_stock_taking/src/core/utils/app_images.dart';
import '../../../core/utils/app_colors.dart';
import '../../../components/app_button.dart';
import '../../../components/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  static final _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool _validateAndSubmit(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;

      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_emailPattern.hasMatch(email)) {
        _emailError = 'Enter a valid email address';
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }
    });

    if (_emailError != null || _passwordError != null) {
      return false;
    }

    context.read<AuthBloc>().add(
          LoginRequested(email: email, password: password),
        );
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  //const SizedBox(height: 16),
                  // AppButton(
                  //   text: 'Sign in with Biometrics',
                  //   onPressed: () {},
                  //   isOutlined: true,
                  //   icon: const Icon(
                  //     Icons.fingerprint,
                  //     size: 20,
                  //     color: AppColors.primary,
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                  const Text(
                    'v1.0.0 · LucrumX Stock Management',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Image.asset(AppImages.logo),
        ),
        const SizedBox(height: 20),
        const Text(
          'LucrumX',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textHigh,
          ),
        ),
        // const SizedBox(height: 4),
        // const Text(
        //   'Stock Taking',
        //   style: TextStyle(
        //     fontSize: 14,
        //     color: AppColors.textMedium,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppTextField(
          label: 'Email',
          hint: 'agent@lucrum.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Password',
          hint: '••••••••',
          controller: _passwordController,
          obscureText: _obscurePassword,
          isRequired: true,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: AppColors.textMedium,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AppButton(
          text: 'Sign In',
          isLoading: state is AuthLoading,
          onPressed: () => _validateAndSubmit(context),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(fontSize: 12, color: AppColors.textLow),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
