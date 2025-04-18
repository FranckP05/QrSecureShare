import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../database/database_helper.dart';
import '../widgets/theme_toggle_button.dart';

class HistoryWidget extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;

  const HistoryWidget({
    super.key,
    required this.username,
    required this.toggleTheme,
  });

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleTextColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFEDF2FF)
          : Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align the whole column to the start
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push items to ends
                children: [
                  Text(
                    'Historique',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: titleTextColor, 
                    ),
                  ),
                  ThemeToggleButton(toggleTheme: widget.toggleTheme),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.getDataHistory(widget.username),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading history'));
                    }
                    final history = snapshot.data ?? [];
                    if (history.isEmpty) {
                      return const Center(child: Text('No data received yet'));
                    }
                    return ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['type_name'] ?? 'Unknown Type',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text('Received: ${item['date']}', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text(
                                  item['content'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}