import 'dart:async';
import 'package:sehatak/core/services/debounce_service.dart';

class DeferredLoader<T> {
  final DebounceService _debounce = DebounceService();
  final Future<List<T>> Function(String query) _searchFunction;
  final Duration _debounceDelay;
  final int _maxResults;

  DeferredLoader({
    required Future<List<T>> Function(String query) searchFunction,
    this._debounceDelay = const Duration(milliseconds: 300),
    this._maxResults = 20,
  }) : _searchFunction = searchFunction;

  Future<List<T>> search(String query) async {
    if (query.isEmpty) return [];
    
    final completer = Completer<List<T>>();
    
    _debounce.search(query, (q) async {
      try {
        final results = await _searchFunction(q);
        completer.complete(results.take(_maxResults).toList());
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    return completer.future;
  }

  void dispose() {
    _debounce.dispose();
  }
}
