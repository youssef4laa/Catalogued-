import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = ''; // TODO: Add your TMDB API key

  Future<Map<String, dynamic>> searchMovie(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search for title');
    }
  }

  Future<Map<String, dynamic>> getDetails(String id, String type) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$type/$id?api_key=$_apiKey&append_to_response=credits,videos'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get details');
    }
  }
}