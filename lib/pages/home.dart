import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_share/pages/receive_page.dart';
import 'package:secure_share/pages/share_page.dart';
import 'package:secure_share/widgets/theme_toggle_button.dart';
import 'package:secure_share/widgets/gradient_button.dart';

class Home extends StatefulWidget {
  Home({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.light
          ? Color(0xFFEDF2FF)
          : Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 10),
              child: ThemeToggleButton(toggleTheme: widget.toggleTheme),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/safety_shield.svg',
                        width: 250,
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF2178dd)
                            : Color(0xFF4C56E1),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'QR Secure Share',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 24,
                      ),
                      child: Column(
                        children: [
                          GradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SharePage(toggleTheme: widget.toggleTheme),
                                ),
                              );
                            },
                            svgPath: 'assets/icons/share_bold.svg',
                            svgWidth: 35,
                            svgColor: Colors.white,
                            text: 'Envoyer',
                            lightColors: const [
                              Color(0xFF07c8f9),
                              Color(0xFF0d41e1),
                            ],
                            darkColors: const [
                              Color(0xFF4C56E1), Color(0xFF0B1567)
                            ],
                          ),
                          const SizedBox(height: 12),
                          GradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReceivePage(toggleTheme: widget.toggleTheme),
                                ),
                              );
                            },
                            svgPath: 'assets/icons/receive.svg',
                            svgWidth: 30,
                            svgColor: Colors.white,
                            text: 'Recevoir',
                            lightColors: const [
                              Color(0xFF07c8f9),
                              Color(0xFF0d41e1),
                            ],
                            darkColors: const [
                              Color(0xFF4C56E1), Color(0xFF0B1567)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}