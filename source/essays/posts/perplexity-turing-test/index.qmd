---
title: "Predicting AGI by the Turing Test"

author: "Yuxi Liu"
date: "2024-01-20"
date-modified: "2025-02-25"
categories: [AI, scaling, math]
format:
  html:
    toc: true
description: "Minimizing log-perplexity loss is equivalent to maximizing survival length in a Turing test. Assuming compute-loss scaling law, a scaled-up GPT that produces human-like science papers would cost ~200 years of global GDP."

image: "figure/banner_4_edit.png"
image-alt: "An abstract representation of the Turing test. On the left is a dark city of obelisks over a bright background, and on the right is the same thing, mirrored and inverted, but with subtle differences due to the randomness of the art generator. It represents the abstract idea of the Turing test: duality, subtle differences, same contours, and complex object made of simple parts. High contrast, monochromatic, minimalistic, in the style of vector svg art."

status: "finished"
confidence: "possible"
importance: 10
---

{{< include ../../../static/_macros.tex >}}

## Abstract

This essay explains *the Direct Approach* proposed by [@barnettScalingTransformativeAutoregressive2023].[^direct-approach-report] I encourage you to play with the [*Direct Approach Interactive Model*](https://epochai.org/blog/direct-approach-interactive-model) to explore an interactive simulation using the approach.

> The Direct Approach framework bounds the compute requirements for transformative AI by extrapolating neural scaling laws. We combine those estimates with simple models of future progress in algorithms, investment, and compute costs to produce a user-adjustable forecast over the date at which TAI will be achieved. [@barnettDirectApproach2023]

[^direct-approach-report]: The thing is released in a scattered way, typical for an internet-native publication. There is the report [@barnettScalingTransformativeAutoregressive2023], in the form of a paper -- clearly meant to be cited, despite being hard to read. There is the website [@barnettDirectApproach2023], in the form of a blog post -- clearly meant to be read, despite not being upper-class enough to be cited in journal papers. Finally there is the [interactive model](https://epochai.org/blog/direct-approach-interactive-model) which looks like an optional add-on to the blog post.

From the POV of the judge, a Turing test is a sequential test for two statistical hypotheses -- "is human" and "is machine". Under reasonable assumptions, halving the (reducible part of) log-perplexity loss of the language model would double the time it can survive in a Turing test. 

We can think of the peer-review of scientific papers as a Turing test, and say that AGI has arrived when we have AI scientists that can pass the papers peer-review. This allows us to calculate the log-perplexity loss of the first AGI. If we assume it is just a scaled-up GPT, then assuming the Chinchilla scaling law, [it would cost about 200 years of global GDP](#sec-forecasting-agi). This makes it virtually certain that the first AGI will not be a scaled-up GPT.

## Turing test as statistical hypothesis test

### Turing test

In the [Turing test](https://en.wikipedia.org/wiki/Turing_test), there are three players: one judge and two players. The first player is a human, and the second is a machine. The judge asks each player text questions and receives text answers. The judge must decide who is the human.

We consider a simplified Turing test. In this test, the judge does not ask, and simply receives *one* stream of text $X_{1:\infty}$. The judge must decide whether the stream is produced by the human or the machine, and do so quickly.

Cast in the language of statistical hypothesis testing, we have two hypotheses:

* $H_0$: "the stream is produced by the human";
* $H_1$: "the stream is produced by the machine".

The judge would read from the stream $X_{1:\infty}$, `o-n-e- -t-o-k-e-n` at a time, and at each token, decide whether to take another one, or announce its judgment: $H_0$ or $H_1$.

As the organizers of the Turing test, we would start the test by flipping a fair coin to decide whether to use the human or the machine. Therefore, $Pr(H_0) = Pr(H_1)$, and by Bayes, the posterior log-probability ratio is 

$$
\ln\frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)} = \ln\frac{Pr(H_0|X_{1:n})}{Pr(H_1|X_{1:n})}
$$

This allows us to use the [sequential probability ratio test](https://en.wikipedia.org/wiki/Sequential_probability_ratio_test) (SPRT). The judge would decide on two decision boundaries, and calculate $\ln\frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)}$ at each token. It would stop and announce the decision as soon as the quantity exceeds one of the boundaries. 

For example, suppose the judge wants to decide when the odds ratio is 10 to 1, then it would set the decision boundaries to be $[-\ln 10, + \ln 10]$. If $\ln\frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)}$ goes above $+\ln 10$ when $n = 60$, then the judge would announce "$H_0$" at that point.

The $\ln 10$ is a good rule of thumb, which we will use for the remainder of the essay.

### Sequential hypothesis testing

Consider the following simple equation:

$$
\ub{\frac 1n \E_{X \sim Pr(\cdot | H_0)}\left[ \ln\frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)}\right]}{$\frac 1n D_{KL}(Pr(\cdot | H_0)\| Pr(\cdot | H_1))$} = \ub{\frac 1n 
\E_{X \sim Pr(\cdot | H_0)}\lrs{\ln\frac{1}{Pr(X_{1:n}|H_1)}}}{negative log-likelihood loss per token} - \ub{\frac 1n  \E_{X \sim Pr(\cdot | H_0)}\lrs{\frac{1}{\ln Pr(X_{1:n}|H_0)}}}{entropy rate of the human itself}
$${#eq-sprt}

The first term is the KL-divergence per token between the machine and the human. Roughly speaking, it is how different they are, per token emitted. It is an information-theoretic quantity.

The second term is negative log-likelihood loss per token. This is what language models are trained to minimize. We write it as $L$.

The third term is the entropy rate of the human. It is how random the human is. We write it as $L_\infty$, because it is the theoretical minimal loss that the language model can reach.

If the machine is a perfect replica of the human, then the second term is zero, and the first term equals the third term.

Assuming that the human is an ergodic speakers of English,[^ergodic-speaker] we can sample an infinite stream $X_{1:\infty}$ from the human, then call up the [Shannon--McMillan--Breiman theorem](#sec-smb-theorem) and find that

[^ergodic-speaker]:
    In short, an ergodic speaker is someone who has only one speech. If you hear it speak once for a very long time, then hear it speak again for a very long time, then you can take the first and shift it around, so that it looks like the second over a very long sub-segment. Ergodic speakers allow you to take the average over a single very long speech, and be assured that it is close to the average over all possible speeches.
    
    In long, see [the appendix on ergodic theory](#sec-ergodic-theory).

$$
\frac 1n \ln\frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)} \to L - L_\infty
$$

On the other hand, if the machine is also an ergodic speaker of English, then we can sample an infinite stream $X_{1:\infty}$ from the machine, then call up the SMB theorem and find that

$$
\frac 1n \ln\frac{Pr(X_{1:n}|H_1)}{Pr(X_{1:n}|H_0)} \to L' - L_\infty'
$$

where unfortunately, we have the odd $L'$ and $L_\infty'$, defined by

$$
L' := \lim_n \frac 1n 
\E_{X \sim Pr(\cdot | H_1)}\lrs{\ln\frac{1}{Pr(X_{1:n}|H_0)}}, \quad L_\infty' := \lim_n \frac 1n 
\E_{X \sim Pr(\cdot | H_1)}\lrs{\ln\frac{1}{Pr(X_{1:n}|H_1)}}
$$

We can interpret them as the loss of the human at imitating the machine, and the entropy rate of the machine itself. When the machine is close enough to the human, we can take the approximation $L' \approx L,  L_\infty' \approx L_\infty$.

Now, define the log-ratio at step $n$ to be $r_n := \frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)}$. During a Turing test, the judge calculates

$$
\begin{aligned}
r_0 &= 1 \\
r_1 &= r_0 + \frac{Pr(X_{1:1}|H_0)}{Pr(X_{1:1}|H_1)} \\
r_2 &= r_1 + \frac{Pr(X_{1:2}|X_{1:1}, H_0)}{Pr(X_{1:2}|X_{1:1}, H_1)} \\
&\cdots
\end{aligned}
$$

So, imagine that such a perfect judge is going through a Turing test, upon receiving "my cat is technically", and we are listening on its thoughts:

* "If it were a human, then it would start with 'my' with probability $0.01$. If it were a machine, then $0.05$. Therefore, the odds ratio is 2 to 1."
* "If it were a human, then it would follow 'my' with 'cat' with probability $0.01$. If it were a machine, then $0.033$. Therefore, the odds ratio is 3 to 1."
* "If it were a human, then it would follow 'is' with 'my cat' with probability... I do not know. However, I do know that the odds *ratio* is 2 to 1. Now that the total odds ratio is 12 to 1, I can decide: $H_0$."

We see that the judge does not have to know the probabilities $Pr(X_{1:n}|H_0)$ and $Pr(X_{1:n}|H_1)$, only their *ratio*. This might be a minor point, but this idea of likelihood ratio is quite important. It is like "I don't know how often you say 'cat' but I know that you say it twice as often than I do!".

Let $T^*$ be the time it takes for the judge to decide.

$$T^* \approx \frac{\ln 10}{L - L_\infty}$$

Intuitively, each token *on average* moves the log-probability-ratio away from 0 by another $(L-L_\infty)$. Decision is triggered when it finally moves out of the interval $[-\ln 10, +\ln 10]$.

We are not able to simply look at a few tokens, draw a straight line, and call it a day, because the trajectory of log-probability-ratio is much closer to a random walk with drift. Subjectively, if you were a judge and watching the log-probability-ratio moving, you'd see ups and downs, keeping you in suspense, until it finally crosses the decision boundaries.

### Slowdown factor

To perform the SPRT as described, the judge must know intimately the difference between a human and a machine. Can the judge do that? Can anyone know, with certainty, that I would start my speech with "Forty cats ..." with a probability that is *exactly* 32.42 times that of GPT-3?

As a crude approximation, we can model real-world judges as slowed-down version of the perfect judge. We can imagine that at each step, instead of updating the log-ratio by 

$$
\ln r_{n+1} \leftarrow \ln r_n + \ln \frac{Pr(X_{n+1}|H_0, X_{1:n})}{Pr(X_{n+1}|H_1, X_{1:n})}
$$

we update it by 

$$
\ln r_{n+1} \leftarrow \ln r_n + \frac 1s \ln \frac{Pr(X_{n+1}|H_0, X_{1:n})}{Pr(X_{n+1}|H_1, X_{1:n})}
$$

where $s > 1$ is the **slowdown factor**. This implies that if it takes $\sim T$ tokens for the perfect judge to reach a likelihood ratio of $r$, it would take $\sim sT$ tokens for a human judge. 

### Measuring the slowdown factor

The slowdown factor $s$ is unknown.

> Informed by an internal poll, we enforce a lognormal distribution with a median of 53.1, a 15th percentile estimate of 9.84, and an 85th percentile of 290. [@atkinsonDirectApproachInteractive2023]

The original paper [@barnettScalingTransformativeAutoregressive2023] contains no estimate of $s$. They did propose to measure it experimentally by running the Turing test with a human judge and two language models. One model $H_0$ "perfectly imitates humans" by simply sampling a random text segment from a corpus, and the other model $H_1$ is a trained language model, finetuned to imitate the same corpus. They claimed that for any piece of text $X_{1:n}$, they can calculate the log-ratio $\ln\frac{Pr(X_{1:n}|H_0)}{Pr(X_{1:n}|H_1)}$, but I found it difficult: Suppose $X_{1:n} = \text{ technically fork}$, which is unlikely but possible, yet the phrase never appears in the corpus, what should be $Pr(X_{1:n}|H_0)$? We can use one of the many smoothing tricks [@jurafskySpeechLanguageProcessing2023, chapter 3], but this gets complicated.

#### My ideas

What I think would work well is if both $H_0$and $H_1$ are language models, perhaps even the same model with different sampling temperatures, then the human judge only has to distinguish the two models.

Perhaps we can make this into a gambling game. The human subject would be presented with two long outputs from two hidden Markov models. Then the subject becomes the judge of a Turing test: "Are you seeing the output from machine 0 or machine 1?". At each step, the subject can either pay a few cents of fake money to see another character, or stop and make a bet with the entire bankroll: "I bet 70\% of my bankroll on machine 0 and the rest on machine 1!". Both bets have payoff odds of $2:1$. I believe that if the cost of seeing another character is *just right*, the subject would be nudged to make a decision at exactly $10:1$ posterior odds ratio on the two hypotheses "machine 0" and "machine 1".

A diffusion guessing game: The user uploads a lot of MIDI musics. The program plays back note by note, but adds increasingly severe distortions (add a gaussian or Poisson noise to each note). The user guesses which music it is. The more noise there is, the longer it should take the user to guess. Compare the length with the Bayesian optimal predictor.

#### Human-or-not

There was one large-scale attempt at the Turing test in early 2023, in a game called "Human or Not?" [@jannaiHumanNotGamified2023]. Human participants took 2-minute conversations, and at the end, had to decide whether they were talking to a human or a bot.[^human-participant]

[^human-participant]: There was no mention of whether the bots had to decide the same question.

> The conversations have a “ping-pong” structure that prevents players from sending two consecutive messages without a response, in order to ensure a balanced and dynamic exchange. Each message, limited to a maximum of 100 characters, has to be composed and sent within a 20-second window, and the chat ends after 2 minutes, usually consisting of 4-5 messages from each side. This ensures that players don’t have to wait for too long, so they can remain engaged with the game and a constant suspense is kept. Once the conversation is over, players are prompted to guess whether their conversational partner was a fellow human or an AI bot. [@jannaiHumanNotGamified2023]

I counted that during a typical message, each side sends $[20, 40]$ English words in total, or $[30, 50]$ tokens. In $[60\%, 70\%]$ of trials, the human participant judged correctly. This suggests that the log-ratio achieved after $[30, 50]$ tokens is around the range of $[\pm \ln 6/4, \pm \ln 7/3]$. In other words, the average log-ratio per token is

$$
\frac{[\ln 6/4, \ln 7/3]}{[30, 50]} \in [0.01, 0.03] \;\rm{ nat/token}
$$

They used several different AI, ranging between Jurassic-2, GPT-4, and Cohere. None of them have published their training compute or loss curves. The only good estimate is for GPT-4, which has training cost $C = 2\times 10^{25}\rm{FLOP}$.

Assuming that [Chinchilla scaling](#eq-chinchilla-scaling) holds, average log-ratio per token that an ideal judge should achieve is $L - L_\infty = \frac{1070}{C^{0.154}} = 0.14 \;\rm{ nat/token}$. Therefore, 

$$s \in [5, 14]$$

I did not expect the estimate to be nearly symmetric around $10$.

## Entropy of natural languages

In @eq-sprt, we argued that $L_\infty$ *should* be interpreted as the entropy rate of the source, usually human-generated English. Unfortunately, unlike that of coin flips or Markov chains, the entropy rate of English cannot be calculated, only estimated. Fortunately, it can be estimated in several ways, and we can check their agreement.

Since tokenizers are temporary, but English is permanent, we convert all units to $\;\rm{bit/character}$ for easy comparison.

### Chinchilla scaling {#sec-chinchilla-scaling}

In the Chinchilla scaling law paper, the authors trained many language models with various sizes from a single architecture family, and fitted a statistical law to the data, giving $L_\infty = 1.69 \;\rm{ nat/token}$ (without error bars, unfortunately) [@hoffmannTrainingComputeOptimalLarge2022, page 25].

To find the effective $\;\rm{bit/character}$ for the Chinchilla scaling law, we need to convert $\rm{nat}$ to $\rm{bit}$, and $\rm{token}$ to $\rm{character}$. The first is easy: $1 \;\mathrm{bit} = \ln(2)\;\mathrm{nat}$. The second can be estimated by running a tokenizer over a large natural English corpus. I have estimated this by running the GPT-2 tokenizer on the [`WikiText-2`](https://paperswithcode.com/dataset/wikitext-2) corpus, and found that on average,

$$
1 \;\rm{token} = 4.5 \;\rm{character} = 0.85 \;\rm{word}
$$

Thus, $L_\infty \approx \frac{1.69}{4.5\times \ln 2} = 0.54 \;\rm{bit/character}$.

### Turing-completeness

Unfortunately, to lower-bound entropy rates, we typically have to make strong assumptions, because in general, lower-bounding entropy is not computable. For example, the entropy of $982148086513282306647093844\dots$ appears to be $\ln 10$, but it is in fact zero, because those are the digits of $10^{100} \pi$ starting at the radix point. In general, this means we have all the hairy problems of measuring the Kolmogorov complexity.

There is also another problem: Probabilistically speaking, there is no such thing as the entropy rate of a single sequence. We can convert a single sequence into a stochastic process, by, for example, sampling a random positive integer $n$, then start the sequence at the $n$-th place. The problem is that we really have two versions of the same word "entropy", one is by minimal description length, and another is by probability. The two versions are connected by Shannon coding theorem, but they are not the same.

This is similar to the Halting problem. It's possible in general to prove that a machine halts: just run it. It's not possible in general to prove that it does not halt. Similarly, there is a program $P$, such that given any input $x$, it will output a sequence of numbers $P(x)_1, P(x)_2, \dots$ that can converge to the Kolmogorov complexity *from above*: $P(x)_1 > P(x)_2 > \cdots, \lim_n P(x)_n = K(x)$. The program just runs every possible Turing machine in parallel.

There are two catches.

One, it is impossible to know in general whether $P(x)_n$ is the last time it will output, or whether if we wait a few more eternities, we will see another output $P(x)_{n+1}$.

Two, it is also impossible to have a program $P'$ that approaches it from below: $P(x)_1 < P(x)_2 < \cdots, \lim_n P(x)_n = K(x)$. Otherwise, we would have a machine that can calculate the Busy Beaver function.

[@feutrillReviewShannonDifferential2021] reviews the entropy rate formulas for several commonly used models. An ergodic Markov chain with stationary distribution $\pi_i$ and transition probabilities $p_{ij}$ has entropy rate $-\sum_{ij}\pi_i p_{ij}\ln p_{ij}$. For the hidden Markov model, there is no known closed-form formula in the transition probabilities, though there are upper and lower bounds [@coverElementsInformationTheory2006, Theorem 4.5.1].

### Guessing game

The earliest attempt to measure the entropy rate of English is by Shannon himself [@shannonPredictionEntropyPrinted1951]: $[0.6, 1.3] \;\rm{bit/character}$. He obtained the estimate by presenting human subjects $n-1$ characters from a text, and ask them to guess the next character repeatedly, until they got it right. In this case, the optimal strategy is to construct the $n$-gram table, and pick the argmax character for the given $(n-1)$-gram, then the arg-next-max, and so on.

Let $N$ be the total number of characters allowed -- Shannon's experiment used $N = 27$, with 26 lowercase letters and one white space. Let $p_k$ be the frequency that the subject makes exactly $k$ guesses -- including the correct guess, so that $\sum_{k=1}^N p_k = 1$. By convention, $p_{N+1} := 0$. Shannon derived both an upper and a lower bound for the entropy per character:

$$
\sum_{k=1}^N k(p_k - p_{k+1}) \ln k \leq H \leq - \sum_{k=1}^N p_k \ln p_k
$$

The upper bound is proved by [Shannon's source coding theorem](https://en.wikipedia.org/wiki/Shannon's_source_coding_theorem). Taking a human subject, copy it, then they can be used as an encoder-decoder pair.[^rng-human] The lower bound is not only tricky to prove, but also **wrong** in general. It is only correct when the human subject is *the optimal* $N$-gram predictor, *and* when the language *is* exactly generated by an $N$-gram model.[^wrong-shannon]

[@burtonLongrangeConstraintsStatistical1955] uses the same method as Shannon, but with longer contexts and texts from more books (Shannon sampled all passages from just one book). They found that English has "redundancy" in $[0.6, 0.8]$, meaning that English has entropy rate $\ln 27 \times (1- [0.6, 0.8]) = [0.7, 1.3] \;\rm{bit/character}$.

[^rng-human]: It still works even if the humans are pseudorandom. We just have to whisper the same <abbr title="Random Number Generator">RNG</abbr> seed into both humans' ears, and then they would behave in the same pseudorandom way.

[^wrong-shannon]:
    The simplest counterexample: Suppose the source is binary, and satisfies $X_{n+1} = X_{n} + 1 \mod 2$, so it has zero entropy. Nevertheless, the human intentionally guesses wrong the first time. Therefore, we have $p_2 = 1$, and we have violated the lower bound by $2\ln 2 > 0$.
    
    This source can be made ergodic by adding an $\epsilon$ amount of coin-flip noise: $X_{n+1} = X_{n} + 1 \mod 2$ with probability $1-\epsilon$. This would still give us $2\ln 2 + O(\epsilon) > O(\epsilon \ln \epsilon)$.

Over the years, others devised other methods to estimate this entropy. For example, [@coverConvergentGamblingEstimate1978] used a gambling game estimation, in the style of the [Kelly criterion](https://en.wikipedia.org/wiki/Kelly_criterion). Subjects were required to divide their entire bankroll into 27 differently-sized bets over 27 possibilities (26 letters and 1 whitespace). The right bet pays back 27-fold, and the other bets are lost. Let $S_n$ be the size of bankroll after $n$ rounds of betting, then

$$
H \leq \ln 27 - \limsup_n \frac 1n \ln S_n
$$

They found that $H \leq 1.3 \;\rm{bit/character}$.

The guesser does not have to be a human. It can very well be a language model. [@brownEstimateUpperBound1992] made a simple trigram model over the Brown corpus (600 million words), and found that it gives $H \leq 1.75 \;\rm{bit/character}$. [@behrjrEstimatingComparingEntropy2002] used a model that combines multiple n-gram models, giving $H \leq 1.46 \;\rm{bit/character}$.

A [more recent attempt in 2022](https://www.lesswrong.com/posts/htrZrxduciZ5QaCjw/language-models-seem-to-be-much-better-than-humans-at-next) is crucial, as it seems to show humans are already surpassed by the best language models like GPT-3 in terms of reaching low perplexity, but I haven't yet studied it in detail.

### Lossless compression

Another way to estimate is by lossless compression of a large corpus, since the entropy rate is the lower bound on compression rate. In more detail, if you have a source of information emitting symbols, and its symbol stream has an entropy rate of $x \;\mathrm{bit/symbol}$, then it takes at least $\sim xl$ bits to encode a long segment with $l$ symbols. Furthermore, this lower bound is approachable using the [entropy encoding](https://en.wikipedia.org/wiki/Entropy_coding).

The [Hutter prize](http://prize.hutter1.net/) is a competition for compressing a $10^9$-byte corpus from the English Wikipedia (`enwik9`). For the size of the finished product, both the algorithm and the compressed data must be counted. In particular, if a neural network is used, then the size of the neural network weights must be counted as well.

The `enwik9` dataset is in `XML` format, and thus contains a lot of non-English content like `<timestamp>2005-12-27T18:46:47Z</timestamp>`. It has $10^9$ bytes. It is tricky to decide how to clean it up to remove all the `XML` formatting. As a simple estimate, we simply counted its characters:

$$
997,520,891 \text{ characters} = 1,000,000,000 \text{ bytes}
$$

Therefore, the entropy rate is

$$
\frac{8\times 10^8 / 997,520,891}{\text{compression ratio}} = \frac{8.02}{\text{compression ratio}}\;\rm{bit/character}
$${#eq-hutter-prize-entropy-rate}

The standard zip algorithm can compress it down to about 300 Mb in size, a compression ratio of $\sim 3\times$. Over the years, the progress has been slow but somewhat steady. The current winning entry (Kaido Orav, 2024) has a compression ratio of $8.88\times$. If we extrapolate the prize-winning entries over the years, it seems that the best possible compression ratio is $\sim 10\times$. 

Similar to the Hutter prize, the [Large Text Compression Benchmark](https://mattmahoney.net/dc/text.html) also asks for compressing the `enwik9` dataset. However, there is no limit to the algorithm runtime or size, so the compression ratio for this benchmark is always higher. Currently (2024-01-19), the maximal compression rate reached is $9.35\times$ with [`nncp v3.2`](https://bellard.org/nncp/), which uses a small Transformer model.

[@grassbergerDataCompressionEntropy2002] used a substitutional compression algorithm with increasingly large codebooks. When the codebook had 6000 codes, the algorithm gave $h \leq 1.82 \;\rm{bit/character}$. By extrapolating the {codebook size}-{entropy rate} curve to an infinitely large codebook, they estimated that English has entropy rate $0.7 \pm 0.2 \;\rm{bit/character}$.

### Summary

| estimate | method | raw number| effective entropy rate (bit/char) |
| ---- | ---- | ---- | ---- |
| [@grassbergerDataCompressionEntropy2002] | compression, extrapolation | $0.7 \pm 0.2 \;\rm{bit/character}$ | $\sim[0.5, 0.9]$ |
| [Hutter prize](http://prize.hutter1.net/) (Kaido Orav, 2024) | compression | compression ratio $\geq 8.88$ | $\leq 0.90$ |
| Hutter prize extrapolated | compression, extrapolation | compression ratio $\sim 10$ | $\sim 0.80$ |
| [Large Text Compression Benchmark](https://mattmahoney.net/dc/text.html) (`nncp v3.2`, 2023) | compression | compression ratio $\geq 9.35$ | $\leq 0.86$ |
| [@shannonPredictionEntropyPrinted1951] | guessing game | $\in [0.6, 1.3] \;\rm{bit/character}$ | $\in [0.6, 1.3]$ |
| [@burtonLongrangeConstraintsStatistical1955] | guessing game | $\in [0.6, 1.3] \;\rm{bit/character}$ | $\in [0.7, 1.3]$ |
| [@coverConvergentGamblingEstimate1978] | guessing game | $\leq 1.3 \;\rm{bit/character}$ | $\leq 1.3$ |
| [@brownEstimateUpperBound1992] | 3-gram language model | $\leq 1.75 \;\rm{bit/character}$ | $\leq 1.75$ |
| [@behrjrEstimatingComparingEntropy2002] | n-gram language model | $\leq 1.46 \;\rm{bit/character}$ | $\leq 1.46$ |
| [@kaplanScalingLawsNeural2020] | Transformer language model, extrapolation | $\sim 1.7 \;\rm{nat/token}$ | $\sim 0.57$ |
| [@hoffmannTrainingComputeOptimalLarge2022] | Transformer language model, extrapolation | $L_\infty = 1.69 \;\rm{nat/token}$ | $\sim 0.54$[^tokenizer-difference] |

[^tokenizer-difference]: Because the tokenizers differ, the same `nat/token` translates to different `bit/char`.

Notably, the above table has mostly upper bounds, and only one dubious lower bound (by Shannon) from 1951. Perhaps lower bounds can be established by using [randomness extractors](https://en.wikipedia.org/wiki/Randomness_extractor) on a large corpus, and checking that the output from the extractor passes pseudorandomness tests.

Most of the data seems to be centered around 0.8 bpc. The one outlier is the Chinchilla scaling law estimate: 0.54 bpc. I have found that a lot hinges on the exact tokenizer-dataset fit, which is why tokenization is so annoying and I wish people would try to do away with it, or at least report bit-per-character in addition to nat-per-token.

## Forecasting AGI {#sec-forecasting-agi}

According to the [Chinchilla scaling law](https://en.wikipedia.org/wiki/Neural_scaling_law#Chinchilla_scaling_(Hoffmann,_et_al,_2022)) [@hoffmannTrainingComputeOptimalLarge2022], if we have a fixed amount of computing budget $C$, by choosing the model and dataset size correctly, the minimal reducible loss achievable is

$$
L - L_\infty = \frac{1070}{(C/\;\rm{FLOP})^{0.154}} \;\rm{nat/token}
$${#eq-chinchilla-scaling}

Assuming a slowdown factor $s$, that the judge decides when the odds ratio is $r:1$, and the Chinchilla scaling law, we have a direct method to predict how long a language model can survive in a Turing test, according to the cost of training compute $C$:

$$T^* \sim \frac{s\ln r}{1070}(C/\;\rm{FLOP})^{0.154} \;\rm{token}$$

This gives, as a rule of thumb, $100\times$ compute means $2 \times$ length of survival in a Turing test.

For example, assuming a slowdown factor of $s=10$, and that the judge decides when the odds ratio is $10:1$, for a language model to survive for 1000 tokens, it needs

$$L - L_\infty \leq 10 \times \ln 10 / 1000 = 0.023 \;\rm{nat/token}$$

If GPT-4 costs $2\times 10^{25} \;\rm{FLOP}$ in compute, and $1 \;\rm{word} \approx 1.2 \;\rm{token}$, then

$$T^* \approx 170 \text{ tokens} \approx 150 \text{ words}$$

meaning it has a good chance of passing the Turing test if limited to only 150 words. For context, the *Attention is All You Need* paper has an abstract that's 200 tokens long. 

A typical scientific paper is about 4000 words long, which is $27\times$ that of 150 words, so it would need $27^{1/0.153} = (2\times 10^9)\times$ that of compute. Assuming that GPT-4 cost 10 million USD to train, this hypothetical AI would cost $2\times 10^{16}$ USD, or 200 years of global GDP<sub>2023</sub>.

This implies that the first AGI will not be a scaled-up GPT -- autoregressive transformer generatively pretrained on a lightly filtered text dataset. It has to include something else, perhaps multimodal data, high-quality data, better architecture, etc. Even if we were to attempt to merely scale it up, turning earth into a GPT-factory,[^gpt-factory] with even 50\% of global GDP devoted,[^50-percent-gdp] and with 2\% growth rate forever, it would still take 110 years,[^110-years] arriving at year 2133. Whole brain emulation would likely take less time.[^wbe-timeline]

[^110-years]: Solve for $x$ in $200 = \sum_{k=0}^x 0.5 \times 1.02^k$.

[^50-percent-gdp]: Only in a life-or-death situation does 50\% of GDP get devoted to one purpose. For example, that is about the level of GDP devoted to war production during WWII in the major combatant countries. The USA spent 4 trillion USD<sub>2011</sub> over 6 years out of an annual GDP of 1.3 trillion USD<sub>2011</sub>.

[^wbe-timeline]: <iframe src="https://www.metaculus.com/questions/question_embed/2813/?theme=dark" style="height:430px; width:100%; max-width:550px"></iframe>

[^gpt-factory]:
    Consider this anecdote from [Edward Teller](https://en.wikipedia.org/wiki/Edward_Teller):

    > The possibilities of developing an atomic weapon and the desirability of doing it secretly were discussed at a Princeton University conference in which I participated in March 1939... Bohr said this rare variety could not be separated from common uranium except by turning the country into a gigantic factory. Bohr was worried that this could be done and that an atomic bomb could be developed--but he hoped that neither could be accomplished. Years later, when Bohr came to Los Alamos, I was prepared to say, "You see..." But before I could open my mouth, he said: "You see, I told you it couldn't be done without turning the whole country into a factory. You have done just that." [@tellerLegacyHiroshima1975]

## Appendix: Ergodic theory {#sec-ergodic-theory}

Since we used ergodic theory during the essay, we should quickly explain what it is about. This section is foundational, but the full complexity is not necessary. 

### Measure-theoretic POV

I know, you know too, nobody really likes measure theory any more than pianists like practicing scales hundreds of times. Still, it is at the right level of abstraction for many theories, including probability.

We omit all mentions of "almost-everywhere", "except on a set of measure zero", and similar annoying phrases. As long as you never make a union of uncountable many subsets, you will not be hurt by this omission.

A [probability space](https://en.wikipedia.org/wiki/Probability_space) is a measurable space with a measure of $1$. We write it as $(\Omega, \mathcal B, Pr)$, where $\mathcal B$ is the sigma-algebra of measurable sets, and $Pr$ is the probability measure. We also write $\mu$ for the measure.[^pronounced-mu]

[^pronounced-mu]: Pronounced "mu" -- it is a pun because both "mu" and "measure" starts with "m".

We consider a single measurable function $T : \Omega \to \Omega$, and call it the **shift map**.

We demand that $T$ *must* **preserve measure**. That is, $\forall S \in \mathcal B$, we have $Pr(T^{-1}(S)) = Pr(S)$.

A subset is **measurable** iff it is an element of $\mathcal B$. A measurable set is also called an **event**.

A subset $S \in \mathcal B$ is $T$-invariant iff $T^{-1}(S) = S$ almost everywhere.[^ae-warning] Let $\mathcal I$ be the set of all $T$-invariant subsets:

$$
\mathcal I := \{S \in \mathcal B : T^{-1}(S) = S\}
$$

[^ae-warning]: That is, except on a subset of measure zero: $Pr(T^{-1}(S) - S) = 0$ and $Pr(S - T^{-1}(S)) = 0$. This is the last time we will measure this.

Now, obviously any set of measure zero or one are $T$-invariant. We say that those are *trivially* $T$-invariant. We say that $T$ is **ergodic** iff $\mathcal I$ has only such trivial subsets. In other words, $T$ is ergodic iff it cannot be factored into two nontrivial chunks:

$$
S, S' \text{ partitions } \Omega,\quad \text{such that } T^{-1}(S) = S ,\; T^{-1}(S') = S',\; Pr(S) > 0 ,\; Pr(S') > 0
$$

We *usually* ask $T$ to also be ergodic, though sometimes we don't need that.


Ergodic maps have many very good properties. We will use the following one. For the theorem, you can picture it as the real space $\R^n$ with the gaussian probability distribution, but in fact, it applies for just about everything we would care about, such as the space of English texts, [queuing jobs](https://en.wikipedia.org/wiki/Queueing_theory), [random walks](https://en.wikipedia.org/wiki/Wiener_process), etc.[^rigor-mortis]

[^rigor-mortis]: Except pathological examples constructed by logicians who have nothing better to do than to care about the continuum hypothesis, large cardinals, and the arithmetic hierarchy. Those who desire the rigor-mortis of logic, let them have it.

::: {#thm-ergodic-dense-orbit}

## Dense orbits

If the state space is a [topological space with a countable basis](https://en.wikipedia.org/wiki/Second-countable_space), and any nonempty open set has positive measure, then almost any $X\in\Omega$ has a dense orbit.

:::

::: {.proof}
Let $U$ be a nonempty open set. 

$\Omega - \cup_{i \geq 0} T^{-i}U$ is $T$-invariant, and since it excludes $U$, it does not have the full measure. Since $T$ is ergodic, the set actually has zero measure.

Now, $\cup(\Omega - \cup T^{-i}U)$ is a union of countably many zero-measure sets, so it still has zero measure. By expanding the definition, this is the set of all points with non-dense orbit.
:::

Finally, there is a common theme in ergodic theory. There are rigorous versions of it, but instead of going for rigor, the spirit is more important:

::: {#thm-ergodic-decomposition}

## ergodic decomposition

Any interesting map is a partition/sum/integral of ergodic maps.

:::

For example, the shear map on the unit square $[0, 1]^2$ defined by

$$
(x, y) \mapsto (x, x+y \mod 1)
$$

can be thought of as an integral over rotations: For each $x \in [0, 1]$, we have $T_x : y \mapsto x+y\mod 1$. For almost all $x\in [0, 1]$, we have $T_x$ an [irrational rotation](https://en.wikipedia.org/wiki/Irrational_rotation), thus ergodic.

### Sequence POV

We must interpret the language of measure theory, which is dead like chalk dust, back into the language of sequence predictions, which is alive like reinforced concrete.

Each point in the state space $X\in \Omega$ is a text: a stream of tokens infinite both forwards and backwards. The state space $\Omega$ is the all possible texts $(X_n)_n$. We assume that all tokens come from the same finite-size alphabet, for example, the 128 ASCII symbols. 

The shift map on the state space $T : \Omega \to \Omega$ is defined by moving the origin to the right by one:

$$
T(\dots, X_{-1}, X_0, X_1, \dots) := (\dots, X_0, X_1, X_2, \dots)
$$

The shift map is measure-preserving, meaning that the process is **stationary**: We could have started reading at any point, and we would still expect to see the same kind of probability distribution. It would not be like "Sorry, the word 'cat' appears with zero probability when $n \geq 1000$.". It would be like "No matter where we start reading, we should expect to the first three tokens to be 'cat' with probability $10^{-4}$.".

Repeatedly applying the shift map $T$ is just reading through the stream, one token at a time:

$$
\text{...Lorem ipsum ...} \mapsto \text{...orem ipsum d...} \mapsto \text{...rem ipsum do...} \mapsto \cdots
$$

A periodic point of $T$ is a text that repeats itself like a broken record. For example, $X := \text{... and and and ...}$ satisfies $T^4X = X$.

A $T$-invariant set $S\subset \Omega$ is a set of texts, such that if we take any text $X$ from $S$, and jump either forwards or backwards for an arbitrary amount, we get another set in $S$. In other words, $S$ is a set of token streams where there is no origin: you can start reading from any token.

A probability distribution over $\Omega$ describes the probability of observing various kinds of text streams.

If we can partition $\Omega$ into two subsets $P, Q$, with probabilities $\epsilon > 0, 1-\epsilon > 0$, then it means that any text from $P$ is different from any text from $Q$, after any shift. It is as if there are two languages, and each text can be exclusively written in one language only.

We wish to consider only texts created by some imaginary "universal English speaker". In particular, we do not want it to get stuck in one sub-language of English, then never escape from it. That is, we assume the universal speaker is **ergodic**.

Now imagine that we randomly sample two pieces of text generated by the universal speaker, and we shift the first text around to match it against the second. By @thm-ergodic-dense-orbit, the orbit of the first text is dense in the space of all possible English texts spoken by the universal speaker. We can gamify this situation thus:

* Prover: "I take one piece of text $x$, then another piece $x'$.".
* Challenger: "I challenge you to find a stretch of text from $x$ that matches the $-1000:1000$ stretch in $x'$.".
* Prover asks [a team of immortal monkeys](https://en.wikipedia.org/wiki/Infinite_monkey_theorem) to do the task. A million years later: "At $49134819$.".
* Challenger verifies that $T^{49134819}(x)_{-1000:1000} = (x')_{-1000:1000}$.

### Shannon--McMillan--Breiman {#sec-smb-theorem}

If someone has created an infinite sequence of coin flips $X_{-\infty:+\infty}$, then revealed it to us one by one, then each reveal would give us $1 \;\rm{bit} = \ln 2 \;\rm{nat}$. The long-term average obtained per reveal is still $\ln 2 \;\rm{nat}$, a rather boring situation.

How do we measure the entropy of an English speaker? It speaks token by token, and we have to measure the average information we obtain per token. The problem is that there are two senses of "average". It could be the time-average: we listen to the speaker speak for a very long time, and calculate the entropy in the speech. It could be the ensemble-average: we listen to the speaker speak for a very long time, then do it again, then again, etc, then average together the time-averages.

If the speaker is ergodic, then the speaker essentially has just one speech, and any two samples of its speech are just translations of each other.[^ergodicity-and-self-averaging] Consequently, it is intuitively clear that with probability 1, the time-average of the entropy of one speech equals the ensemble-average of the entropy of all speeches. Intuitively, with probability 1,

[^ergodicity-and-self-averaging]: Statistical mechanists might recognize this as saying that the language is [self-averaging](https://en.wikipedia.org/wiki/Self-averaging). That is, sampling many speeches from the language is essentially the same as sampling one very long speech that we then cut into many sub-speeches.

$$
\frac{1}{n} \ln Pr(X_{1:n}) \to \E\lrs{\frac{1}{n} \ln Pr(X_{1:n})}
$$

For non-ergodic speakers. We simply [decompose the speaker into an ensemble of ergodic speakers](@thm-ergodic-decomposition), then apply the SMB theorem to each one. It is like the strong law of large numbers. Intuitively, with probability 1,

$$
\frac{1}{n} \ln Pr(X_{1:n}| X \text{ is type }i)\to \E\lrs{\frac{1}{n} \ln Pr(X_{1:n}) | X \text{ is type }i}
$$

This is the [Shannon--McMillan--Breiman theorem](https://en.wikipedia.org/wiki/Shannon-McMillan-Breiman_theorem).

In textbooks and Wikipedia, the SMB theorem is stated rigorously, but you have already understood the idea of SMB, and the rigorous versions are simply paraphrases of the idea.
