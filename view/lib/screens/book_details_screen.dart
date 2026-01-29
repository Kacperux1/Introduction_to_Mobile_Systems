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

class BookDetailsScreen extends StatefulWidget {
  final int bookId;
  final bool isLoggedIn;
  final String? translatedTitle;
  final String? dynamicImageUrl;

  const BookDetailsScreen({
    super.key, 
    required this.bookId, 
    required this.isLoggedIn,
    this.translatedTitle,
    this.dynamicImageUrl,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Future<Book> _bookFuture;
  String? _currentTranslatedTitle;
  String? _currentImageUrl;
  final AiChatService _aiService = AiChatService();

  @override
  void initState() {
    super.initState();
    _currentTranslatedTitle = widget.translatedTitle;
    _currentImageUrl = widget.dynamicImageUrl;
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
      final book = Book.fromJson(jsonDecode(response.body));
      if (_currentTranslatedTitle == null) {
        _translateTitle(book.title);
      }
      return book;
    } else {
      throw Exception(S.of(context).get('failed_load_details'));
    }
  }

  Future<void> _translateTitle(String title) async {
    final s = S.of(context);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    final translated = await _aiService.translateTitle(title, s.locale.languageCode, token);
    if (mounted && translated != title) {
      setState(() {
        _currentTranslatedTitle = translated;
      });
    }
  }

  void _refreshBookDetails() {
    setState(() {
      _bookFuture = _fetchBookDetails();
    });
  }

  Future<bool> _submitReview(int bookId, int rating, String comment, S s) async {
    if (!widget.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(s.get('login_required_review'))),
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
          SnackBar(
              content: Text(s.get('timeout_error'))),
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

  Future<void> _showReviewDialog(Book book, ThemeData theme, S s) async {
    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    int rating = 3;
    bool isSubmitting = false;
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    Color dialogTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    final reviewSubmitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isHighContrast ? Colors.black : (isDarkMode || isDefaultMode ? const Color(0xFF1A1A1A) : theme.dialogBackgroundColor),
              title: Text(s.get('review_dialog_title', args: {'title': _currentTranslatedTitle ?? book.title}), style: TextStyle(color: dialogTextColor)),
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(s.get('submit'), style: TextStyle(color: dialogTextColor)),
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
    final s = S.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('book_details'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
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
                child: Text(s.get('error_occurred', args: {'error': snapshot.error.toString()}),
                    style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            final book = snapshot.data!;
            return _buildBookDetails(context, book, theme, s);
          } else {
            return Center(child: Text(s.get('book_not_found')));
          }
        },
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, Book book, ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final themeSettings = ThemeSettings.of(context);

    Color cardTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);
    final displayTitle = _currentTranslatedTitle ?? book.title;
    final displayImageUrl = _currentImageUrl ?? book.imageUrl;

    final String bookDescription = s.get('book_semantics', args: {
        'title': displayTitle,
        'author': book.author,
        'condition': s.translateCondition(book.condition),
        'price': book.price.toStringAsFixed(2),
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Image
            Semantics(
              label: s.get('book_cover_label'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: CachedNetworkImage(
                  imageUrl: displayImageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            //Szczegóły
            Semantics(
              container: true,
              label: bookDescription,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : theme.cardColor)),
                child: InkWell(
                  onTap: () => themeSettings?.speak(bookDescription),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.get('title')}: $displayTitle',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22, color: cardTextColor)),
                        const SizedBox(height: 8.0),
                        Text('${s.get('author')}: ${book.author}',
                            style: TextStyle(fontSize: 18, color: cardTextColor)),
                        const SizedBox(height: 12.0),
                        Text('${s.get('condition')}: ${s.translateCondition(book.condition)}',
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic, color: cardTextColor)),
                        const SizedBox(height: 12.0),
                        Text('${s.get('price')}: ${book.price.toStringAsFixed(2)}zł',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isHighContrast ? Colors.yellow : (isDarkMode ? Colors.greenAccent : Colors.green[800]))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Sprzedawca
            if (book.sellerLogin != null) _buildSellerSection(context, book, theme, s),

            // Recenzje
            _buildReviewsSection(book, theme, s),

            const SizedBox(height: 16.0),

            if (widget.isLoggedIn)
              Semantics(
                button: true,
                child: ElevatedButton(
                  onPressed: () => _showReviewDialog(book, theme, s),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighContrast ? Colors.black : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                  ),
                  child: Text(s.get('add_review'),
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
                    SnackBar(
                        content: Text(s.get('purchase_not_implemented'))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHighContrast ? Colors.black : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
                ),
                child: Text(s.get('buy_now'),
                    style: TextStyle(fontSize: 20, color: isHighContrast ? Colors.yellow : Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerSection(BuildContext context, Book book, ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

    Color sectionHeaderColor = (isHighContrast) ? Colors.yellow : Colors.white;
    if (!isHighContrast && !isDefaultMode && !isDarkMode) sectionHeaderColor = Colors.black;
    Color cardTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.get('sold_by'),
          style: TextStyle(
              color: sectionHeaderColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Card(
          shape:
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
          color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : theme.cardColor)),
          child: ListTile(
            leading: Icon(Icons.person, size: 40, color: isHighContrast ? Colors.yellow : cardTextColor),
            title: Text(book.sellerLogin!,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cardTextColor)),
            subtitle: Text(book.sellerEmail ?? s.get('email_not_available'), 
              style: TextStyle(color: cardTextColor.withOpacity(0.7))),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          s.get('chat_not_implemented'))),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isHighContrast ? Colors.black : Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none),
              ),
              child:
                  Text(s.get('contact'), style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildReviewsSection(Book book, ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

    Color sectionHeaderColor = (isHighContrast) ? Colors.yellow : Colors.white;
    if (!isHighContrast && !isDefaultMode && !isDarkMode) sectionHeaderColor = Colors.black;
    Color cardTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    if (book.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(s.get('no_reviews_yet'),
              style: TextStyle(color: sectionHeaderColor, fontSize: 16)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.get('reviews'),
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
              color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : theme.cardColor)),
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
                                fontWeight: FontWeight.bold, fontSize: 16, color: cardTextColor)),
                        _buildRatingStars(review.rating),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(review.comment, style: TextStyle(fontSize: 14, color: cardTextColor)),
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
