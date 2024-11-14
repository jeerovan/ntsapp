import 'dart:async';
import 'package:flutter/material.dart';

class ScrollPage extends StatefulWidget {
  const ScrollPage({super.key});

  @override
  ScrollPageState createState() => ScrollPageState();
}

class ScrollPageState extends State<ScrollPage> {
  final List<int> _items = [];
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";
  bool _isLoading = false;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _textController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
        });
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _items.clear();
      });
      return;
    }

    int? start;
    try {
      start = int.parse(query);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid input. Please enter a number.")),
      );
      return;
    }

    final newItems = generateList(start, false, _limit);
    setState(() {
      _items.clear();
      _items.addAll(newItems.reversed);
    });
  }

  Future<void> _scrollSearch(bool up) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    //await Future.delayed(const Duration(seconds: 1));
    final start = up ? _items.last : _items.first;
    final newItems = generateList(start, up, _limit);

    setState(() {
      if (up) {
        _items.addAll(newItems);
      } else {
        _items.insertAll(0, newItems.reversed);
      }
      _isLoading = false;
    });
  }

  List<int> generateList(int start, bool direction, int limit) {
    List<int> result = [];
    if (direction) {
      for (int i = start + 1; i <= 500 && result.length < limit; i++) {
        result.add(i);
      }
    } else {
      for (int i = start - 1; i > 0 && result.length < limit; i--) {
        result.add(i);
      }
    }
    return result;
  }

  @override
  void dispose() {
    _textController.removeListener(_onSearchChanged);
    _textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Notes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels  == scrollInfo.metrics.maxScrollExtent) {
                    _scrollSearch(true); // Load upwards
                  } else if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
                    _scrollSearch(false); // Load downwards
                  }
                  return false;
                },
                child: ListView.builder(
                  reverse: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          _items[index].toString(),
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildInputBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Enter a number to search...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}
