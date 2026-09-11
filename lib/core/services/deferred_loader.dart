import 'dart:async';
import 'package:sehatak/core/services/debounce_service.dart';

class DeferredLoader<T> {
  final DebounceService _debounce = DebounceService();
  final Future<List<T>> Function(String query) _searchFunction;
  final Duration _debounceDelay;
  final int _maxResults;

  DeferredLoader({required Future<List<T>> Function(String query) searchFunction, Duration debounceDelay = const Duration(milliseconds: 300), int maxResults = 20}) : _searchFunction = searchFunction, _debounceDelay = debounceDelay, _maxResults = maxResults;

  Future<List<T>> search(String query) async {
    if (query.isEmpty) return [];
    final completer = Completer<List<T>>();
    _debounce.search(query, (q) async {
      try { completer.complete((await _searchFunction(q)).take(_maxResults).toList()); } catch (e) { completer.completeError(e); }
    });
    return completer.future;
  }
  void dispose() => _debounce.dispose();
}
