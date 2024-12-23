import 'dart:convert';
import 'package:http/http.dart' as http;

class RakutenAPI {
  static const String apiKey = String.fromEnvironment('RAKUTEN_API_KEY');
  static const String endpoint =
      'https://app.rakuten.co.jp/services/api/BooksDVD/Search/20170404';

  static Future<List<dynamic>> searchItems(String query) async {
    final url = Uri.parse(
        '$endpoint?format=json&formatVersion=2&title=$query&applicationId=$apiKey&sort=-releaseDate');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to load data from Rakuten API');
    }
  }
}
