import 'package:codepan/utils/debouncer.dart';
import 'package:flutter/material.dart';

abstract class Searchable {
  List<String?> get searchable;
}

mixin SearchHandlerMixin<S extends StatefulWidget, M extends Searchable>
    on State<S> {
  final Debouncer _debouncer = Debouncer();
  final List<M> _suggestions = [];
  String _search = '';

  List<M> get allItems;

  List<M> get items => showSuggestions ? _suggestions : allItems;

  bool get showSuggestions => _search.isNotEmpty;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.cancel();
  }

  void onSearch(String text) {
    _debouncer.cancel();
    _debouncer.run(() {
      _search = text.toLowerCase();
      _suggestions.clear();
      if (_search.isNotEmpty) {
        for (final item in allItems) {
          for (final text in item.searchable) {
            if (text != null && text.toLowerCase().contains(_search)) {
              _suggestions.add(item);
              break;
            }
          }
        }
      }
      setState(() {});
    });
  }
}
