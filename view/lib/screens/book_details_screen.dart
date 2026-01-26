import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class BookDetailsScreen extends StatefulWidget {
  final int bookId;
  final bool isLoggedIn;

  const BookDetailsScreen({super.key, required this.bookId, required this.isLoggedIn});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Future<Book> _bookFuture;

  @override
  void initState() {
    super.initState();
    _bookFuture = _fetchBookDetails();
  }

  Future<Book> _fetchBookDetails() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/books/${widget.bookId}'),
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load book details');
    }
  }

  void _refreshBookDetails() {
    setState(() {
      _bookFuture = _fetchBookDetails();
    });
  }

  Future<bool> _submitReview(int bookId, int rating, String comment) async {
    if (!widget.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to submit a review.')),
        );
      }
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

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
                  'Failed to submit review. Status: ${response.statusCode}, Body: ${response.body}')),
        );
        return false;
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('The request timed out. Please try again.')),
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

  Future<void> _showReviewDialog(Book book, ThemeData theme) async {
    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    int rating = 3;
    bool isSubmitting = false;
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);

    final reviewSubmitted = await showDialog<bool>(
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
                          onPressed: isSubmitting
                              ? null
                              : () {
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Submit', style: TextStyle(color: isHighContrast ? Colors.yellow : null)),
                ),
              ],
            );
          },
        );
      },
    );

    if (reviewSubmitted == true) {
      _refreshBookDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Book Details', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: FutureBuilder<Book>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            final book = snapshot.data!;
            return _buildBookDetails(context, book, theme);
          } else {
            return const Center(child: Text('Book not found.'));
          }
        },
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, Book book, ThemeData theme) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    Color textColor;
    if (isHighContrast) {
      textColor = Colors.yellow;
    } else if (isDarkMode || isDefaultMode) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }

    Color cardTextColor = isHighContrast ? Colors.yellow : Colors.black;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Image
            Semantics(
              label: 'Book cover image',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: CachedNetworkImage(
                  imageUrl: book.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            //Szczegóły
            Semantics(
              container: true,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                color: isHighContrast ? Colors.black : (isDefaultMode ? const Color(0xFFE0E0E0) : theme.cardColor),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Title: ${book.title}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22, color: cardTextColor)),
                      const SizedBox(height: 8.0),
                      Text('Author: ${book.author}',
                          style: TextStyle(fontSize: 18, color: cardTextColor)),
                      const SizedBox(height: 12.0),
                      Text('Condition: ${book.condition}',
                          style: TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic, color: cardTextColor)),
                      const SizedBox(height: 12.0),
                      Text('Price: ${book.price.toStringAsFixed(2)}zł',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: isHighContrast ? Colors.yellow : (isDarkMode ? Colors.greenAccent : Colors.green[800]))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Sprzedawca
            if (book.sellerLogin != null) _buildSellerSection(context, book, theme),

            // Recenzje
            _buildReviewsSection(book, theme),

            const SizedBox(height: 16.0),

            if (widget.isLoggedIn)
              Semantics(
                button: true,
                child: ElevatedButton(
                  onPressed: () => _showReviewDialog(book, theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighContrast ? Colors.black : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                  ),
                  child: Text('Add Your Review',
                      style: TextStyle(fontSize: 18, color: isHighContrast ? Colors.yellow : Colors.white)),
                ),
              ),

            const SizedBox(height: 24.0),

            // Buy Now
            Semantics(
              button: true,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Purchase functionality not implemented yet.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHighContrast ? Colors.black : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                ),
                child: Text('Buy Now',
                    style: TextStyle(fontSize: 20, color: isHighContrast ? Colors.yellow : Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerSection(BuildContext context, Book book, ThemeData theme) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

    Color sectionHeaderColor = (isHighContrast) ? Colors.yellow : Colors.white;
    if (!isHighContrast && !isDefaultMode && !isDarkMode) sectionHeaderColor = Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sold by',
          style: TextStyle(
              color: sectionHeaderColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Card(
          shape:
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
          color: isHighContrast ? Colors.black : (isDefaultMode ? const Color(0xFFE0E0E0) : theme.cardColor),
          child: ListTile(
            leading: Icon(Icons.person, size: 40, color: isHighContrast ? Colors.yellow : null),
            title: Text(book.sellerLogin!,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isHighContrast ? Colors.yellow : Colors.black)),
            subtitle: Text(book.sellerEmail ?? 'Email not available', 
              style: TextStyle(color: isHighContrast ? Colors.yellow.withOpacity(0.7) : Colors.black54)),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Chat functionality will be implemented in the future.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isHighContrast ? Colors.black : Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
              ),
              child:
                  Text('Contact', style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildReviewsSection(Book book, ThemeData theme) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

    Color sectionHeaderColor = (isHighContrast) ? Colors.yellow : Colors.white;
    if (!isHighContrast && !isDefaultMode && !isDarkMode) sectionHeaderColor = Colors.black;

    if (book.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text('No reviews yet.',
              style: TextStyle(color: sectionHeaderColor, fontSize: 16)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
              color: sectionHeaderColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: book.reviews.length,
          itemBuilder: (context, index) {
            final review = book.reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
              color: isHighContrast ? Colors.black : (isDefaultMode ? const Color(0xFFE0E0E0) : theme.cardColor),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.reviewerName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: isHighContrast ? Colors.yellow : Colors.black)),
                        _buildRatingStars(review.rating),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(review.comment, style: TextStyle(fontSize: 14, color: isHighContrast ? Colors.yellow : Colors.black)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}
