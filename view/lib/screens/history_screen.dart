import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n_helper.dart';
import '../models/completed_offer.dart';
import '../models/book.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<CompletedOffer>> _purchasesFuture;
  late Future<List<CompletedOffer>> _salesHistoryFuture;
  late Future<List<Book>> _pendingSalesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _purchasesFuture = _fetchPurchases();
      _salesHistoryFuture = _fetchSalesHistory();
      _pendingSalesFuture = _fetchPendingSales();
    });
  }

  Future<List<CompletedOffer>> _fetchPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await http.get(
      Uri.parse('https://mobilki.bieda.it/api/history/purchases'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => CompletedOffer.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<List<CompletedOffer>> _fetchSalesHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await http.get(
      Uri.parse('https://mobilki.bieda.it/api/history/sales'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => CompletedOffer.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load sales history');
    }
  }

  Future<List<Book>> _fetchPendingSales() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await http.get(
      Uri.parse('https://mobilki.bieda.it/api/books/pending'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Book.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load pending sales');
    }
  }

  Future<void> _confirmSale(int bookId, S s) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('https://mobilki.bieda.it/api/books/$bookId/confirm-sale'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.get('sale_confirmed'))),
          );
          _loadAllData();
        }
      } else {
        final error = jsonDecode(response.body)['message'] ?? response.body;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.get('confirm_failed', args: {'error': error}))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.get('error_occurred', args: {'error': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    Color textColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('history_title'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isHighContrast ? Colors.yellow : Colors.white,
          unselectedLabelColor: isHighContrast ? Colors.yellow.withOpacity(0.5) : Colors.white.withOpacity(0.7),
          indicatorColor: isHighContrast ? Colors.yellow : Colors.white,
          tabs: [
            Tab(text: s.get('purchases')),
            Tab(text: s.get('pending_sales')),
            Tab(text: s.get('sales')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompletedList(_purchasesFuture, s, textColor, isHighContrast, true),
          _buildPendingList(_pendingSalesFuture, s, textColor, isHighContrast),
          _buildCompletedList(_salesHistoryFuture, s, textColor, isHighContrast, false),
        ],
      ),
    );
  }

  Widget _buildCompletedList(Future<List<CompletedOffer>> future, S s, Color textColor, bool isHighContrast, bool isPurchase) {
    return FutureBuilder<List<CompletedOffer>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(s.get('error_occurred', args: {'error': snapshot.error.toString()}), style: TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(s.get('no_history'), style: TextStyle(color: textColor)));
        }

        final offers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return Card(
              color: isHighContrast ? Colors.black : null,
              shape: isHighContrast ? RoundedRectangleBorder(side: const BorderSide(color: Colors.yellow, width: 2), borderRadius: BorderRadius.circular(10)) : null,
              child: ListTile(
                title: Text(offer.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.author, style: TextStyle(color: textColor.withOpacity(0.7))),
                    Text('${s.get('date')}: ${DateFormat('yyyy-MM-dd HH:mm').format(offer.completionDate)}', style: TextStyle(color: textColor.withOpacity(0.7))),
                    Text('${isPurchase ? s.get('seller') : s.get('buyer')}: ${isPurchase ? offer.sellerLogin : offer.buyerLogin}', style: TextStyle(color: textColor.withOpacity(0.7))),
                  ],
                ),
                trailing: Text('${offer.price.toStringAsFixed(2)} zł', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isHighContrast ? Colors.yellow : Colors.green)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingList(Future<List<Book>> future, S s, Color textColor, bool isHighContrast) {
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(s.get('error_occurred', args: {'error': snapshot.error.toString()}), style: TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(s.get('no_history'), style: TextStyle(color: textColor)));
        }

        final books = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              color: isHighContrast ? Colors.black : null,
              shape: isHighContrast ? RoundedRectangleBorder(side: const BorderSide(color: Colors.yellow, width: 2), borderRadius: BorderRadius.circular(10)) : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(book.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.author, style: TextStyle(color: textColor.withOpacity(0.7))),
                          Text('${s.get('buyer')}: ${book.pendingBuyerLogin}', style: TextStyle(color: textColor.withOpacity(0.7))),
                        ],
                      ),
                      trailing: Text('${book.price.toStringAsFixed(2)} zł', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isHighContrast ? Colors.yellow : Colors.green)),
                    ),
                    ElevatedButton(
                      onPressed: () => _confirmSale(book.id, s),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHighContrast ? Colors.black : Colors.green,
                        side: isHighContrast ? const BorderSide(color: Colors.yellow) : null,
                      ),
                      child: Text(s.get('confirm_sale'), style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
