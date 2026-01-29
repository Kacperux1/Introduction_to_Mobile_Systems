class CompletedOffer {
  final int id;
  final String title;
  final String author;
  final double price;
  final String? sellerLogin;
  final String? buyerLogin;
  final DateTime completionDate;

  CompletedOffer({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.sellerLogin,
    this.buyerLogin,
    required this.completionDate,
  });

  factory CompletedOffer.fromJson(Map<String, dynamic> json) {
    return CompletedOffer(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'No Author',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      sellerLogin: json['sellerLogin'],
      buyerLogin: json['buyerLogin'],
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : DateTime.now(),
    );
  }
}
