import 'package:mazadi/core/models/category.dart';
import 'package:flutter/material.dart';

class CategoryAuctionsScreen extends StatefulWidget {
  final Category category;
  final Function onBack;

  const CategoryAuctionsScreen({
    super.key,
    required this.category,
    required this.onBack,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryAuctionsScreenState createState() => _CategoryAuctionsScreenState();
}

class _CategoryAuctionsScreenState extends State<CategoryAuctionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category auctions'),
      ),
      body: Center(
        child: Text('Category auctions Screen'),
      ),
    );
  }
}
