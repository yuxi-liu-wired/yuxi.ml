---
title: "Research ideas"
author: "Yuxi Liu"
date: "2024-06-11"
date-modified: "2024-06-11"
categories: [fun]
format:
  html:
    code-fold: true
    toc: true
    resources:
        - "figure/**"
description: "Ideas for research. Free for a good home."

# image: "figure/banner.png"
status: "draft"
confidence: "log"
importance: 3
---

{{< include ../../../static/_macros.tex >}}

## Statistics

### Correlation gradient ascends to causation

The idea is that by gradient-ascending correlation, we would eventually arrive at a high-correlation pair of variables, which should be quite causally related. Naively, this is false. If the basic structure is a complex causal diagram, then a local maximum for $\argmax_Y R_{XY}$ might be where $Y$ is far downstream of $X$, and connected by many weak paths.

However, there was a case-report that it works in biochemistry, where the following sequence was used to discover how to chemically induce meiosis ([*Meiosis is all you need*, Metacelsus 2022](https://denovo.substack.com/p/meiosis-is-all-you-need)):

1. Take a diploid cell line (probably ESC or iPSC or PGCLC)
2. Induce meiosis and form many haploid cell lines.
3. Genotype the haploid lines and select the best ones.
4. Fuse two haploid cells to re-generate a diploid cell line.
5. Repeat as desired. At the end, either differentiate the cells into oocytes or perform nuclear transfer into a donor oocyte.

What I think *might* work out is if we find $X, Y$ such that $\nabla_X r_{X,Y} = 0$ and $\nabla_Y r_{X,Y} = 0$, where the gradient $\nabla$ does not literally mean $d/dx$, but rather, what happens if we move from $X$ to an adjacent variable. However, what is "adjacent"? We can't say that "adjacent" means "directly connected on the causal graph" because if we know the causal graph, then our problem is solved!

## AI

### RL

<https://x.com/layer07_yuxi/status/1914932954863952249>

### Compression

The pure algorithmic compression approach intelligence: one of the things to look out for.
It might sound too elegant to be true *in practice* (it is true in theory, of course), but probably deserves at least 1% of total AI funding/effort.

[Compression Represents Intelligence Linearly (2024)](https://arxiv.org/abs/2404.09937)

https://iliao2345.github.io/blog_posts/arc_agi_without_pretraining/arc_agi_without_pretraining.html

Boolean-gate RNN wins the Hutter Prize.

Last year we tried winning it with an LLM arithmetic encoder-decoder architecture, but then realized that to get the total filesize (including the LLM) to be <110 MB, we'd need a tiny LM (< 50MB, or about <50M 8-bit parameters), not a large LM.
Perhaps this can work:
1. Take a pretrained frontier-quality big RNN. Finetune it on English Wikipedia.
2. Distill it down to a tiny RNN. Maybe do it in stages: big -> medium -> small -> tiny.
3. Distill it down to a sparse boolean-gate neural network.
~100 million gates would just cost 10MB, which seems within the realm of plausibility. (Pintadosi etc, 2019) estimated that 1.5 MB is enough for syntax, grammar, and semantics.

Simply using negative log-likelihood (NLL) on a fresh batch of Internet text could be used as an "uncheatable eval" for base models. 

https://github.com/Jellyfish042/uncheatable_eval

Gwern suggested that even for chatbot models, NLL can be estimated by the Shannon "guess the next word" test, which Shannon tested on biohumans in the 1950s (the original chatbots). The lower the resulting estimated text entropy is, the better the chatbot is.

https://old.reddit.com/r/mlscaling/comments/1ju1q2e/compression_represents_intelligence_linearly/


### search-aware training

When one does "tree of thought" with an LLM, such as Llama 3, because the LLM was "unaware" that it would be used in tree searches in test-time, it would not behave as well as possible. This is a case of train-test mismatch. If during training it was also used in tree searches, it should do much better during test-time tree search.

Intuition for the mismatch: If an LLM is trained to just predict the next token on only the training corpus, then it would have difficulty planning over multiple rollouts, because it has only ever played one-rollout games of language-generation.

Sometimes it is very valuable to go through many  rollouts being wrong just to gather learn exactly why they are wrong, so that one can avoid them. But an LLM trained to do one-rollout language-generation would be trained to not do that. They are "YOLO" (you only language once) in that sense. YOLO leads to conservation and exploitation, not exploration.

Note: It may still learn multi-rollout by a "[side-channel attack](https://en.wikipedia.org/wiki/Side-channel_attack)", like how they managed to learn to spell despite using tokenizers ([*Models In a Spelling Bee: Language Models Implicitly Learn the Character Composition of Tokens*](https://arxiv.org/abs/2108.11193)), by using some implicit cryptoanalysis to break the [substitution cipher](https://en.wikipedia.org/wiki/Substitution_cipher) of tokenizers, but that's obviously very inefficient.


### Formalizing 'bitterhart'

benchmart (v.): to "shop" for the best benchmarks to make your model look good.

"Rumours abound that the company's flagship model was heavily benchmarted for the investor demo."

"Is Benchmarting the New P-Hacking? A Call for Greater Transparency in AI Evaluation."

And yet...

1. The benchmark-oriented training is prone to Goodharting.
2. Yet, by simply drawing a clear goal to shoot at, it motivated the researchers so much that
3. AI still progressed faster than without Goodharting.

I call this strange coexistence of Goodhart and the Bitter Lesson the "bitterhart". It is bitter, because Goodharting is generally considered very bad, and yet, without the benchmarks, where would AI be? We would be stuck with many beautiful theoretical constructs and no way to tell which one is right.

Is there a way to make this insight formal? How to measure Goodharting? Some possible starting points: 

## Biology

Solving the "humans cause 6 species to go extinct per day" problem by making new species.

For example, Lake Malawi cichlids differ by ~2.5 mbp. Current price of CRISPR is ~0.1 USD/bp, so each species costs ~0.25 million USD. Thus, halting anthropogenic extinction would cost just ~0.5 billion USD/yr. indeed, with 1 billion USD/yr, the number of species on earth can grow at a rate 10000x that of the natural baseline.

In general, any clade that,

* Contains many species
* Well-known, uniform genetic architecture
* Speciation mechanism well-understood, localized, and combinatorial.

is a good candidate for scalable species generation. Examples include cichlid, drosophila, bumbus, etc.

This can be an SCP organization: Nephilim Initiative (NI), with the motto: "Secunda Hebdomas Geneseos" \[The second week of creation\].

## Unsorted

A "robot arm of the long now". It stacks one block every century. In 10000 years, it finishes building a pyramid. This should be a greater challenge than the "clock of the long now".

> My spy-glass showed it to me with clearness—a living hill of watchfulness, known to us as The Watcher Of The South. It brooded there, squat and tremendous, hunched over the pale radiance of the Glowing Dome.  Much, I know, had been writ concerning this Odd, Vast Watcher; for it had grown out of the blackness of the South Unknown Lands a million years gone. ... A million years gone, as I have told, came it out from the blackness of the South, and grew steadily nearer through twenty thousand years; but so slow that in no one year could a man perceive that it had moved.
>
> --- William Hope Hodgson, [*The Night Land*](https://gutenberg.org/cache/epub/10662/pg10662-images.html) (1912)