import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  final String apiKey = 'AIzaSyAouXiGeEUB51dc2onkxfHSxzCD3OMl07Y'; // youtube API key

  // Fetch videos based on a search query
  Future<List<dynamic>> fetchVideos(String query) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items']; // Return list of video items
    } else {
      throw Exception('Failed to fetch videos');
    }
  }
}

