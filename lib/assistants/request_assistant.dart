import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return 'Error Occurred, Failed. Status Code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error Occurred, Failed. Exception: ${e.toString()}';
    }
  }
}