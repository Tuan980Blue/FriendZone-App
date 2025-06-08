import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_page_transitions.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'otp_reset_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _error = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;
  bool _isFocused = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitResetRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://web-socket-friendzone.onrender.com/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "message": "Password reset OTP has been sent to your email",
          "email": _emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        setState(() {
          _error = data['error'];
        });
      } else if (data['message'] != null) {
        // Chuyển sang màn hình nhập OTP và mật khẩu mới
        Navigator.of(context).push(
          AppPageTransitions.slideRight(
            OtpResetScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        setState(() {
          _error = 'Unexpected error. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF000000),
                        const Color(0xFF1A1A1A),
                      ]
                    : [
                        const Color(0xFFF8F9FA),
                        Colors.white,
                        const Color(0xFFF8F9FA),
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Animated background patterns
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
              ),
            ),
          ),

          // Instagram logo watermark with animation
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 0.03),
              duration: const Duration(milliseconds: 2000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.rotate(
                    angle: 0.05,
                    child: Image.asset(
                      'assets/images/logo02.png',
                      height: 120,
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: size.height * 0.08),
                          
                          // Glassmorphism container for header
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? Colors.black.withOpacity(0.4)
                                      : Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Animated icon container
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.8, end: 1.0),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF833AB4),
                                                  Color(0xFFE1306C),
                                                  Color(0xFFF77737),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFE1306C).withOpacity(0.4),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.lock_reset_rounded,
                                              color: Colors.white,
                                              size: 36,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                    
                                    // Title with gradient
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [
                                          Color(0xFF833AB4),
                                          Color(0xFFE1306C),
                                          Color(0xFFF77737),
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'Reset Password',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    Text(
                                      'Enter your email to receive a password reset code',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        height: 1.5,
                                        letterSpacing: 0.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Enhanced email input field
                          StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _isFocused
                                            ? const Color(0xFFEC5387)
                                            : isDark
                                                ? Colors.grey[800]!
                                                : Colors.grey[400]!,
                                        width: _isFocused ? 2 : 1.5,
                                      ),
                                      boxShadow: _isFocused
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFE1306C).withOpacity(0.2),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 16,
                                        letterSpacing: 0.3,
                                      ),
                                      onTap: () => setState(() => _isFocused = true),
                                      onEditingComplete: () => setState(() => _isFocused = false),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle: TextStyle(
                                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                                          fontSize: 15,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: _isFocused
                                              ? const Color(0xFFE1306C)
                                              : isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                          size: 22,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                        errorText: null, // Disable default error
                                      ),
                                      validator: (value) {
                                        String? error;
                                        if (value == null || value.isEmpty) {
                                          error = 'Please enter your email';
                                        } else if (!value.contains('@')) {
                                          error = 'Please enter a valid email';
                                        }
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (_emailError != error) {
                                            setState(() {
                                              _emailError = error;
                                            });
                                          }
                                        });
                                        return null; // Always return null to hide default error
                                      },
                                    ),
                                  ),
                                  if (_emailError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12, top: 4),
                                      child: Text(
                                        _emailError!,
                                        style: const TextStyle(
                                          color: Color(0xFFE1306C),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 28),

                          // Enhanced error message
                          if (_error.isNotEmpty)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1306C).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE1306C).withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Color(0xFFE1306C),
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _error,
                                            style: const TextStyle(
                                              color: Color(0xFFE1306C),
                                              fontSize: 14,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 28),

                          // Enhanced submit button
                          StatefulBuilder(
                            builder: (context, setState) {
                              return MouseRegion(
                                onEnter: (_) => setState(() => _isHovered = true),
                                onExit: (_) => setState(() => _isHovered = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF833AB4),
                                        Color(0xFFE1306C),
                                        Color(0xFFF77737),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE1306C).withOpacity(_isHovered ? 0.4 : 0.3),
                                        blurRadius: _isHovered ? 12 : 8,
                                        spreadRadius: _isHovered ? 2 : 1,
                                        offset: Offset(0, _isHovered ? 6 : 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _isLoading ? null : _submitResetRequest,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 26,
                                                width: 26,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                'Send Reset Code',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      offset: const Offset(0, 1),
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Enhanced back button
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Back to Login',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (var i = 0; i < size.width; i += spacing as int) {
      for (var j = 0; j < size.height; j += spacing as int) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 