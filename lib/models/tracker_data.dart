class TrackerData {
  static Map<String, dynamic> empty() => {
        'goals': <dynamic>[],
        'habits': <String, dynamic>{},
        'reflections': <String, dynamic>{},
        'rights': <dynamic>[],
      };

  static Map<String, dynamic> normalize(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Saved data is not a map');
    }

    final loaded = Map<String, dynamic>.from(value);

    return {
      'goals': loaded['goals'] is List
          ? List<dynamic>.from(loaded['goals'])
          : <dynamic>[],
      'habits': loaded['habits'] is Map
          ? Map<String, dynamic>.from(loaded['habits'])
          : <String, dynamic>{},
      'reflections': loaded['reflections'] is Map
          ? Map<String, dynamic>.from(loaded['reflections'])
          : <String, dynamic>{},
      'rights': loaded['rights'] is List
          ? List<dynamic>.from(loaded['rights'])
          : <dynamic>[],
    };
  }
}
