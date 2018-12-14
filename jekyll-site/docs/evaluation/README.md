---
layout: docs
title: Evaluation
permalink: /docs/evaluation/
---

# Evaluation h1
## Evaluation h2
### Evaluation h3
#### Evaluation h4
##### Evaluation h5
###### Evaluation h6

Lorem ipsum dolor sit amet, [consectetur adipiscing](#) elit. Nam lacinia auctor nunc, in commodo ante faucibus ut. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nunc vel neque ut nisi sodales aliquet. Ut nunc velit, feugiat et elit eget, lobortis sodales est. Integer turpis tellus, semper nec neque ut, elementum mollis metus. Ut `faucibus lorem` felis porta lorem vehicula accumsan. Duis sed tempor enim, ac porttitor mi. Maecenas non sollicitudin quam. Nam mollis scelerisque sapien eu viverra. Etiam tempor bibendum eros, a faucibus tellus ullamcorper a. Aliquam id lorem est. Vivamus in ipsum condimentum, vulputate nisl et, rutrum tellus.

- item 1
- item 2
- item 3
- item 4

```kotlin:ank
val idj = IdJ(1)

val id: Kind2<ForConvert, ForIdJ, A> = idj.fromKindedJ()
.attempt().unsafeRunSync()
```

```kotlin:ank:silent
// Exception Style

fun parse(s: String): Int =
    if (s.matches(Regex("-?[0-9]+"))) s.toInt()
    else throw NumberFormatException("$s is not a valid integer.")

fun reciprocal(i: Int): Double =
    if (i == 0) throw IllegalArgumentException("Cannot take reciprocal of 0.")
    else 1.0 / i

fun stringify(d: Double): String = d.toString()
```