---
title: "Notes on Web Design"
author: "Yuxi Liu"
date: "2023-12-10"
date-modified: "2023-12-10"
categories: [programming]

format:
  html:
    toc: true
description: "My quick reference for designing content for the Internet."
# image: "figure/banner_1.png"

status: "wip"
confidence: "log"
importance: 4
---

General references:

* [The 2022 Web Almanac](https://almanac.httparchive.org/en/2022/)
* [MDN Web Docs](https://developer.mozilla.org/en-US/)

## HTML

HTML (HyperText Markup Language) is the standard markup language for creating web pages.

HTML was created by Tim Berners-Lee in 1989. The key metaphor for HTML is the "editing markup", as follows: Back in the old days, authors would write or typewrite their document in the exact same font, from the first word to the last word. Then the document is sent to an editor, who would edit it by *marking up* the words, such as drawing squiggly lines, crossing things out, changing their font size, and writing other instructions for the type-setter (which back then meant someone who would take out types from a box and set them into the right ordering for the printing press).

So, one should think of an HTML document as starting with a plaintext of exactly the same format, from the first to the last word, then adding marks upon it.

### `<!DOCTYPE>`

The `<!DOCTYPE>` tag is used to declare the document type. It is usually like `<!DOCTYPE html>`, although there are rare variants, where instead of `html`, we have `html -//w3c//dtd xhtml 1.0 transitional//en http://www.w3.org/tr/xhtml1/dtd/xhtml1-transitional.dtd`, `html -//w3c//dtd xhtml 1.0 strict//en http://www.w3.org/tr/xhtml1/dtd/xhtml1-strict.dtd`, etc.

Well, if you don't care much for the details, use `<!DOCTYPE html>` is always fine. If you do care, read on.

The `xhtml` thing came from early 2000s, where there was a movement to `XML`-everything. Instead of the poorly specified `HTML`, there would be `XHTML`, which can be checked for syntax, and compiled into an abstract syntax tree. Despite this, people just kept on using `HTML` and ignored `XHTML`.

Despite the universal ambitions of `XML`, it is now in the land of old soldiers, who never die, but just fade away.
* The `SVG` vector graphics format.
* `MathML`, which is like `LaTeX` but in `XML`.
* The `RSS` and `Atom` feeds, which... unfortunately, are also mostly legacy now. Who even use these nowadays?
* The acronym `AJAX`, which stands for **Asynchronous JavaScript and ~~XML~~ JSON**. After looking at `XML` and `JSON`, I am quite glad this replacement happened.

### Semantic markup

Use `<article>` to surround a block of article. There can be any number of articles in a single `HTML` file.

The `id` of tags must be unique within each `HTML` file.

### Tips for fast loading

Use `<img decoding="async" loading="lazy" ...>` for images, to allow the rest of the page to load before the images are loaded. To avoid [Cumulative Layout Shift (CLS)](https://web.dev/articles/cls), I think something like 

```css
img {
  max-width: 100%;
  height: auto;
}
```

<!-- ### `<meta>`

## CSS 

## JavaScript -->

## Punctuation

### Comma

The comma separates parts with equal syntax roles.

```text
Equal noun-phrases.
  I have 3 trees in my backyard: a jujube tree, a jujube tree, and a peach tree.

Equal adjectives.
  He is a strong, healthy man.

Adjectives at unequal levels.
* We stayed at an expensive, summer resort.
  We stayed at an {expensive {summer resort}}.
```

They denote typed multisets.

```text
They are typed multisets, as in:
I have 3 trees in my backyard: a jujube tree, a jujube tree, and a peach tree.
=>
I have {(jujube tree, 2), (peach tree, 1)} in my backyard.

They are not typed sets, because:
I have 3 trees in my backyard: a jujube tree, a jujube tree, and a peach tree.
=/=>
I have {jujube tree, peach tree} in my backyard.

They are not typed lists, because:
I have 3 trees in my backyard: a jujube tree, a jujube tree, and a peach tree.
=
I have 3 trees in my backyard: a jujube tree, a peach tree, and a jujube tree.
but
(jujube tree, jujube tree, peach tree) =/= (jujube tree, peach tree, jujube tree)

They are not untyped multisets, because:
* I have in my backyard a jujube tree and sing.
  Backyard = {(jujube tree, 1), (sing, 1)}
```

The "and" before the last item on the list seems to be necessary in speech, as in "Heads up! The list is about to be over!", even though it is not necessary in writing.


The "Oxford comma" is a rather odd hack that allows a tiny amount of nesting. In fact, English does not have recursion, and 2 seems to be the deepest nesting we can get. [According to Wikipedia](https://en.wikipedia.org/wiki/Serial_comma#Arguments_for_and_against), the most common arguments for/against the Oxford comma are: convention, disambiguation. As for convention, it cannot be argued with, only dealt with. As for disambiguation, I recommend using brackets.[^oxford-comma-rant]

[^oxford-comma-rant]: It seems like a lot of weird English syntax is centered around an abhorrence of brackets. Like, I understand why brackets can get annoying (as anyone can see by looking at LISP code), but there is no reason to avoid brackets when you really need to disambiguate something. For example, instead of requiring the Oxford comma, why not just put in a freaking bracket? Don't say that "oh you can't speak brackets" like damn you you can't speak commas either!

```text
No Oxford comma:
To my parents, Ayn Rand and God.
To my mother, Ayn Rand, and God.

Oxford comma:
To my parents, Ayn Rand, and God.
To my mother, Ayn Rand and God.

Mathematics:
To {my parents, Ayn Rand, God}.
To {my mother Ayn Rand, God}.
To {my mother, Ayn Rand, God}.
```

For clauses, commas are weird. There is no clear rule.

```text
Equal clauses.
  He walked all the way home, and he shut the door.

Equal clauses, though the second lost the pronoun.
  I saw that she was busy, and [I] prepared to leave.

Dependent clause (except that-clause).
  Because I could not stop for Death, He kindly stopped for me.

No comma between that-clause and main-clause, or vice versa.
* We paused before a House, that seemed a swelling of the Ground
  We paused before a House that seemed a swelling of the Ground
* That is not dead, which can eternal lie.
  That is not dead which can eternal lie.
```

A pair of commas can replace a pair of parentheses, though there is no benefit, other than avoiding the wrath of English teachers.

A comma, like an em-dash `---`, can indicate pauses and stutters in quotations, such as "Daisy, Daisy... give me---e--- your, ans, ser, do...". This is an edge case and there are no fixed rules here. If you ever have to write something like this, use your imagination.

### Quotation

English quotation standards are extremely annoying, because while theoretically quotation is meant to be verbatim, it is anything but. I recommend verbatim quotation. It is consistent with usage in computer programming and formal logic. In particular, the English quotation method would be a syntax error in computer programming, and would also break the proofs of Gödel's incompleteness theorems, which use the [Quine quotation](https://en.wikipedia.org/wiki/Quasi-quotation).

For nested quotations, alternate between double `"` and single `'` quotation marks. In other words, inside a level-$n$ writing, use `"` if $n \equiv 0\mod 2$, and `'` otherwise. It is context-free, and its quotient by `{" ~ '}` is the [Dyck language](https://en.wikipedia.org/wiki/Dyck_language).

However, if you need to pass the Turing test, then study carefully the following edge cases:

```
* Did Hal say "Good morning, Dave."?
  Did Hal say, "Good morning, Dave"?

* No, he said "Where are you, Dave?".
  No, he said, "Where are you, Dave?"

  To be perfectly exact, I heard "Wh--- are you, Da---".

* "cat" is in lowercase.
* "Cat" is in lowercase.
* "Cat" is in uppercase.
  "Cat" is capitalized.
* In lowercase "cat" is.
* "cat" is in lowercase, while "CAT" is in uppercase.
  "CAT" is in uppercase, while "cat" is in lowercase.
  What we cannot speak about we must pass over in silence.

* "sed" ("stream editor") is a Unix utility that parses and transforms text.
* "Sed" ("stream editor") is a Unix utility that parses and transforms text.
  The Unix utility "sed" parses and transforms text.
```

The two senses of verbatim (verbatim verbal speech, verbatim written text) are inconsistent with the capitalization constraint:

```
This violates "first letter capitalization".
* "... 'Vim' stands for 'vi improved'. 'sed' stands for 'stream editor'. ..." 

This violates "verbatim written text".
* "... 'Vim' stands for 'vi improved'. 'Sed' stands for 'stream editor'. ..."

This violates "verbatim verbal speech".
* "... 'Vim' stands for 'vi improved', whereas 'sed' stands for 'stream editor'. ..."

This violates the constraint of grammar.
* "... 'Vim' stands for 'vi improved', 'sed' stands for 'stream editor'. ..."

This works, but only by a dubious insertion.
  "... 'Vim' stands for 'vi improved'[, whereas] 'sed' stands for 'stream editor'. ..."

This works, but just barely.
  "... 'Vim' stands for 'vi improved'; 'sed' stands for 'stream editor'. ..."

It would not work if the two sentences are not "closely related".
* "... The Unix coreutils were written mostly in the 1970s; 'sed',
       which stands for 'stream editor', was written by Lee McMahon in 1973. ..."
```

### Whitespace

For most cases, the single whitespace works.

` ` (U+00A0 [no-break space]{.smallcaps}) says: "Do not break line here.". Similarly for `&NoBreak;` (U+2060 [word joiner]{.smallcaps}). The opposite is `<wbr>` (U+200B [zero width space]{.smallcaps}), which says: "You can break line here.".

` ` (U+2007 [figure space]{.smallcaps}), ` ` (U+2008 [punctuation space]{.smallcaps}), are only for numerical tabulations, to ensure alignment across rows.

The thin space and hair space are not used except by fastidious typographers.

### Connecting words

Use `-` to connect two non-equal parts into a compound noun-phrase, except when one of the parts is an open compound, in which case, use `--`.

Use `--` to connect two equal parts into a compound noun-phrase.

> `pre-WWII, pre--World War Two, ex--Prime Minister, water-based solution, non--water-based solution, the anti-choice--anti-life debate`

### Interruptions

Use em-dash `---` without spacing.

> `I---no, YOU son of a---`
>
> `---and as I was saying---`

### Deletions

To cut out letters or words by redaction, use the em-dash `---`. Imagine that you wrote out the text normally, then you replace the section to be redacted with a single `---`, and in this way you will find the right spacing. However, I recommend the black block character `█`, which looks just like real redactions on secret documents.

> `That f--- son of a b███!`

The ellipsis symbol can be done either with `...` or with a single `…` (U+2026 [horizontal ellipsis]{.smallcaps}). It is used with spacing on both ends, except that there is no space between it and the quotation mark.

> `"Consider this ... , and no more ... be said. ... and so on and so forth ...", said Mr. ---.`

### Arithmetics

If you cannot use LaTeX, then you could use the hyphen `-` for minus sign, though it's more correct to use `−`. Similarly, the letter `x` can work, though `×` is better.

