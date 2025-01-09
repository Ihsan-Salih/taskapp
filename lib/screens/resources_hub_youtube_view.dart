import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/youtube_service.dart';

class ResourcesHubYouTubeView extends StatefulWidget {
  @override
  _ResourcesHubYouTubeViewState createState() => _ResourcesHubYouTubeViewState();
}

class _ResourcesHubYouTubeViewState extends State<ResourcesHubYouTubeView> {
  final List<String> subjects = ['Math', 'Science', 'History', 'Technology'];
  final List<String> grades = ['Grade 1-3', 'Grade 4-6', 'Grade 7-9', 'Grade 10-12'];

  String selectedSubject = 'Math'; // Default subject
  String selectedGrade = 'Grade 1-3'; // Default grade
  List<dynamic> youtubeVideos = [];
  bool isLoading = false;

  // Fetch YouTube videos based on selected filters
  void fetchYouTubeVideos(String subject, String grade) async {
    setState(() {
      isLoading = true;
      youtubeVideos = [];
    });

    final youTubeService = YouTubeService();
    final query = '$subject for $grade students';
    try {
      final videos = await youTubeService.fetchVideos(query);
      setState(() {
        youtubeVideos = videos;
      });
    } catch (error) {
      print('Error fetching videos: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Refresh videos
  void refreshVideos() {
    fetchYouTubeVideos(selectedSubject, selectedGrade);
  }

  @override
  void initState() {
    super.initState();
    // Fetch initial videos
    fetchYouTubeVideos(selectedSubject, selectedGrade);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Upto here works');

    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Resources'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshVideos,
            tooltip: 'Refresh Videos',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Dropdown
            Text(
              'Select a Subject:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedSubject,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedSubject = value!;
                  fetchYouTubeVideos(selectedSubject, selectedGrade);
                });
              },
              items: subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Grade Dropdown
            Text(
              'Select a Grade:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedGrade,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedGrade = value!;
                  fetchYouTubeVideos(selectedSubject, selectedGrade);
                });
              },
              items: grades.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Video List
            Text(
              'YouTube Videos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : youtubeVideos.isEmpty
                  ? Center(
                child: Text(
                  'No videos available. Try selecting a different subject or grade.',
                ),
              )
                  : ListView.builder(
                itemCount: youtubeVideos.length,
                itemBuilder: (context, index) {
                  final video = youtubeVideos[index];
                  final snippet = video['snippet'];
                  final videoId = video['id']['videoId'];
                  return ListTile(
                    leading: Image.network(
                      snippet['thumbnails']['default']['url'],
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(snippet['title']),
                    subtitle: Text(snippet['channelTitle']),
                    onTap: () {
                      // Navigate to WebView screen with the video URL
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              YouTubeVideoView(videoId: videoId),
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
    );
  }
}

// WebView Screen to Play YouTube Videos
class YouTubeVideoView extends StatefulWidget {
  final String videoId;

  const YouTubeVideoView({Key? key, required this.videoId}) : super(key: key);

  @override
  _YouTubeVideoViewState createState() => _YouTubeVideoViewState();
}

class _YouTubeVideoViewState extends State<YouTubeVideoView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final videoUrl = 'https://www.youtube.com/embed/${widget.videoId}';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadRequest(Uri.parse(videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Video'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}