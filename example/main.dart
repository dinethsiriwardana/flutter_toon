import 'package:flutter_toon/flutter_toon.dart';

// Minimal example showing how to convert JSON -> TOON and TOON -> JSON.
void main() {
  final json = {
    'name': 'Mickey',
    'age': 92,
    'isActive': true,
    'tags': ['mouse', 'cartoon'],
    'address': {
      'city': 'Orlando',
      'zip': '32830',
    },
    'items': [
      {'id': 1, 'label': 'One'},
      {'id': 2, 'label': 'Two'},
    ],
  };

  final toon = jsonToToon(json);
  print('TOON output:\n$toon\n');

  final jsonBack = toonToJson(toon);
  print('JSON back:\n$jsonBack');
}
