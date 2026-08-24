class DeepComparison {
  static bool deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (var key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!deepEquals(a[key], b[key])) return false;
      }
      return true;
    }

    return a == b;
  }

  static bool areFirebaseDataEqual(Map<String, dynamic>? oldData, Map<String, dynamic>? newData) {
    if (oldData == null && newData == null) return true;
    if (oldData == null || newData == null) return false;
    
    final importantKeys = ['id', 'name', 'image', 'price', 'rating', 'specialty'];
    for (var key in importantKeys) {
      if (oldData[key] != newData[key]) return false;
    }
    return true;
  }
}
