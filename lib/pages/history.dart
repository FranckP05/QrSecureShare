import 'package:flutter/material.dart';
import 'package:secure_share/database/database_helper.dart';
import 'package:secure_share/widgets/theme_toggle_button.dart';

class HistoryWidget extends StatefulWidget {
  HistoryWidget({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late Future<List<Map<String, dynamic>>> _historyData;

  @override
  void initState() {
    super.initState();
    _historyData = _fetchHistory(); // Fetch history on widget initialization
  }

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUserCount(); // Get user count
    if (user > 0) {
      // Assuming only one user exists
      final userId = 1; // Replace with actual user ID
      return await dbHelper.getHistory(userId);
    }
    return [];
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _historyData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final history = snapshot.data ?? [];

                  if (history.isEmpty) {
                    return Center(child: Text('No history available.'));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final record = history[index];
                        final receivedData = record['received_data'];
                        final receivedDate = record['received_date'];

                        return ListTile(
                          title: Text(receivedData),
                          subtitle: Text('Received on: $receivedDate'),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
