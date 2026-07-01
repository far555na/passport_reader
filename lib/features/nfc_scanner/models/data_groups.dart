import 'dart:typed_data';

class DataGroups {
  final Map<int, Uint8List> _data;

  DataGroups(this._data);

  /// Retrieves the raw bytes for a specific Data Group.
  Uint8List? get(int dgNumber) => _data[dgNumber];

  /// Checks if a specific Data Group is present.
  bool contains(int dgNumber) => _data.containsKey(dgNumber);

  /// Exposes the entries for iteration.
  Iterable<MapEntry<int, Uint8List>> get entries => _data.entries;

  /// Checks if there are no data groups loaded.
  bool get isEmpty => _data.isEmpty;
}
