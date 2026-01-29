import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../l10n_helper.dart';
import '../main.dart';
import '../service/ai_chat_service.dart';

class ReviewBooksScreen extends StatefulWidget {
  const ReviewBooksScreen({super.key});

  @override
  State<ReviewBooksScreen> createState() => _ReviewBooksScreenState();
}

class _ReviewBooksScreenState extends State<ReviewBooksScreen> {
  late Future<List<Book>> _booksFuture;
  final AiChatService _aiService = AiChatService();
  final Map<int, String> _translatedTitles = {};

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
  }

  Future<List<Book>> _fetchBooks() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/books'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      final books = body.map((dynamic item) => Book.fromJson(item)).toList();
      _translateTitles(books);
      return books;
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> _translateTitles(List<Book> books) async {
    final s = S.of(context);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    for (var book in books) {
      _aiService.translateTitle(book.title, s.locale.languageCode, token).then((translated) {
        if (mounted && translated != book.title) {
          setState(() {
            _translatedTitles[book.id] = translated;
          });
        }
      });
    }
  }

  Future<void> _showReviewDialog(Book book, ThemeData theme, S s) async {
    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    int rating = 3;
    bool isSubmitting = false;
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    Color dialogTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);
    final displayTitle = _translatedTitles[book.id] ?? book.title;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isHighContrast ? Colors.black : (isDarkMode || isDefaultMode ? const Color(0xFF1A1A1A) : theme.dialogBackgroundColor),
              title: Text(s.get('review_dialog_title', args: {'title': displayTitle}), style: TextStyle(color: dialogTextColor)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.get('your_rating'), style: TextStyle(color: dialogTextColor)),
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
                      style: TextStyle(color: dialogTextColor),
                      decoration: InputDecoration(
                        labelText: s.get('comment'),
                        labelStyle: TextStyle(color: dialogTextColor.withOpacity(0.7)),
                        enabledBorder: isHighContrast || isDarkMode || isDefaultMode 
                          ? UnderlineInputBorder(borderSide: BorderSide(color: dialogTextColor.withOpacity(0.5))) 
                          : null,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return s.get('enter_comment_error');
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
                  child: Text(s.get('cancel'), style: TextStyle(color: dialogTextColor)),
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
                                book.id, rating, commentController.text, s);
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
                      : Text(s.get('submit'), style: TextStyle(color: dialogTextColor)),
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

  Future<bool> _submitReview(int bookId, int rating, String comment, S s) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(s.get('login_required_review'))),
        );
      }
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('http://localhost:8080/api/reviews'),
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
          SnackBar(content: Text(s.get('review_submitted'))),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  s.get('review_failed', args: {'error': response.body}))),
        );
        return false;
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.get('timeout_error'))),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.get('error_occurred', args: {'error': e.toString()}))),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('review_title'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
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
                child: Text(s.get('error_loading_books', args: {'error': snapshot.error.toString()}),
                    style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text(s.get('no_books_to_review'), style: TextStyle(color: theme.textTheme.bodyLarge?.color)));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildBookCard(context, snapshot.data![index], theme, s);
              },
            );
          } else {
            return Center(child: Text(s.get('no_books_to_review'), style: TextStyle(color: theme.textTheme.bodyLarge?.color)));
          }
        },
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final themeSettings = ThemeSettings.of(context);

    Color textColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);
    final displayTitle = _translatedTitles[book.id] ?? book.title;

    final String bookDescription = s.get('book_semantics', args: {
        'title': displayTitle,
        'author': book.author,
        'condition': s.translateCondition(book.condition),
        'price': book.price.toStringAsFixed(2),
    });

    return Semantics(
      container: true,
      label: bookDescription,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
        color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : theme.cardColor)),
        child: InkWell(
          onTap: () => themeSettings?.speak(bookDescription),
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
                      Text(displayTitle,
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
                  label: s.get('add_review'),
                  child: ElevatedButton(
                    onPressed: () => _showReviewDialog(book, theme, s),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHighContrast ? Colors.black : Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                    ),
                    child: Text(s.get('review_button'), style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
