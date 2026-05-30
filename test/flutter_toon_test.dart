import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_toon/flutter_toon.dart';

void main() {
  test('converts json to toon', () {
    final toon = jsonToToon({
      'user': {
        'id': 1,
        'name': 'Ada',
        'active': true,
      },
    });

    expect(toon, 'user:\n  id: 1\n  name: Ada\n  active: true');
  });

  test('converts toon to json', () {
    const toon = 'user:\n  id: 1\n  name: Ada\n  active: true';

    expect(toonToJson(toon), '{"user":{"id":1,"name":"Ada","active":true}}');
  });

  test('round trips uniform object arrays', () {
    final toon = jsonToToon({
      'users': [
        {'id': 1, 'name': 'Ada'},
        {'id': 2, 'name': 'Bob'},
      ],
    });

    expect(toon, 'users[2]{id,name}:\n1,Ada\n2,Bob');
    expect(toonToJson(toon), '{"users":[{"id":1,"name":"Ada"},{"id":2,"name":"Bob"}]}');
  });

  test('handles primitive arrays and empty values', () {
    final toon = jsonToToon({
      'tags': ['dart', 'flutter'],
      'meta': {},
      'empty': [],
    });

    expect(toon, 'tags[2]: dart,flutter\nmeta:\nempty[0]:');
    expect(toonToJson(toon), '{"tags":["dart","flutter"],"meta":{},"empty":[]}');
  });

  test('converts jsonapi errors to toon', () {
    final toon = jsonToToon({
      'jsonapi': {'version': '1.1'},
      'errors': [
        {
          'code': '123',
          'source': {'pointer': '/data/attributes/firstName'},
          'title': 'Value is too short',
          'detail': 'First name must contain at least two characters.',
        },
        {
          'code': '225',
          'source': {'pointer': '/data/attributes/password'},
          'title': 'Passwords must contain a letter, number, and punctuation character.',
          'detail': 'The password provided is missing a punctuation character.',
        },
        {
          'code': '226',
          'source': {'pointer': '/data/attributes/password'},
          'title': 'Password and password confirmation do not match.',
        },
      ],
    });

    expect(
      toon,
      'jsonapi:\n'
      '  version: "1.1"\n'
      'errors[3]:\n'
      '  - code: "123"\n'
      '    source.pointer: /data/attributes/firstName\n'
      '    title: Value is too short\n'
      '    detail: First name must contain at least two characters.\n'
      '  - code: "225"\n'
      '    source.pointer: /data/attributes/password\n'
      '    title: "Passwords must contain a letter, number, and punctuation character."\n'
      '    detail: The password provided is missing a punctuation character.\n'
      '  - code: "226"\n'
      '    source.pointer: /data/attributes/password\n'
      '    title: Password and password confirmation do not match.',
    );

    expect(
      toonToJson(toon),
      '{"jsonapi":{"version":"1.1"},"errors":[{"code":"123","source":{"pointer":"/data/attributes/firstName"},"title":"Value is too short","detail":"First name must contain at least two characters."},{"code":"225","source":{"pointer":"/data/attributes/password"},"title":"Passwords must contain a letter, number, and punctuation character.","detail":"The password provided is missing a punctuation character."},{"code":"226","source":{"pointer":"/data/attributes/password"},"title":"Password and password confirmation do not match."}]}',
    );
  });
}
