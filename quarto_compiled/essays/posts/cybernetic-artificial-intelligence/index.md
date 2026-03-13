---
title: "Cybernetic Artificial Intelligence"
author: "Yuxi Liu"
date: "2023-12-23"
date-modified: "2023-12-23"

categories: [AI, cybernetics, math, history]
format:
    html:
        toc: true

description: "Machine learning and self-reproduction according to Norbert Wiener."
image: "figure/cybernetic_meadow.png"
image-alt: "A grid of electromechanical spider-like robots on a concrete surface, with small cracks and many rounded-headed copper spires like tallgrass. It might be called poetically 'a cybernetic meadow'. Realistic sci-fi illustration."

status: "finished"
confidence: "likely"
importance: 2
---

{{< include ../../../static/_macros.tex >}}

## Cybernetics

In the creation lore of artificial intelligence, John McCarthy coined the term "artificial intelligence" to distinguish his approach from "cybernetics", which was dominated by Norbert Wiener. However, if that is the case, then we can infer that there was a real danger that artificial intelligence could have been confused with Norbert Wiener's cybernetics. That is, they must have some real similarity. If the similarity is not in style or approach -- as otherwise there would be no need to distinguish the two -- then the similarity must be in goal.

And indeed there is. I was first alerted to this by Wiener's little book [@wienerGodGolemInc1964, Chapter 4], which briefly sketched out a machine that could purportedly imitate any machine, including another copy of itself, thus effecting both machine learning and machine reproduction. Unfortunately, it attempted to be a popular science book and explained concepts with a minimum of mathematical symbols, thus providing the reader with a minimum of understanding. Nevertheless, I figured it out by consulting his other books, and so I decided to write this post for posterity, as a simple sketch of another way to think about machine intelligence and machine life. A view of another universe, perhaps, or the theoretical basis of some hard sci-fi to be written.

This cybernetic machine is a rather obscure one, and most of the references are decades-old. The main references I relied on to write this essay are [@wienerNonlinearProblemsRandom1958, Chapters 10, 11; @wienerCyberneticsControlCommunication2019, Chapter 9; @ohaganPolynomialChaosTutorial2013; @harrisIdentificationNonlinearSystems1967].

Wiener's terminology is occasionally obsolete; unfortunately, the subject of cybernetic artificial intelligence has essentially never been updated since Wiener, so anyone trying to study the subject must contend with his publications. So here is a list of obsolete terminology and my explanations.

* shot noise, shot effect, tube noise: white noise. It is *not* [Poisson noise](https://en.wikipedia.org/wiki/Shot_noise).
* chaos: a generic term for randomness, or random variables. It is *not* [chaos theory](https://en.wikipedia.org/wiki/Chaos_theory).
* voltage multiplier: an electronic device that multiplies two voltages together, by $(x, y) \mapsto xy$. It is *not* the [voltage multiplier](https://en.wikipedia.org/wiki/Voltage_multiplier).

### The nonlinear transducer model

According to Wiener, cybernetics is the science of control and communication in the animal and the machine. To be more precise, he used the following model of sweeping generality: the **nonlinear transducer model**.

::: {#def-signal}
## signal

A signal is a function of time, written as $x(t)$, where $t \in \R$. The signal can take values in any space, but for convenience, we will only consider the case where $x$ is real-valued. That is, we only consider functions of type $x : \R \to \R$.
:::

A transducer transduces, meaning that it takes in a signal and outputs a signal. Antennas, filters, circuits of resistors and capacitors, and essentially electronic devices that do not require power input to run, are transducers. Wiener considered only deterministic, causal transducers, meaning that the output of a transducer at time $t$ is determined by the inputs during the period $(-\infty, t]$.

In large sections of electronic engineering, electronic circuits are studied as either linear and continuous, or as nonlinear and discrete. Nonlinear but continuous devices are very difficult to study in general, but Wiener took on it and constructed a theory for general nonlinear continuous transducers.

::: {#def-transducer}
## nonlinear transducer

* The transducer is a function $T$ that, given any real-valued function $x : \R \to \R$, returns a real-valued function $T[x] : \R \to \R$. In other words, it sends real-valued signals to real-valued signals.[^real-valued-signals]
* The transducer's output at any time $t$ is determined by the value of $x$ on the interval $(-\infty, t]$. In other words, it is causal and deterministic.
* The transducer is stationary in time. That is, if $x$ is the same over the interval $(-\infty, t]$ as $x'$ over the interval $(-\infty, t']$, then $T[x](t) = T[x'](t')$.
* The transducer has a limited amount of memory, so that its dependence on the high-frequency details of the input signal decreases rapidly as frequency increases. We will explain the meaning of this assumption later.
* The transducer depends analytically on the frequencies of the input signal. We will explain the meaning of this assumption later.

[^real-valued-signals]: Wiener actually studied general multidimensional signals, but those mostly involve notational complications, with no new ideas.

:::

## Orthogonal functions

In order to present Wiener's approach to nonlinear control theory, we need a small amount of the theory of orthogonal polynomials. Specifically, we need the Hermite and Laguerre polynomials. They are not as famous as the trigonometric functions, but they are used in the same way as trigonometric functions in Fourier analysis. In Fourier analysis, every well-behaved function (in the Fourier sense) is decomposable as an infinite linear sum of trigonometric functions. Similarly, every well-behaved function (in the Hermite sense) is decomposable into an infinite linear sum of Hermite functions, and the same applies to Laguerre functions.

### Laguerre functions

The Laguerre polynomials have many equivalent definitions. We will use three of those.

::: {#def-laguerre}
## Laguerre polynomials

Direct definition:

$$
L_n(x) := \sum_{k} \binom{n}{k}\frac{(-1)^k}{k!} x^k
$${#eq-laguerre}

Definition by a generating function:

$$
g(t, x) = \sum_{n=0}^\infty t^n L_n(x)=  \frac{1}{1-t} e^{-tx/(1-t)}
$${#eq-laguerre-generating-function}

Definition by ordinary differential equation:

$$
\begin{cases}
xL_n'' + (1-x) L_n' + nL_n &= 0 \\
L_n(0) &= 1 \\
L_n'(0) &= -n 
\end{cases}
$${#eq-laguerre-ode}
:::

::: {#prp-laguerre-equivalence}

The three definitions are equivalent.

:::

::: {.proof}
The direct definition of $L_n$ satisfies $xL_n'' + (1-x) L_n' + nL_n = 0$, and has the same value and first derivative at $x=0$. By the uniqueness theorem of ordinary differential equations, the two definitions are equal.

By taking the first partial derivatives $\partial_x g, \partial_t g$, and simplifying, we obtain some recurrence relations of $L_n$, including $xL_n'' + (1-x) L_n' + nL_n = 0$. Plugging in the case where $x=0$, we obtain $L_n(0) = 1$ and $L_n'(0) = -n$.
:::

::: {#prp-laguerre}

## Laguerre polynomials are orthogonal with respect to the exponential distribution

$$
\int_{0}^\infty e^{-x}L_m(x) L_n(x)dx = \delta_{mn}
$$
:::

::: {.proof}

Explicitly integrate

$$\int_{0}^\infty e^{-x} g(t, x)  g(s, x) dx$$

then expand the Taylor series of both sides in powers of $s, t$.

:::

::: {#def-laguerre-function}
## Laguerre functions

$$
\psi_n(t) := e^{-t/2}L_n(t)
$$

:::

The Laguerre functions make the orthogonality cleaner:

$$
\int_0^\infty \psi_n(t)\psi_m(t) dt = \delta_{mn}
$${#eq-laguerre-function-orthogonal}

Just like in Fourier analysis, by virtue of orthogonality, we can represent any well-behaved function on $(-\infty, t]$ as an infinite sum of Laguerre functions

$$
f(t-\tau) = \sum_{n \geq 0} c_n \psi_n(\tau)
$$

by taking a convolution with the Laguerre functions

$$
c_n = \int_0^\infty f(t-\tau) \psi_n(\tau) d\tau.
$$ 

### Hermite polynomials

::: {#def-hermite-polynomial}
## physicist's Hermite polynomials

$$
\sum_n H_n(x) \frac{1}{n!}t^n = e^{-t^2 + 2tx} = g(t, x)
$${#eq-hermite}
:::

::: {#prp-hermite}
## Hermite polynomials are orthogonal with respect to the normal distribution with variance 1/2

$$\int e^{-x^2}H_n(x) H_m(x) dx = \sqrt\pi 2^n  n! \delta_{mn}$$
:::

::: {.proof collapse="true"}
$$\int e^{-x^2} g(t, x)g(s, x) dx = \sum_{n, m \geq 0}\frac{1}{n! m!}t^ns^m \int e^{-x^2} H_n(x) H_m(x) dx$$

Directly compute the left-hand side and find that it equals $\sqrt\pi e^{2st}$. Now expand it in powers of $s$ and $t$.
:::

## Learning and reproducing any transducer

Now we are ready to perform the "Hermite--Laguerre expansion", Wiener's way to analyze (learn) and synthesize (reproduce) arbitrary transducer using pure analog devices.

### Algebra of analog circuitry

In an analog electronic circuit, real numbers are represented as voltages across two points ("ports") in the circuit. Adding is as simple as making a serial connection. Negation is even simpler: just connect the ports in the opposite direction. Multiplication is significantly trickier, but it can be done. There are electronic devices with nonlinear response characteristics, meaning that they have two input ports and two output ports, and if you apply an input voltage $x$ across one such device, the output voltage would be $f(x)$ where $f$ is not a linear function. Now suppose that $f(x) = x^2$.[^universal-approximation]

[^universal-approximation]: From our vantage point, the [universal approximation theorems](https://en.wikipedia.org/wiki/Universal_approximation_theorem) proven in the early 1990s show that, generically, if we have any nonlinear function $f_0$ *at all*, then we can construct *any* activation function $f$ as a neural network, by using many copies of the $f_0$ device as activation functions and linear devices as weights and biases.

With such an $f$, we can multiply two voltages by $xy = (f(x+y) - f(x) - f(y)) \times 0.5$, and so we can construct any polynomial function in any number of variables. That is, we can do algebra by analog devices, as long as we have a voltage multiplier.

Of course, we don't hear about voltage multipliers often, and this is no accident -- it is quite difficult to get one with good performance. In the preface to the second edition of *Cybernetics*<sub>1961</sub> [@wienerCyberneticsControlCommunication2019, page xli], Wiener waxes praise about Gabor's breakthrough circuit device that could multiply two voltages at a frequency of $1\; \mathrm{kHz}$:

> While there are many approaches to the problem of multiplying two functions electrically, this task is not technically easy. On the one hand, a good multiplier must work over a large range of amplitudes. On the other hand, it must be so nearly instantaneous in its operation that it will be accurate up to high frequencies. Gabor claims for his multiplier a frequency range running to about 1,000 cycles. ... he does not state explicitly the amplitude range over which his method of multiplication is valid nor the degree of accuracy to be obtained. I am awaiting very eagerly[^awaiting-eagerly] an explicit statement of these properties so that we can give a good evaluation of the multiplier for use in other pieces of apparatus dependent on it.

[^awaiting-eagerly]: Gabor published it in the same year of 1961: [@gaborUniversalNonlinearFilter1961].

To our modern ears, multiplying two voltages 1000 times a second by analog means seems simultaneously astonishing and obsolete. [Intel 8086](https://en.wikipedia.org/wiki/Intel_8086) in 1976 already could multiply a million times a second, and whatever has come of Gabor's universal filter? It seems to me that Wiener never accepted the future of digital computers, preferring the concrete certainty of magnetic cores and electric wires.

### The Laguerre filter bank

To find the Laguerre coefficients of a signal, we need to perform a convolution. Convolutions become products after a [Laplace transform](https://en.wikipedia.org/wiki/List_of_Laplace_transforms), so we need to find the Laplace transform of the Laguerre functions $\psi_n = e^{-x/2}L_n(x)$. Fortunately, it is easy to compute. We simply read from a standard table:

$$
\mathcal L [t^n e^{-\alpha t}\theta(t)] = \frac{n!}{(s+\alpha)^{n+1}}
$$

where $\theta(t) = 1_{t \geq 0}$ is the zero-one step function.

Then, since the Laplace transform is linear, we have after simplification

$$
\mathcal L[\psi_n\theta] = \frac{1}{s+1/2}\left(\frac{s-1/2}{s+1/2}\right)^n
$$

This gives a simple [filter bank](https://en.wikipedia.org/wiki/Filter_bank) that constructs the Laguerre coefficients for any signal. The input signal passes through a $\frac{1}{s+1/2}$ filter to obtain the $c_0$ coefficient, and then through a $\frac{s-1/2}{s+1/2}$ filter to obtain the $c_1$ coefficient, and so on. This filter bank can be constructed with standard resistors and capacitors.

The following theorem finishes the last piece of the puzzle. [@harrisIdentificationNonlinearSystems1967] claims that the proof is found in [@boseTheoryNonlinearSystems1956; @harrisIdentificationNonlinearSystems1966], but I did not check.

::: {#thm-laguerre-white-noise}
Let $x(t)$ be a white noise process with variance $1/2$, and let $c_0(t), c_1(t), \dots$ be its Laguerre coefficients, then:

* the joint stochastic process $(c_0(t), c_1(t), \dots)$ is stationary;
* for any fixed $t\in \R$, the random variables $c_0(t), c_1(t), \dots$ are independent samples of the standard gaussian distribution $\mathcal N(0, 1/2)$.
:::

### The Hermite coefficients

For a given input signal $x : \R \to \R$, we pass it into the Laguerre filter bank. The readouts from the filter bank are the signals $c_0(t), c_1(t), \dots$. They satisfy the equation

$$
x(t - \tau) = \sum_{n\geq 0} c_n(t) \psi_n(\tau), \; \forall \tau \geq 0\quad \forall t \in \R
$$

In words, at any cut-off time $t \in \R$, the signal we have seen so far is $x(t - \tau)$ with $\tau \geq 0$. This signal can then be decomposed as a linear sum of Laguerre functions $\sum_{n\geq 0} c_n(t) \psi_n(\tau)$, with $c_n(t)$ as the Laguerre coefficients. The coefficients depend on the cut-off time $t$, but do not depend on $\tau$, which is not "real" time, but only a kind of "relative historical time", as we look into the past standing at time $t$.

A transducer, by our assumption, is deterministic and causal, so that $T[x](t)$ is a deterministic function of the signal we have seen so far, and so it is a deterministic function of $c_0(t), c_1(t), c_2(t), \dots$. Note carefully that it is determined by $c_0(t), c_1(t), c_2(t), \dots$ *at this very instant* $t$. It does not need the values of $c_0(t'), c_1(t'), c_2(t'), \dots$ at any $t' \neq t$. We write it as follows:

$$
T[x](t) = T(c_0(t), c_1(t), c_2(t), ...)
$$

By our assumption that the transducer has a limited memory, we should be able to ignore the higher frequency components of the input signal, and still recover a good approximation of $T$. That means that $T[x](t) = T(c_0(t), c_1(t), c_2(t), \dots) \approx T(c_0(t), \dots, c_n(t))$, with the approximation increasing in accuracy as $n$ increases.

By our assumption that the transducer is analytic with respect to the input, $T(c_0(t), \dots, c_n(t))$ has a multivariate Hermite serial expansion (the same idea as multivariate Taylor expansion):

$$
T(c_0(t), \dots , c_n(t)) = \sum_{m_0, \dots , m_n \geq 0} T_{m_0, \dots , m_n} H_{m_0}(c_0(t)) \cdots H_{m_n}(c_n(t))
$$

We are quite close to the target. We can compute the Laguerre coefficients $c_n(t)$ of any input signal by the Laguerre filter bank. We can construct analog circuits that compute $H_m(c_n(t))$, the Hermite polynomial values of the Laguerre coefficients. The remaining challenge is to determine the coefficients $T_{m_0, \dots, m_n}$.

This is where @thm-laguerre-white-noise comes to finish the construction. Let $x(t)$ be a white noise process, then since

$$
T[x](t) \approx \sum_{m_0, \dots , m_n \geq 0} T_{m_0, \dots , m_n} H_{m_0}(c_0(t)) \cdots H_{m_n}(c_n(t))
$$

and since the Laguerre coefficients are independent samples of the standard gaussian, we have

$$
T_{m_0, \dots , m_n} \approx \mathbb{E}\lrs{T[x](t)\; H_{m_0}(c_0(t)) \cdots H_{m_n}(c_n(t))}
$$

where the expectation is in the sense of ensemble expectation. That is, we would run this experiment once with a white noise process, freeze it exactly at the moment $t$, then run it again with another white noise process, freeze it exactly at the moment $t$, and so on. Then we average over all these experiments.

However, @thm-laguerre-white-noise states that the Laguerre coefficients are stationary, meaning that we have [ergodicity](https://en.wikipedia.org/wiki/Ergodic_theory)[^ergodic-hypothesis]: the ensemble average is the time average, and so

[^ergodic-hypothesis]: Wiener was *really* into ergodic theory.

$$
T_{m_0, \dots , m_n} \approx \lim_{T \to \infty} \frac{1}{T} \int_0^T T[x](t)\; H_{m_0}(c_0(t)) \cdots H_{m_n}(c_n(t)) dt
$$

The integrand is computable by the analog devices we described. The integration-and-averaging can be done with a very-low-pass filter -- taking the average is essentially passing only the zero-frequency signal, thus it is the low-pass filter with the lowest possible passband. Finally, since white noise is all around us, it can be obtained in many ways, such as by amplifying the thermal noise in a resistor.

And so we have a finished machine, where the white noise $x$ and the signal to imitate $T[x](t)$ come in, and the fitted parameters $T_{m_0, \dots, m_n}$ come out. The fitted parameters can be automatically read and adjusted by electromechanical devices, such as relays and step motors, allowing us to connect the machine in parallel with an unknown transducer, run it for a period over a white noise input, and ultimately achieve a machine that precisely imitates the unknown transducer.

![The fully-formed imitation machine. [@harrisIdentificationNonlinearSystems1967, Figure 2]](figure/wiener_method_machine.png)

## The science of control and communication in the animal and the machine

> Winter 1943--1944
> 
> [Lorente de Nó](https://en.wikipedia.org/wiki/Rafael_Lorente_de_N%C3%B3) and I, as physiologists, were asked to consider the second of two hypothetical black boxes that the allies had liberated from the Germans. No one knew what they were supposed to do or how they were to do it. The rust box had been opened and exploded. Both had inputs and outputs, so labelled. The question was phrased unforgettably: "This is the enemy's machine. You always have to find out what it does and how it does it. What shall we do?" By the time the question had become that well defined, Norbert was snoring at the top of his lungs and his cigar ashes were falling on his stomach. But when Lorente and I had tried to answer, Norbert rose abruptly and said: "You could of course give it all possible sinusoidal frequencies one after the other and record the output, but it would be better to feed it noise -- say white noise -- you might call this a [Rorschach](https://en.wikipedia.org/wiki/Rorschach_test)." Before I could challenge his notion of a Rorschach, many engineers' voices broke in. Then, for the first time, I caught the sparkle in [Johnny von Neumann](https://en.wikipedia.org/wiki/John_von_Neumann)'s eye. I had never seen him before and I did not know who he was. He read my face like an open book. He knew that a stimulus for man or machine must be shaped to match nearly some of his feature-filters, and that white noise would not do. There followed a wonderful duel: Norbert with an enormous club chasing Johnny, and Johnny with a rapier waltzing around Norbert-at the end of which they went to lunch arm in arm.
>
> [@mccullochRecollectionsManySources1974]

We have reached the end of the road, facing an all-analog general-purpose learning machine. This machine can imitate any black-box transducer, and thus is a form of machine learning. If we have two such machines, and randomly set the parameters of one machine, then the other machine would learn to imitate the same behavior. And since each parameter setting creates a different behavior, *purely by imitating behavior*, the parameters would be copied from one machine to the other. This is an explicit construction for how behaviorism can work, even if not in our universe, then in another universe where the animals really are those imitation devices.

As Wiener speculated [@wienerCyberneticsControlCommunication2019, pages 248-249], biological learning and reproduction are "philosophically similar" to this machine:

> While both Professor Gabor's methods and my own lead to the construction of nonlinear transducers, they are linear to the extent that the nonlinear transducer is represented with an output which is the sum of the outputs of a set of nonlinear transducers with the same input. These outputs are combined with varying linear coefficients. This allows us to employ the theory of linear developments in the design and specification of the nonlinear transducer. And in particular, this method allows us to obtain coefficients of the constituent elements by a least-square process. If we join this to a method of statistically averaging over the set of all inputs to our apparatus, we have essentially a branch of the theory of orthogonal development. Such a statistical basis of the theory of nonlinear transducers can be obtained from an actual study of the past statistics of the inputs used in each particular case. I ask if this is philosophically very different from what is done when a gene acts as a template to form other molecules of the same gene from an indeterminate mixture of amino and nucleic acids, or when a virus guides into its own form other molecules of the same virus out of the tissues and juices of its host. I do not in the least claim that the details of these processes are the same, but I do claim that they are philosophically very similar phenomena.

It seems like this device, as it stands, would be plagued by the same issues that plague a general analog computer -- error correction, bad gains, and intractable nonlinearities. Still, it stands as a vision of an alternative future in an alternative world, if not an alternative future of our world.

![](figure/cybernetic_meadow.png)
