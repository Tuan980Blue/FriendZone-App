import 'dart:async';

import 'package:flutter/material.dart';
import 'package:friendzoneapp/core/errors/exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:friendzoneapp/presentation/screens/register_screen.dart';
import 'package:friendzoneapp/presentation/screens/forgot_password_screen.dart';
import 'package:friendzoneapp/presentation/screens/google_password_setup_screen.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../theme/app_theme.dart';
import '../theme/app_page_transitions.dart';
import 'home_page.dart';
import '../../di/injection_container.dart';

class LoginScreen extends StatefulWidget {
  final LoginUseCase loginUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  const LoginScreen({
    super.key,
    required this.loginUseCase,
    required this.googleSignInUseCase,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final RegisterUseCase _registerUseCase = sl<RegisterUseCase>();
  String? _emailValidationError;
  String? _passwordValidationError;
  Timer? _emailErrorTimer;
  Timer? _passwordErrorTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailValidationError = null;
      _passwordValidationError = null;
      _emailErrorTimer?.cancel();
      _passwordErrorTimer?.cancel();
    });

    bool isValid = true;

    void startEmailErrorTimer() {
      _emailErrorTimer?.cancel();
      _emailErrorTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _emailValidationError = null;
          });
        }
      });
    }

    void startPasswordErrorTimer() {
      _passwordErrorTimer?.cancel();
      _passwordErrorTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _passwordValidationError = null;
          });
        }
      });
    }

    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      }
      if (!value.contains('@')) {
        return 'Please enter a valid email';
      }
      return null;
    }

    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    }

    String? emailValidationResult = validateEmail(_emailController.text.trim());
    if (emailValidationResult != null) {
      setState(() {
        _emailValidationError = emailValidationResult;
        startEmailErrorTimer();
      });
      isValid = false;
    }

    String? passwordValidationResult = validatePassword(_passwordController.text);
    if (passwordValidationResult != null) {
      setState(() {
        _passwordValidationError = passwordValidationResult;
        startPasswordErrorTimer();
      });
      isValid = false;
    }

    if (!isValid) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await widget.loginUseCase(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        AppPageTransitions.fade(const HomePage()),
      );

    }
    on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
    on ServerException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
    catch (e) {
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
      });
    }
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      
      // Sign out trước để force hiển thị dialog chọn tài khoản
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() { _isLoading = false; });
        return;
      }

      final authHeaders = await googleUser.authHeaders;
      final authToken = authHeaders['Authorization'];
      if (authToken == null) {
        throw Exception('Failed to get Google auth token');
      }
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
        headers: {'Authorization': authToken},
      );
      print('Google userinfo response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to get user info from Google');
      }
      final userInfo = jsonDecode(response.body);
      
      // Gọi backend và lưu token
      final result = await widget.googleSignInUseCase(userInfo);
      print('Backend result: $result');

      // Kiểm tra và lưu token từ backend chỉ khi không requirePassword
      if (result['requirePassword'] != true && result['token'] == null) {
        throw Exception('Backend did not return authentication token');
      }

      if (!mounted) return;

      // Handle the response
      if (result['requirePassword'] == true) {
        // New user needs to create password
        Navigator.of(context).push(
          AppPageTransitions.slideUp(
            GooglePasswordSetupScreen(
              userInfo: result['userInfo'],
              googleSignInUseCase: widget.googleSignInUseCase,
            ),
          ),
        );
      } else {
        // Existing user, navigate to home
        Navigator.of(context).pushReplacement(
          AppPageTransitions.fade(const HomePage()),
        );
      }
    } catch (e, stack) {
      print('Google Sign-In error: $e');
      print('Stack trace: $stack');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      AppPageTransitions.slideRight(
        RegisterScreen(
          registerUseCase: _registerUseCase,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.backgroundDark
                  : AppTheme.backgroundLight,
              Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.backgroundDark.withOpacity(0.8)
                  : AppTheme.backgroundLight.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo with shadow
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          Theme.of(context).brightness == Brightness.dark 
                            ? 'assets/images/logo02.png'
                            : 'assets/images/logo01.png',
                          height: 120,
                          width: 120,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Welcome Text
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkModeText
                              : AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email field with custom styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            errorText: _emailValidationError,
                          ),
                          validator: (value) {
                            return null;
                          },
                          onChanged: (value) {
                            if (_emailValidationError != null) {
                              setState(() {
                                _emailValidationError = null;
                                _emailErrorTimer?.cancel();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password field with custom styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.primaryBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            errorText: _passwordValidationError,
                          ),
                          validator: (value) {
                            return null;
                          },
                          onChanged: (value) {
                            if (_passwordValidationError != null) {
                              setState(() {
                                _passwordValidationError = null;
                                _passwordErrorTimer?.cancel();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              AppPageTransitions.slideUp(
                                const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Error message
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Login button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentPink.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF833AB4),
                              Color(0xFFE1306C),
                              Color(0xFFF77737),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider with "OR"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 24,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 