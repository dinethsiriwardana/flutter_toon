# flutter_toon

A small Flutter package for converting **JSON ↔ TOON**.

TOON is a compact, human-readable format for structured data. This package keeps the API simple and covers the common TOON shapes:

- flat objects
- nested objects
- primitive arrays
- uniform arrays of objects

## Features

- Convert a JSON string or decoded JSON value to TOON
- Convert TOON back to a compact JSON string
- Keep output readable and easy to debug

## Usage

```dart
import 'package:flutter_toon/flutter_toon.dart';

final toon = jsonToToon({
	'user': {
		'id': 1,
		'name': 'Ada',
	}
});

final json = toonToJson('user:\n  id: 1\n  name: Ada');
```

## Example

Here is a small JSON API error response example:

```dart
final toon = jsonToToon({
	'jsonapi': {'version': '1.1'},
	'errors': [
		{
			'code': '123',
			'source': {'pointer': '/data/attributes/firstName'},
			'title': 'Value is too short',
			'detail': 'First name must contain at least two characters.',
		},
	],
});

final json = toonToJson(toon);
```

This becomes TOON like this:

```toon
jsonapi:
	version: "1.1"
errors[1]:
	- code: "123"
		source.pointer: /data/attributes/firstName
		title: Value is too short
		detail: First name must contain at least two characters.
```

## Notes

- The package is designed for common TOON structures used in LLM prompts.
- Uniform object arrays are encoded in table form.
- Complex mixed arrays are not supported in this first version.
