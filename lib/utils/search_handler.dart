import 'package:codepan/models/master.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:flutter/cupertino.dart';

abstract class StateWithSearch<S extends StatefulWidget, M extends MasterData>
    extends State<S> {
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
  }

  void onSearch(text) {
    _debouncer.run(() {
      _search = text.toLowerCase();
      _suggestions.clear();
      if (_search.isNotEmpty) {
        for (final item in allItems) {
          final name = item.name;
          if(name != null) {
            if (name.toLowerCase().contains(_search)) {
              _suggestions.add(item);
            }
          }
        }
      }
      setState(() {});
    });
  }
}
