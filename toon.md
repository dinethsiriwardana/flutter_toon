# TOON (Token-Oriented Object Notation) — Complete Technical Documentation

## Executive Summary

**TOON (Token-Oriented Object Notation)** is a compact, human-readable data serialization format designed specifically for passing structured data to Large Language Models (LLMs) with **30–60% fewer tokens** compared to JSON. It combines YAML-like indentation for nested objects with CSV-style tabular layouts for uniform arrays, achieving token efficiency while maintaining lossless JSON round-trip compatibility. [github](https://github.com/toon-format/spec)

***

## 1. What Is TOON?

### Definition
TOON is a **line-oriented, indentation-based encoding** of the JSON data model for LLM prompts. It provides:
- **Lossless serialization** of JSON objects, arrays, and primitives [github](https://github.com/toon-format/spec)
- **Schema-aware structure** with explicit array lengths `[N]` and field declarations `{fields}` [toonformat](https://toonformat.dev)
- **Human readability** with YAML-like indentation and minimal punctuation [united-codes](https://www.united-codes.com/products/uc-ai/docs/guides/toon/)

### Current Status
| Attribute | Value |
|-----------|-------|
| **Specification Version** | 3.0 (Working Draft, 2025-11-24)  [github](https://github.com/toon-format/spec) |
| **License** | MIT  [github](https://github.com/toon-format/spec) |
| **Official Repository** | `github.com/toon-format/spec`  [github](https://github.com/toon-format/spec) |
| **Primary Use Case** | LLM input/prompts (not general API replacement)  [linkedin](https://www.linkedin.com/posts/giacomoveneri_github-toon-formattoon-token-oriented-activity-7395486995977842688-Ei29) |

***

## 2. Core Design Principles

| Principle | Description |
|-----------|-------------|
| **Token Efficiency** | Eliminates redundant syntax (braces, brackets, most quotes)  [github](https://github.com/toon-format/spec) |
| **Schema-Aware** | Explicit `[N]` lengths and `{fields}` headers help LLMs validate structure  [github](https://github.com/toon-format/spec) |
| **Human-Readable** | Indentation-based hierarchy (2 spaces per level), YAML-like syntax  [github](https://github.com/toon-format/spec) |
| **Tabular for Uniform Arrays** | CSV-style header + rows for objects with identical fields  [github](https://github.com/toon-format/spec) |
| **Lossless JSON Round-Trip** | JSON → TOON → JSON without data loss  [github](https://github.com/toon-format/spec) |

***

## 3. TOON Syntax Reference

### 3.1 Simple Objects
TOON removes curly braces and uses `key: value` notation with newlines between properties:

```toon
id: 123
name: Ada
active: true
```

**Equivalent JSON:**
```json
{ "id": 123, "name": "Ada", "active": true }
```


***

### 3.2 Nested Objects
Uses YAML-like indentation (2 spaces per level):

```toon
user:
  id: 123
  name: Ada
```

**Equivalent JSON:**
```json
{ "user": { "id": 123, "name": "Ada" } }
```


***

### 3.3 Arrays of Primitives
Declares length inline with comma-separated values:

```toon
tags [toonformat](https://toonformat.dev): foo,bar,baz
numbers [toonformat](https://toonformat.dev): 1,2,3
```

**Equivalent JSON:**
```json
{ "tags": ["foo", "bar", "baz"], "numbers": [1, 2, 3] }
```


***

### 3.4 Uniform Object Arrays (Tabular Format) — **Core Feature**

This is where TOON achieves maximum token savings (30–60%):

```toon
users [linkedin](https://www.linkedin.com/posts/ranjithsrajan_github-toon-formattoon-token-oriented-activity-7394624263695216640-g8Fb){id,name,role}:
1,Alice,admin
2,Bob,user
```

**Equivalent JSON:**
```json
{
  "users": [
    { "id": 1, "name": "Alice", "role": "admin" },
    { "id": 2, "name": "Bob", "role": "user" }
  ]
}
```

**Syntax breakdown:**
| Component | Meaning |
|-----------|---------|
| `users [linkedin](https://www.linkedin.com/posts/ranjithsrajan_github-toon-formattoon-token-oriented-activity-7394624263695216640-g8Fb)` | Array named "users" with 2 elements  [github](https://github.com/toon-format/spec) |
| `{id,name,role}` | Field schema declared once  [github](https://github.com/toon-format/spec) |
| Each line | One row/object with comma-separated values  [github](https://github.com/toon-format/spec) |

For 100 employees, this reduces **60.7% tokens** vs formatted JSON: [linkedin](https://www.linkedin.com/pulse/introducing-tooner-bringing-toon-format-laravel-pouya-zouravand-vfuof)

```toon
employees[100]{id,name,email,department,salary}:
1,Alice Johnson,alice@company.com,Engineering,75000
2,Bob Smith,bob@company.com,Sales,65000
...
```


***

### 3.5 Delimiter Options

TOON supports multiple delimiters for row values:

| Delimiter | Syntax | When to Use |
|-----------|--------|-------------|
| Comma (default) | `,` | General use |
| Tab | `\t` | Better compression, reduces quoting needs  [github](https://github.com/toon-format/spec) |
| Pipe | `\|` | When data contains commas  [github](https://github.com/toon-format/spec) |

Using tabs can offer **additional token savings** because it reduces the need for quoting/escaping. [github](https://github.com/toon-format/spec)

***

### 3.6 Key Folding

For chains of single-level "wrapper" keys, TOON supports dotted paths to save tokens:

```toon
user.profile.name: Ada
user.profile.age: 30
```

Instead of nested indentation when appropriate. [github](https://github.com/toon-format/spec)

***

### 3.7 String Quoting

Strings are **quoted only when necessary**:
- Contains the active delimiter
- Contains colons `:`
- Has leading/trailing spaces
- Contains control characters

Example:
```toon
message: "He said \"hello\""
simple: Hello World
```


***

### 3.8 Special Type Conversion

| Type | TOON Representation |
|------|---------------------|
| Numbers | Decimal form (not scientific)  [github](https://github.com/toon-format/spec) |
| `NaN` / ±Infinity | `null`  [github](https://github.com/toon-format/spec) |
| BigInt (safe range) | Number  [github](https://github.com/toon-format/spec) |
| BigInt (unsafe) | Quoted decimal string  [github](https://github.com/toon-format/spec) |
| Dates | Quoted ISO strings  [github](https://github.com/toon-format/spec) |
| Non-serializable | `null`  [github](https://github.com/toon-format/spec) |
| Null values | `null`  [united-codes](https://www.united-codes.com/products/uc-ai/docs/guides/toon/) |
| Booleans | `true` / `false`  [united-codes](https://www.united-codes.com/products/uc-ai/docs/guides/toon/) |
| Empty arrays | `key[0]:`  [united-codes](https://www.united-codes.com/products/uc-ai/docs/guides/toon/) |
| Empty objects | `key:`  [united-codes](https://www.united-codes.com/products/uc-ai/docs/guides/toon/) |

***

## 4. Token Efficiency Benchmarks

### 4.1 Overall Performance

| Metric | TOON vs JSON |
|--------|--------------|
| **Average Token Reduction** | 30–60%  [github](https://github.com/toon-format/spec) |
| **Formatted JSON vs TOON** | 55% reduction  [infoq](https://www.infoq.com/news/2025/11/toon-reduce-llm-cost-tokens/) |
| **Compact JSON vs TOON** | 25% reduction  [infoq](https://www.infoq.com/news/2025/11/toon-reduce-llm-cost-tokens/) |
| **YAML vs TOON** | 38% reduction  [infoq](https://www.infoq.com/news/2025/11/toon-reduce-llm-cost-tokens/) |

### 4.2 Real Dataset Benchmarks

| Dataset | JSON Tokens | TOON Tokens | Savings | Cost Saved (GPT-4 Turbo) |
|---------|-------------|-------------|---------|--------------------------|
| User Profiles (100 records) | 12,500 | 6,250 | **50%** | $0.019  [toontools](https://www.toontools.app/benchmarks) |
| E-commerce Products (500 items) | 45,000 | 20,700 | **54%** | $0.073  [toontools](https://www.toontools.app/benchmarks) |
| Chat Conversation (50 messages) | 8,200 | 3,690 | **55%** | $0.013  [toontools](https://www.toontools.app/benchmarks) |
| API Response (Nested Data) | 18,500 | 9,065 | **51%** | $0.028  [toontools](https://www.toontools.app/benchmarks) |

*Costs based on GPT-4 Turbo pricing ($0.01 per 1K input tokens) * [toontools](https://www.toontools.app/benchmarks)

### 4.3 LLM Accuracy Results

| Benchmark | TOON Accuracy | JSON Accuracy | Token Usage |
|-----------|---------------|---------------|-------------|
| Uniform arrays (GitHub tests) | **73.9%** | 69.7% | 39.6% fewer  [linkedin](https://www.linkedin.com/posts/ranjithsrajan_github-toon-formattoon-token-oriented-activity-7394624263695216640-g8Fb) |
| Mixed-structure (4 models) | **76.4%** | 75.0% | ~40% fewer  [toonformat](https://toonformat.dev) |
| GPT-5 Nano retrieval | **99.4%** | N/A | 46% fewer  [infoq](https://www.infoq.com/news/2025/11/toon-reduce-llm-cost-tokens/) |

**Note:** Some independent benchmarks show TOON performing worse than markdown tables for nested data retrieval. [improvingagents](https://www.improvingagents.com/blog/toon-benchmarks)

***

## 5. When to Use TOON

### ✅ Ideal Use Cases

| Scenario | Why TOON Excels |
|----------|-----------------|
| **Uniform arrays of objects** | Maximum token savings (declare keys once, stream rows)  [github](https://github.com/toon-format/spec) |
| **AI prompting with structured data** | Schema-aware guardrails improve LLM comprehension  [github](https://github.com/toon-format/spec) |
| **Token-sensitive applications** | 30–60% cost reduction on billed tokens  [github](https://github.com/toon-format/spec) |
| **Database exports / analytics data** | Consistent schemas benefit from tabular format  [linkedin](https://www.linkedin.com/posts/lirielly_github-toon-formattoon-token-oriented-activity-7392234691656896512-9nG3) |
| **API responses with consistent structure** | e.g., 15K GitHub repos: 42% reduction  [linkedin](https://www.linkedin.com/posts/lirielly_github-toon-formattoon-token-oriented-activity-7392234691656896512-9nG3) |

### ❌ When NOT to Use TOON

| Scenario | Reason |
|----------|--------|
| **Highly nested structures** | Token savings decrease; may be worse than compact JSON  [github](https://github.com/toon-format/spec) |
| **Non-uniform arrays** | Variable fields reduce tabular benefits  [github](https://github.com/toon-format/spec) |
| **Simple flat tables** | CSV may be more compact (TOON adds metadata overhead)  [github](https://github.com/toon-format/spec) |
| **Latency-critical apps** | Serialization/deserialization time may favor compact JSON  [github](https://github.com/toon-format/spec) |
| **General API communication** | JSON remains the standard; TOON is for LLM input primarily  [linkedin](https://www.linkedin.com/posts/giacomoveneri_github-toon-formattoon-token-oriented-activity-7395486995977842688-Ei29) |

***

## 6. Using TOON in LLM Prompts

### 6.1 Encoding Before Sending

Use official libraries to convert JSON → TOON:

**TypeScript example:**
```typescript
import { encode } from '@toon-format/toon';

const toon = encode(jsonData);
```

Include in prompt as a code block:
```
```toon
users{id,name,role}: [jsdelivr](https://www.jsdelivr.com/package/npm/@toon-format/spec)
1,Alice,admin
2,Bob,user
3,Charlie,user
```
```


***

### 6.2 Generating TOON from the LLM

To have the model output TOON:
1. Show a sample TOON header (e.g., `users[N]{…}:`)
2. Specify the model must produce matching rows and correct `[N]` value
3. Require answer **only in code block** in TOON format

This pattern helps the model avoid guessing key names. [github](https://github.com/toon-format/spec)

***

## 7. Implementations & Tools

### 7.1 Official SDKs

| Language | Package | Purpose |
|----------|---------|---------|
| **TypeScript/JavaScript** | `@toon-format/toon` (official) | Encode/decode JSON ↔ TOON  [github](https://github.com/toon-format/spec) |
| **TypeScript Spec** | `@toon-format/spec` | Specification package  [jsdelivr](https://www.jsdelivr.com/package/npm/@toon-format/spec) |
| **CLI Tool** | `@toon-format/cli` | Convert JSON ↔ TOON with token analysis  [jsdelivr](https://www.jsdelivr.com/package/npm/@toon-format/cli) |
| **Elixir** | `tooner` | Laravel/PHP implementation  [linkedin](https://www.linkedin.com/pulse/introducing-tooner-bringing-toon-format-laravel-pouya-zouravand-vfuof) |
| **PHP** | `Tooner` | TOON port for PHP  [github](https://github.com/toon-format/spec) |
| **R** | `toon` (CRAN) | Serialize R objects to TOON  [github](https://github.com/toon-format/spec) |
| **Python** | `toonify` | Inspired by TypeScript library  [github](https://github.com/ScrapeGraphAI/toonify/blob/main/README.md) |

### 7.2 Web Tools

| Tool | Function |
|------|----------|
| **JSON → TOON converter** | Browser-based conversion  [toontools](https://www.toontools.app/benchmarks) |
| **TOON → JSON converter** | Reverse conversion  [toontools](https://www.toontools.app/benchmarks) |
| **CSV Converter** | CSV ↔ TOON  [toontools](https://www.toontools.app/benchmarks) |
| **YAML Converter** | YAML ↔ TOON  [toontools](https://www.toontools.app/benchmarks) |
| **Interactive playground** | Real-time token count visualization  [github](https://github.com/toon-format/spec) |
| **ToonParse** | Client-side conversion (no server send)  [github](https://github.com/toon-format/spec) |

All web tools run client-side for privacy. [github](https://github.com/toon-format/spec)

***

## 8. Advantages Summary

| Advantage | Impact |
|-----------|--------|
| **Token Efficiency** | 30–60% reduction → lower API costs, more context window space  [github](https://github.com/toon-format/spec) |
| **Higher Accuracy** | Schema-aware guardrails reduce LLM hallucinations/errors  [github](https://github.com/toon-format/spec) |
| **Human Readability** | Debug-friendly with indentation and clear syntax  [github](https://github.com/toon-format/spec) |
| **Zero Data Loss** | Lossless JSON round-trip  [github](https://github.com/toon-format/spec) |
| **Cross-Language** | Implementations in TypeScript, Elixir, PHP, R, Python  [github](https://github.com/toon-format/spec) |

***

## 9. Caveats & Limitations

### 9.1 LLM Training Gap
Most LLMs **were not explicitly trained on TOON** — training data consists almost entirely of JSON. This means:
- Models may require adaptation/few-shot prompting [reddit](https://www.reddit.com/r/aipromptprogramming/comments/1p2u24n/json_is_killing_your_llm_token_budgetmeet_toon/)
- Some models may respond less optimally initially [github](https://github.com/toon-format/spec)

### 9.2 Specification Fluidity
- TOON is still **relatively new** (spec v3.0 working draft as of Nov 2025) [github](https://github.com/toon-format/spec)
- Specification is **in flux** — implementations may not be fully compatible unless matching spec version [github](https://github.com/toon-format/spec)

### 9.3 Mixed Benchmark Results
Independent tests show:
- TOON performed **worse than markdown tables** for nested data retrieval with GPT-5 nano [improvingagents](https://www.improvingagents.com/blog/toon-benchmarks)
- No circumstances found where TOON was the **best-performing format** in some tests [improvingagents](https://www.improvingagents.com/blog/toon-benchmarks)
- Difference vs CSV was **not statistically significant** for some tasks [improvingagents](https://www.improvingagents.com/blog/toon-benchmarks)

***

## 10. Practical Example: Before & After

### Input (JSON) — 15,145 tokens
```json
{
  "articles": [
    { "id": 1, "title": "AI Trends", "author": "John", "views": 1500 },
    { "id": 2, "title": "ML Basics", "author": "Jane", "views": 2300 },
    { "id": 3, "title": "Deep Learning", "author": "John", "views": 3100 }
  ]
}
```

### Output (TOON) — 8,745 tokens (**42% reduction**)
```toon
articles [toonformat](https://toonformat.dev){id,title,author,views}:
1,AI Trends,John,1500
2,ML Basics,Jane,2300
3,Deep Learning,John,3100
```


***

## 11. Roadmap & Future Development

| Item | Status |
|------|--------|
| **Spec v3.0 stabilization** | Working Draft (Nov 2025)  [github](https://github.com/toon-format/spec) |
| **More language implementations** | Active open-source development  [github](https://github.com/toon-format/spec) |
| **API integrations** | Openapi.it announcing TOON support in coming weeks  [github](https://github.com/toon-format/spec) |
| **Spring AI support** | Issue #4869 opened for TOON addition  [github](https://github.com/spring-projects/spring-ai/issues/4869) |
| **Benchmarks expansion** | More dataset patterns being tested  [linkedin](https://www.linkedin.com/posts/ranjithsrajan_github-toon-formattoon-token-oriented-activity-7394624263695216640-g8Fb) |

***

## 12. Quick Reference Cheat Sheet

| Construct | TOON Syntax | JSON Equivalent |
|-----------|-------------|-----------------|
| Simple object | `key: value` | `{ "key": "value" }` |
| Nested object | Indentation (2 spaces) | Nested `{}` |
| Primitive array | `name [toonformat](https://toonformat.dev): a,b,c` | `["a", "b", "c"]` |
| Uniform array | `name [linkedin](https://www.linkedin.com/posts/ranjithsrajan_github-toon-formattoon-token-oriented-activity-7394624263695216640-g8Fb){f1,f2}: v1,v2\nv3,v4` | `[{f1:v1,f2:v2}, {f1:v3,f2:v4}]` |
| Boolean | `true` / `false` | `true` / `false` |
| Null | `null` | `null` |
| Empty array | `name[0]:` | `[]` |
| Empty object | `name:` | `{}` |

***

## 13. Conclusion

TOON is a **complement to JSON**, not a universal replacement. It excels when:
- You have **uniform arrays of objects** (database exports, analytics, API responses)
- **Token costs matter** (billed LLM APIs)
- You need **schema-aware guardrails** for better LLM comprehension

For highly nested, non-uniform, or latency-critical use cases, **compact JSON or CSV** may be better. Always measure benefits for your specific use case. [reddit](https://www.reddit.com/r/aipromptprogramming/comments/1p2u24n/json_is_killing_your_llm_token_budgetmeet_toon/)

***

### Key Sources
- Official specification: `github.com/toon-format/spec` (v3.0) [github](https://github.com/toon-format/spec)
- Benchmarks & tools: `toontools.app/benchmarks` [toontools](https://www.toontools.app/benchmarks)
- Official website: `toonformat.dev` [toonformat](https://toonformat.dev)
- Original article: Openapi.com blog [github](https://github.com/toon-format/spec)