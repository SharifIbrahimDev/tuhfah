import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith_model.dart';
import '../../data/providers/hadith_provider.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _timeElapsed = false;

  @override
  void initState() {
    super.initState();

    // Initialize premium animations
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

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Minimum display timer of 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _timeElapsed = true;
        });
        _checkAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAndNavigate() {
    final hadithAsync = ref.read(hadithListProvider);
    if (_timeElapsed && !hadithAsync.isLoading && !hadithAsync.hasError) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0F1E15) : const Color(0xFFFAF7F0);
    final titleColor = isDarkMode ? const Color(0xFFECE6D9) : const Color(0xFF006B3F);
    final goldColor = const Color(0xFFC5A880);

    // Listen to the provider to trigger navigation if loading finishes after the timer
    ref.listen<AsyncValue<List<HadithModel>>>(hadithListProvider, (previous, next) {
      if (_timeElapsed && !next.isLoading && !next.hasError) {
        _checkAndNavigate();
      }
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        
                        // App Logo
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode ? goldColor : titleColor)
                                    .withValues(alpha: 0.25),
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: Image.asset(
                              'assets/data/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // App Title
                        Text(
                          'تُحْفَةُ الوِلْدَانِ',
                          style: GoogleFonts.tajawal(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // App Subtitle
                        Text(
                          'مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: goldColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const Spacer(flex: 2),
                        
                        // Loading state / Progress Indicator
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode ? goldColor : titleColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Footer / Copyright
                        Text(
                          'مركز عبدالله بن مسعود لتحفيظ القرآن الكريم',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
