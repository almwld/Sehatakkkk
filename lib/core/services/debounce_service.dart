import 'dart:async';

class DebounceService {
  static final DebounceService _instance = DebounceService._internal();
  factory DebounceService() => _instance;
  DebounceService._internal();

  final Map<String, Timer> _timers = {};

  void run(String id, VoidCallback action, {Duration delay = const Duration(milliseconds: 300)}) {
    _timers[id]?.cancel();
    _timers[id] = Timer(delay, () {
      action();
      _timers.remove(id);
    });
  }

  void search(String query, Function(String) onSearch) {
    run('search', () => onSearch(query));
  }

  void loadMore(String id, VoidCallback action) {
    run(id, action, delay: const Duration(milliseconds: 200));
  }

  void dispose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
