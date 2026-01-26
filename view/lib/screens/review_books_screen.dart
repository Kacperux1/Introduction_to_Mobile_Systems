import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class ReviewBooksScreen extends StatefulWidget {
  const ReviewBooksScreen({super.key});

  @override
  State<ReviewBooksScreen> createState() => _ReviewBooksScreenState();
}

class _ReviewBooksScreenState extends State<ReviewBooksScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
  }

  Future<List<Book>> _fetchBooks() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/books'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> _showReviewDialog(Book book, ThemeData theme) async {
    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    int rating = 3;
    bool isSubmitting = false;
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isHighContrast ? Colors.black : theme.dialogBackgroundColor,
              title: Text('Review "${book.title}"', style: TextStyle(color: isHighContrast ? Colors.yellow : null)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Your Rating:', style: TextStyle(color: isHighContrast ? Colors.yellow : null)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    TextFormField(
                      controller: commentController,
                      style: TextStyle(color: isHighContrast ? Colors.yellow : null),
                      decoration: InputDecoration(
                        labelText: 'Comment',
                        labelStyle: TextStyle(color: isHighContrast ? Colors.yellow : null),
                        enabledBorder: isHighContrast ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)) : null,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a comment';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancel', style: TextStyle(color: isHighContrast ? Colors.yellow : null)),
                ),
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isSubmitting = true;
                            });
                            final success = await _submitReview(
                                book.id, rating, commentController.text);
                            if (mounted) {
                              Navigator.of(dialogContext).pop(success);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Submit', style: TextStyle(color: isHighContrast ? Colors.yellow : null)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _booksFuture = _fetchBooks();
      });
    }
  }

  Future<bool> _submitReview(int bookId, int rating, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to submit a review.')),
        );
      }
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:8080/api/reviews'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'bookId': bookId,
              'rating': rating,
              'comment': comment,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return false;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to submit review. Server responded with: ${response.body}')),
        );
        return false;
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The request timed out. Please try again.')),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Write a Review', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildBookCard(context, snapshot.data![index], theme);
              },
            );
          } else {
            return const Center(child: Text('No books found to review.'));
          }
        },
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, ThemeData theme) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    Color textColor = isHighContrast ? Colors.yellow : Colors.black;
    if (isDarkMode || isDefaultMode) {
      // W kartach w trybach ciemnych nadal chcemy czarny tekst na szarym tle,
      // chyba że to High Contrast
    }

    return Semantics(
      container: true,
      label: 'Book for review: ${book.title} by ${book.author}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
        color: isHighContrast ? Colors.black : (isDefaultMode ? const Color(0xFFE0E0E0) : theme.cardColor),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: book.imageUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.book, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    const SizedBox(height: 4.0),
                    Text(book.author, style: TextStyle(fontSize: 14, color: textColor)),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Semantics(
                button: true,
                label: 'Add review for ${book.title}',
                child: ElevatedButton(
                  onPressed: () => _showReviewDialog(book, theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighContrast ? Colors.black : Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                  ),
                  child: Text('Review', style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
