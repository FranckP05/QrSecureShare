import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/gradient_container.dart';
import '../utils/navigation.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SplashPage({super.key, required this.toggleTheme});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _lottieController;
  String _fullText = 'SecureShare';
  String _displayedText = '';
  int _textIndex = 0;
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startTyping();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _slideAnimations = List.generate(3, (i) {
      return Tween<Offset>(
        begin: Offset(i.isEven ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(0.2 * i, 0.2 * i + 0.6, curve: Curves.easeOut),
        ),
      );
    });
  }

  void _startTyping() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        timer.cancel();
        _lottieController.stop();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        colors: const [Color(0xff00458e), Color(0xff000328)],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/secure.json',
                    width: 100,
                    height: 100,
                    controller: _lottieController,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _displayedText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimations[0],
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Text(
                    'Securely share data using encryption and Bluetooth',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      fontFamily: 'Sora',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: _slideAnimations[1],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    'Share Wi-Fi codes, links, photos and documents safely via Bluetooth with RSA and AES encryption, and web link scanning',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SlideTransition(
                position: _slideAnimations[2],
                child: GestureDetector(
                  onTap:
                      () => navigateTo(
                        context,
                        Login(toggleTheme: widget.toggleTheme),
                      ),
                  child: GradientContainer(
                    colors: const [Color(0xff0968e5), Color(0xff091970)],
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 10,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: "WorkSans",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
