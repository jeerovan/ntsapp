import 'dart:async';
import 'package:flutter/material.dart';
import 'model_item.dart';
import 'model_search_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key,});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final List<ModelSearchItem> _items = []; // Store items
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
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
    final newItems = await ModelSearchItem.all(query, _offset, _limit);
    _hasMore = newItems.length == _limit;
    if (_hasMore) _offset += _limit;
    setState(() {
      _items.clear();
      _items.addAll(newItems);
    });
  }

  Future<void> _scrollSearch() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newItems = await ModelSearchItem.all(_searchQuery, _offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _offset += _limit;
      _hasMore = newItems.length == _limit;
    });
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
            // Display search query or results here
            Expanded(
              child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoading) {
                  _scrollSearch();
                }
                return false;
              },
              child: ListView.builder(
                reverse: true,
                itemCount: _items.length + 1, // Additional item for the loading indicator
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return _hasMore
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink() ;
                  }
                  final item = _items[index];
                  return _buildItem(item);
                },
              ),
            ),
            ),
            const SizedBox(height: 20),
            _buildInputBox()
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Type here...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  Widget _buildItem(ModelSearchItem search) {
    ModelItem item = search.item;
    switch (item.type) {
      case 100000:
        return _buildTextItem(item);
      case 110000:
        return _buildImageItem(item);
      case 120000:
        return _buildVideoItem(item);
      case 130000:
        return _buildAudioItem(item);
      case 140000:
        return _buildDocumentItem(item);
      case 150000:
        return _buildLocationItem(item);
      case 160000:
        return _buildContactItem(item);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextItem(ModelItem item){
    return const SizedBox.shrink();
  }
  Widget _buildImageItem(ModelItem item){
    return const SizedBox.shrink();
  }
  Widget _buildVideoItem(ModelItem item){
    return const SizedBox.shrink();
  }
  Widget _buildAudioItem(ModelItem item){
    return const SizedBox.shrink();
  }
  Widget _buildDocumentItem(ModelItem item){
    return const SizedBox.shrink();
  }
  Widget _buildLocationItem(ModelItem item){
    return const SizedBox.shrink();
  }
  Widget _buildContactItem(ModelItem item){
    return const SizedBox.shrink();
  }

}