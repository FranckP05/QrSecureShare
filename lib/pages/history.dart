import 'package:flutter/material.dart';
import 'package:secure_share/widgets/theme_toggle_button.dart';

class HistoryWidget extends StatefulWidget {
  HistoryWidget({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
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
                      child: const Text("This is the history page"),
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