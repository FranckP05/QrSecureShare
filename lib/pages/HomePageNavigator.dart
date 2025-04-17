import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:secure_share/pages/history.dart';
import 'package:secure_share/pages/home.dart';

class HomeNavigator extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeNavigator({super.key, required this.toggleTheme});

  @override
  _HomeNavigatorState createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Home(toggleTheme: widget.toggleTheme),
          HistoryWidget(toggleTheme: widget.toggleTheme),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFEDF2FF) // Match Home/HistoryWidget
            : Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
            child: GNav(
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              gap: 8,
              backgroundColor: Colors.transparent,
              activeColor: Theme.of(context).brightness==Brightness.light? Color(0xFF0096c7): Color(0xFFf96900),
              tabBackgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              tabBorderRadius: 50, // Pill-shaped per pub.dev
              tabMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              rippleColor: Colors.white.withOpacity(0.2),
              hoverColor: Colors.white.withOpacity(0.1),
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora',
                color: Theme.of(context).brightness==Brightness.light? Color(0xFF0096c7): Color(0xFFf96900),
              ),
              iconSize: 24,
              duration: const Duration(milliseconds: 400),
              tabBackgroundGradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.light
                    ? [const Color(0xFFe3f2fd), const Color(0xFFbbdefb)]
                    : [Color(0xFFf8dda4), Color(0xFFfcd45d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  leading: AnimatedScale(
                    scale: _selectedIndex == 0 ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.home,
                      size: 24,
                      color: _selectedIndex == 0
                          ? Theme.of(context).brightness == Brightness.light
                              ? Color(0xFF0096c7)
                              : Color(0xFFf96900)
                          : Theme.of(context).brightness == Brightness.light
                              ? Color(0xFF0096c7)
                              : Color(0xFFf96900),
                    ),
                  ),
                ),
                GButton(
                  icon: Icons.history,
                  text: 'History',
                  leading: AnimatedScale(
                    scale: _selectedIndex == 1 ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.history,
                      size: 24,
                      color: _selectedIndex == 1
                          ? Theme.of(context).brightness == Brightness.light
                              ? Color(0xFF0096c7)
                              : Color(0xFFf96900)
                          : Theme.of(context).brightness == Brightness.light
                              ? Color(0xFF0096c7)
                              : Color(0xFFf96900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}