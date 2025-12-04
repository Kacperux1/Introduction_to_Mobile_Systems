class Review {
  final String reviewerName;
  final int rating;
  final String comment;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewerName: json['reviewerName'] ?? 'Anonymous',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}

class Book {
  final int id;
  final String title;
  final String author;
  final String condition;
  final double price;
  final String imageUrl;
  final String? sellerLogin;
  final String? sellerEmail;
  final List<Review> reviews;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.price,
    required this.imageUrl,
    this.sellerLogin,
    this.sellerEmail,
    required this.reviews,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var reviewList = json['reviews'] as List? ?? [];
    List<Review> reviews = reviewList.map((i) => Review.fromJson(i)).toList();

    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'No Author',
      condition: json['condition'] ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      sellerLogin: json['sellerLogin'],
      sellerEmail: json['sellerEmail'],
      reviews: reviews,
    );
  }
}
