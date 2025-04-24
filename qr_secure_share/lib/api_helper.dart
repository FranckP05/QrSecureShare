import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String _apiKey = 'AIzaSyBB4bsxolv1KhdJIOW4_YFlcbd_Y4Jh_-8';
  static const String _safeBrowsingUrl =
      'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$_apiKey';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Vérifie si un lien est sûr avec l'API Google Safe Browsing
  static Future<bool> isLinkSafe(String url) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final body = {
          'client': {
            'clientId': 'qr-secure-share',
            'clientVersion': '1.0.0',
          },
          'threatInfo': {
            'threatTypes': [
              'MALWARE',
              'SOCIAL_ENGINEERING',
              'UNWANTED_SOFTWARE',
              'POTENTIALLY_HARMFUL_APPLICATION'
            ],
            'platformTypes': ['ANY_PLATFORM'],
            'threatEntryTypes': ['URL'],
            'threatEntries': [
              {'url': url},
            ],
          },
        };

        final response = await http.post(
          Uri.parse(_safeBrowsingUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Si "matches" est vide, le lien est sûr
          return data['matches'] == null || data['matches'].isEmpty;
        } else {
          if (attempt == _maxRetries) {
            // Après le dernier essai, on suppose que le lien est risqué
            return false;
          }
          // Attend avant de réessayer
          await Future.delayed(_retryDelay);
        }
      } catch (e) {
        if (attempt == _maxRetries) {
          // Après le dernier essai, on suppose que le lien est risqué
          return false;
        }
        // Attend avant de réessayer
        await Future.delayed(_retryDelay);
      }
    }
    return false;
  }
}
