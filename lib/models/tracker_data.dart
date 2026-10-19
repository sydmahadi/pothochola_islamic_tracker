class TrackerData {
  static Map<String, dynamic> empty() => {
        'goals': <dynamic>[],
        'habits': <String, dynamic>{},
        'reflections': <String, dynamic>{},
        'rights': <dynamic>[],
        'todayAmalLogs': <String, dynamic>{},
      };

  static Map<String, dynamic> normalize(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Saved data is not a map');
    }

    // আগে থেকে থাকা সব Key ও ডেটা সংরক্ষণ করবে।
    final Map<String, dynamic> loaded =
        Map<String, dynamic>.from(value);

    // প্রয়োজনীয় Key না থাকলে শুধু তখনই যোগ করবে।
    loaded.putIfAbsent('goals', () => <dynamic>[]);
    loaded.putIfAbsent('habits', () => <String, dynamic>{});
    loaded.putIfAbsent('reflections', () => <String, dynamic>{});
    loaded.putIfAbsent('rights', () => <dynamic>[]);
    loaded.putIfAbsent('todayAmalLogs', () => <String, dynamic>{});

    // পরিচিত Key-গুলোর ডেটার ধরন ঠিক রাখবে।
    if (loaded['goals'] is! List) {
      loaded['goals'] = <dynamic>[];
    }

    if (loaded['habits'] is! Map) {
      loaded['habits'] = <String, dynamic>{};
    } else {
      loaded['habits'] =
          Map<String, dynamic>.from(loaded['habits'] as Map);
    }

    if (loaded['reflections'] is! Map) {
      loaded['reflections'] = <String, dynamic>{};
    } else {
      loaded['reflections'] =
          Map<String, dynamic>.from(loaded['reflections'] as Map);
    }

    if (loaded['rights'] is! List) {
      loaded['rights'] = <dynamic>[];
    }

    if (loaded['todayAmalLogs'] is! Map) {
      loaded['todayAmalLogs'] = <String, dynamic>{};
    } else {
      loaded['todayAmalLogs'] =
          Map<String, dynamic>.from(loaded['todayAmalLogs'] as Map);
    }

    return loaded;
  }
}
