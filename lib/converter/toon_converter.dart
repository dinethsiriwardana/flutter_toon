import 'dart:convert';

/// Converts JSON data to TOON and TOON back to JSON.
class ToonConverter {
  /// Converts a JSON string or decoded JSON value into TOON.
  String jsonToToon(Object? jsonInput) {
    final value = _normalizeJsonInput(jsonInput);
    return _ToonEncoder().encode(value);
  }

  /// Converts a TOON string into a compact JSON string.
  String toonToJson(String toonInput) {
    final value = _ToonDecoder(toonInput).decode();
    return jsonEncode(value);
  }

  Object? _normalizeJsonInput(Object? jsonInput) {
    if (jsonInput is String) {
      return jsonDecode(jsonInput);
    }

    return jsonInput;
  }
}

/// Converts JSON data to TOON and TOON back to JSON.
final toonConverter = ToonConverter();

/// Converts a JSON string or decoded JSON value into TOON.
String jsonToToon(Object? jsonInput) => toonConverter.jsonToToon(jsonInput);

/// Converts a TOON string into a compact JSON string.
String toonToJson(String toonInput) => toonConverter.toonToJson(toonInput);

class _ToonEncoder {
  String encode(Object? value) {
    if (value is Map) {
      return _encodeObject(_normalizeMap(value));
    }

    throw const FormatException('TOON root value must be a JSON object.');
  }

  String _encodeObject(Map<String, dynamic> value) {
    final lines = <String>[];

    for (final entry in value.entries) {
      lines.addAll(_encodeEntry(entry.key, entry.value, 0));
    }

    return lines.join('\n');
  }

  List<String> _encodeEntry(String key, Object? value, int indentLevel) {
    final indent = '  ' * indentLevel;

    if (value is Map) {
      final map = _normalizeMap(value);
      if (map.isEmpty) {
        return ['$indent$key:'];
      }

      final lines = <String>['$indent$key:'];
      for (final entry in map.entries) {
        lines.addAll(_encodeEntry(entry.key, entry.value, indentLevel + 1));
      }
      return lines;
    }

    if (value is List) {
      return _encodeList(key, value, indentLevel);
    }

    return ['$indent$key: ${_encodeScalar(value)}'];
  }

  List<String> _encodeList(String key, List<dynamic> value, int indentLevel) {
    final indent = '  ' * indentLevel;

    if (value.isEmpty) {
      return ['$indent$key[0]:'];
    }

    if (_isPrimitiveList(value)) {
      final items = value.map(_encodeScalar).join(',');
      return ['$indent$key[${value.length}]: $items'];
    }

    if (_isUniformObjectList(value) && _isPrimitiveObjectList(value)) {
      final first = _normalizeMap(value.first as Map);
      final fields = first.keys.toList();
      final header = '$indent$key[${value.length}]{${fields.join(',')}}:';
      final rows = <String>[header];
      final rowIndent = '  ' * indentLevel;

      for (final item in value) {
        final map = _normalizeMap(item as Map);
        final row = fields.map((field) => _encodeScalar(map[field])).join(',');
        rows.add('$rowIndent$row');
      }

      return rows;
    }

    if (_isObjectList(value)) {
      return _encodeVerboseObjectList(key, value, indentLevel);
    }

    throw UnsupportedError(
      'Only primitive arrays and uniform object arrays are supported.',
    );
  }

  bool _isPrimitiveList(List<dynamic> value) {
    return value.every((item) => _isPrimitive(item) || item == null);
  }

  bool _isUniformObjectList(List<dynamic> value) {
    if (value.isEmpty || value.any((item) => item is! Map)) {
      return false;
    }

    final first = _normalizeMap(value.first as Map);
    final fields = first.keys.toList();

    return value.every((item) {
      final map = _normalizeMap(item as Map);
      if (map.keys.length != fields.length) {
        return false;
      }

      return fields.every(map.containsKey);
    });
  }

  bool _isPrimitiveObjectList(List<dynamic> value) {
    return value.every((item) {
      final map = _normalizeMap(item as Map);
      return map.values.every(_isPrimitive);
    });
  }

  bool _isObjectList(List<dynamic> value) {
    return value.isNotEmpty && value.every((item) => item is Map);
  }

  Map<String, dynamic> _normalizeMap(Map value) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  List<String> _encodeVerboseObjectList(
    String key,
    List<dynamic> value,
    int indentLevel,
  ) {
    final headerIndent = '  ' * indentLevel;
    final rowIndent = '  ' * (indentLevel + 1);
    final fieldIndent = '  ' * (indentLevel + 2);
    final lines = <String>['$headerIndent$key[${value.length}]:'];

    for (final item in value) {
      final map = _normalizeMap(item as Map);
      final flattened = _flattenEntries(map);

      if (flattened.isEmpty) {
        lines.add('$rowIndent-');
        continue;
      }

      var firstLine = true;
      for (final entry in flattened) {
        final encoded = '${entry.key}: ${_encodeScalar(entry.value)}';
        if (firstLine) {
          lines.add('$rowIndent- $encoded');
          firstLine = false;
        } else {
          lines.add('$fieldIndent$encoded');
        }
      }
    }

    return lines;
  }

  List<MapEntry<String, Object?>> _flattenEntries(
    Map<String, dynamic> value, [
    String prefix = '',
  ]) {
    final entries = <MapEntry<String, Object?>>[];

    for (final entry in value.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final item = entry.value;

      if (item is Map) {
        entries.addAll(_flattenEntries(_normalizeMap(item), key));
        continue;
      }

      entries.add(MapEntry(key, item));
    }

    return entries;
  }

  String _encodeScalar(Object? value) {
    if (value == null) {
      return 'null';
    }

    if (value is bool || value is num) {
      return value.toString();
    }

    final text = value.toString();
    return _needsQuotes(text) ? _quote(text) : text;
  }

  bool _isPrimitive(Object? value) {
    return value == null || value is bool || value is num || value is String;
  }

  bool _needsQuotes(String value) {
    return value.isEmpty ||
        value.startsWith(' ') ||
        value.endsWith(' ') ||
        value.contains(',') ||
        value.contains(':') ||
        value.contains('"') ||
        value.contains('\n') ||
        _looksLikeJsonNumber(value) ||
        value == 'true' ||
        value == 'false' ||
        value == 'null';
  }

  bool _looksLikeJsonNumber(String value) {
    return RegExp(r'^-?(0|[1-9]\d*)(\.\d+)?([eE][+-]?\d+)?$').hasMatch(value);
  }

  String _quote(String value) {
    return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';
  }
}

class _ToonDecoder {
  _ToonDecoder(String input) : _lines = input.replaceAll('\r\n', '\n').split('\n');

  final List<String> _lines;
  int _index = 0;

  Object? decode() {
    final value = _parseObject(0);
    _skipBlankLines();

    if (_index < _lines.length) {
      throw FormatException('Unexpected TOON content on line ${_index + 1}.');
    }

    return value;
  }

  Map<String, dynamic> _parseObject(int indentLevel) {
    final result = <String, dynamic>{};

    while (_index < _lines.length) {
      final rawLine = _lines[_index];
      final line = _Line(rawLine);

      if (line.text.trim().isEmpty) {
        _index++;
        continue;
      }

      if (line.indent < indentLevel) {
        break;
      }

      if (line.indent > indentLevel) {
        throw FormatException('Invalid indentation on line ${_index + 1}.');
      }

      final colonIndex = _indexOfTopLevelColon(line.text);
      if (colonIndex < 0) {
        break;
      }

      final header = line.text.substring(0, colonIndex).trim();
      final rest = line.text.substring(colonIndex + 1).trim();
      final parsed = _parseHeader(header);

      _index++;

      if (parsed.isObjectArray) {
        result[parsed.key] = _parseObjectArray(indentLevel, parsed.fields);
        continue;
      }


        if (parsed.length != null &&
            parsed.fields.isEmpty &&
            rest.isEmpty &&
            _nextMeaningfulLineIsVerboseArray(indentLevel)) {
          result[parsed.key] = _parseVerboseObjectArray(indentLevel, parsed.length);
          continue;
        }

        if (parsed.isPrimitiveArray) {
          result[parsed.key] = _parsePrimitiveArray(rest, parsed.length);
          continue;
        }

      if (rest.isNotEmpty) {
        result[parsed.key] = _parseScalar(rest);
        continue;
      }

      final nextIndent = _nextMeaningfulIndent();
      if (nextIndent != null && nextIndent > indentLevel) {
        final nextLine = _peekNextMeaningfulLine();
        if (nextLine != null &&
            nextLine.indent == indentLevel + 1 &&
            nextLine.text.trimLeft().startsWith('- ')) {
          result[parsed.key] = _parseVerboseObjectArray(indentLevel, parsed.length);
        } else {
          result[parsed.key] = _parseObject(nextIndent);
        }
      } else {
        result[parsed.key] = <String, dynamic>{};
      }
    }

    return result;
  }

  List<dynamic> _parseObjectArray(int indentLevel, List<String> fields) {
    final rows = <dynamic>[];

    while (_index < _lines.length) {
      final rawLine = _lines[_index];
      final line = _Line(rawLine);

      if (line.text.trim().isEmpty) {
        _index++;
        continue;
      }

      if (line.indent < indentLevel || _indexOfTopLevelColon(line.text) >= 0) {
        break;
      }

      if (line.indent != indentLevel) {
        throw FormatException('Invalid array row indentation on line ${_index + 1}.');
      }

      rows.add(_parseRow(line.text, fields));
      _index++;
    }

    return rows;
  }

  List<dynamic> _parseVerboseObjectArray(int indentLevel, int? length) {
    final rows = <dynamic>[];
    final rowIndent = indentLevel + 1;

    while (_index < _lines.length) {
      final rawLine = _lines[_index];
      final line = _Line(rawLine);

      if (line.text.trim().isEmpty) {
        _index++;
        continue;
      }

      if (line.indent < rowIndent) {
        break;
      }

      if (line.indent != rowIndent) {
        throw FormatException('Invalid array row indentation on line ${_index + 1}.');
      }

      final trimmed = line.text.trimLeft();
      if (!trimmed.startsWith('- ')) {
        break;
      }

      final row = <String, dynamic>{};
      final inline = trimmed.substring(2).trim();
      _index++;

      if (inline.isNotEmpty) {
        _parsePropertyLine(inline, row);
      }

      while (_index < _lines.length) {
        final nextRaw = _lines[_index];
        final nextLine = _Line(nextRaw);

        if (nextLine.text.trim().isEmpty) {
          _index++;
          continue;
        }

        if (nextLine.indent < rowIndent) {
          break;
        }

        if (nextLine.indent == rowIndent && nextLine.text.trimLeft().startsWith('- ')) {
          break;
        }

        if (nextLine.indent <= rowIndent) {
          throw FormatException('Invalid array row indentation on line ${_index + 1}.');
        }

        _parsePropertyLine(nextLine.text.trimLeft(), row);
        _index++;
      }

      rows.add(row);
    }

    if (length != null && length != rows.length) {
      throw FormatException('Array length mismatch on line $_index.');
    }

    return rows;
  }

  List<dynamic> _parsePrimitiveArray(String rest, int? length) {
    if (rest.isEmpty) {
      return <dynamic>[];
    }

    final items = _splitRow(rest).map(_parseScalar).toList();
    if (length != null && length != items.length) {
      throw FormatException('Array length mismatch on line $_index.');
    }

    return items;
  }

  Map<String, dynamic> _parseRow(String line, List<String> fields) {
    final values = _splitRow(line);
    if (values.length != fields.length) {
      throw FormatException('Row field count mismatch on line ${_index + 1}.');
    }

    final row = <String, dynamic>{};
    for (var i = 0; i < fields.length; i++) {
      row[fields[i]] = _parseScalar(values[i]);
    }

    return row;
  }

  ParsedHeader _parseHeader(String header) {
    final match = RegExp(
      r'^(?<key>[A-Za-z0-9_.-]+)(?:\[(?<length>\d+)\])?(?:\{(?<fields>[^}]*)\})?$',
    ).firstMatch(header);

    if (match == null) {
      throw FormatException('Invalid TOON header on line ${_index + 1}.');
    }

    final key = match.namedGroup('key')!;
    final length = match.namedGroup('length');
    final fields = match.namedGroup('fields');

    return ParsedHeader(
      key: key,
      length: length == null ? null : int.parse(length),
      fields: fields == null || fields.trim().isEmpty
          ? const []
          : fields.split(',').map((field) => field.trim()).toList(),
    );
  }

  int _indexOfTopLevelColon(String line) {
    var quoted = false;
    var escaped = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        quoted = !quoted;
        continue;
      }

      if (!quoted && char == ':') {
        return i;
      }
    }

    return -1;
  }

  List<String> _splitRow(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    var escaped = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (escaped) {
        buffer.write(char);
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        quoted = !quoted;
        continue;
      }

      if (!quoted && char == ',') {
        values.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    values.add(buffer.toString().trim());
    return values;
  }

  void _parsePropertyLine(String text, Map<String, dynamic> target) {
    final colonIndex = _indexOfTopLevelColon(text);

    if (colonIndex < 0) {
      throw FormatException('Invalid TOON property on line ${_index + 1}.');
    }

    final key = text.substring(0, colonIndex).trim();
    final rest = text.substring(colonIndex + 1).trim();

    if (rest.isEmpty) {
      _assignNestedValue(target, key, <String, dynamic>{});
      return;
    }

    _assignNestedValue(target, key, _parseScalar(rest));
  }

  Object? _parseScalar(String text) {
    final value = text.trim();

    if (value == 'null') {
      return null;
    }

    if (value == 'true') {
      return true;
    }

    if (value == 'false') {
      return false;
    }

    if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
      return value
          .substring(1, value.length - 1)
          .replaceAll(r'\"', '"')
          .replaceAll(r'\\', '\\');
    }

    final number = num.tryParse(value);
    if (number != null) {
      return number;
    }

    return value;
  }

  void _assignNestedValue(
    Map<String, dynamic> target,
    String key,
    Object? value,
  ) {
    final parts = key.split('.');
    var current = target;

    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      final existing = current[part];

      if (existing is Map<String, dynamic>) {
        current = existing;
        continue;
      }

      final child = <String, dynamic>{};
      current[part] = child;
      current = child;
    }

    current[parts.last] = value;
  }

  _Line? _peekNextMeaningfulLine() {
    var probe = _index;

    while (probe < _lines.length) {
      final line = _Line(_lines[probe]);
      if (line.text.trim().isEmpty) {
        probe++;
        continue;
      }

      return line;
    }

    return null;
  }

  bool _nextMeaningfulLineIsVerboseArray(int indentLevel) {
    final line = _peekNextMeaningfulLine();

    return line != null &&
        line.indent == indentLevel + 1 &&
        line.text.trimLeft().startsWith('- ');
  }

  void _skipBlankLines() {
    while (_index < _lines.length && _lines[_index].trim().isEmpty) {
      _index++;
    }
  }

  int? _nextMeaningfulIndent() {
    var probe = _index;

    while (probe < _lines.length) {
      final line = _Line(_lines[probe]);
      if (line.text.trim().isEmpty) {
        probe++;
        continue;
      }

      return line.indent;
    }

    return null;
  }
}

class _Line {
  _Line(this.text) : indent = _countIndent(text);

  final String text;
  final int indent;

  static int _countIndent(String text) {
    var count = 0;
    while (count < text.length && text[count] == ' ') {
      count++;
    }
    return count ~/ 2;
  }
}

class ParsedHeader {
  const ParsedHeader({
    required this.key,
    required this.length,
    required this.fields,
  });

  final String key;
  final int? length;
  final List<String> fields;

  bool get isPrimitiveArray => length != null && fields.isEmpty;

  bool get isObjectArray => fields.isNotEmpty;
}