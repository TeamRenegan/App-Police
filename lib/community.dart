import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapapp/create_post.dart';

class Post {
  final String title;
  final String description;
  final String imageUrl;
  final String authorName;
  final String postDate;

  Post({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorName,
    required this.postDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] ?? 'Default Title',
      description: json['description'] ?? 'Default Description',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      authorName: json['name'] ?? 'Hritika',
      postDate: json['date'] ?? '05-04-2024',
    );
  }
}

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://renegan-inc-backend.onrender.com/posts'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          posts = List<Post>.from(jsonData.map((x) => Post.fromJson(x)));
        });
      } else {
        // Use default/dummy data if request fails
        setState(() {
          posts = [
            Post(
              title: 'Default Title',
              description: 'Default Description',
              imageUrl: 'https://via.placeholder.com/150',
              authorName: 'Default Author',
              postDate: 'Unknown Date',
            ),
          ];
        });
      }
    } catch (e) {
      // Use default/dummy data if an exception occurs
      setState(() {
        posts = [
          Post(
            title: 'Shadow Heist',
            description:
                ' A team of thieves targets a fortified bank vault, facing internal conflicts and external threats in their pursuit of riches.',
            imageUrl: 'https://via.placeholder.com/150',
            authorName: 'Vikram Singhania',
            postDate: '2022-01-01',
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Feed'),
          backgroundColor: Colors.blue,
        ),
        body: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      posts[index].title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      posts[index].description,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Image.network(
                      posts[index].imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Author: ${posts[index].authorName}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${posts[index].postDate}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePostPage()),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.create),
        ),
      ),
    );
  }
}
