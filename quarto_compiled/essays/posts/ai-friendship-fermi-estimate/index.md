---
draft: true
title: "The economics of AI friendship"
author: "Yuxi Liu"
date: "2025-10-2?"
date-modified: "?"

categories: [AI, economics]
format:
  html:
    toc: true

description: "Fermi estimation for ."
image: "?"
image-alt: "?"

status: "finished"
confidence: "possible"
importance: 8
---

## Introduction

This has been a Last year, OpenAI deployed a "memory" system to its ChatGPT product, to personalize GPT for the users. During conversations, the system stores certain important statements about the user into the memory system, which would then be used by GPT in-context, filled into its system prompt.

There are many use cases for personalized AI. Some would want a companion AI, as shown by the popularity of Character.AI, the movie *Her*, and so on. Some would want a butler AI that would take care of the various mundane tasks *just so*. Many small businesses would have demand for AI employees, trained on the job to fit the many little quirks of the shop.

So far, much of AI personalization as offered by the large corporations like OpenAI and Anthropic are limited to changing the system prompt. However, we believe that there is great potential for using continual learning -- finetune the model parameters on the user inputs. The main concern to this is that it would be too costly for a mass consumer product. However, this GU essay argues that personalized AI may already be ready for the consumers at a cost of around 50 USD/month.

Lay down the working hypotheses.

We assume that true personalization requires continual learning. Specifically, we assume that it is not enough to continue with the technique of storing memory as text in-context, exemplified by "ChatGPT memory" that simply creates a long list of text entries that describe the "memory items", and the scaling of context length to millions of tokens in the Gemini series.

For this, we have two arguments.

One, an argument by analogy. The context window, and artificial neural activations during the forward inference, is similar to the moment-to-moment thinking with working memory, encoded by the temporary neural activation patterns. The parameter weights and weight updates by gradient descent are similar to the accumulation of long-term memories. In humans, long-term memory is about a billion times larger than working memory, and decays about a billion times slower. It is reasonable to assume that a model should continue to update its parameters even after finetuning, and not attempt to perform all learning in-context, as the capacity for memory is much greater in parameters than in context.

As we will describe later, an adult human stores about $3\times 10^{9}$ bits in long-term memory, while having only about 10 bits of working memory. An unattended item in working memory decays in a few seconds, while long-term memory decays over decades.

Two, an argument by architecture. While the mechanism for in-context learning is unclear, it is generally believed to involve a mixture of simulated gradient descent, Bayesian inference, and elicitation of learned abilities. It is unlikely that in-context learning can fully replace weight update. Indeed, if in-context learning is sufficient, then we might imagine, at the limit, of running a single untrained Transformer with the entire pretraining corpus as its context. Continual learning is simply *more finetuning*, and if finetuning cannot be replaced by in-context learning, why would continual learning be replaced by it?

Summarize the basic argument.

The argument of the essay is as follows. We first establish, by psychophysical arguments, that a human absorbs around 1 bit per second into long-term memory, which suggests that deep personalization, on the level of a close friendship, amounts to learning up to 10 million bits about the user.

Since a well-trained LLM can encode ~1 bit per parameter, deep personalization can be done by finetuning ~10 million parameters.

Several arguments show that the parallelization overhead of serving millions of finetunes for millions of users would not be bottlenecked by compute or memory bandwidth. The cost of finetuning and inference is estimated to be up to 10 and 40 USD per user-month.


## How many bits and how many tokens are needed for personalization?


To begin, we should estimate the amount of information that a personalized AI should learn on top of what it already knows beforehand.

A human, regarded as an information processor, has a bowtie-like structure. There are around 1 million fibers in the optical nerve, capable of inputting information at a rate of 107 bps (bits per second). The other modalities, such as the ear, the touch, and such, have substantially less bandwidth. However, since consciousness is substantially narrower than this, much of this torrent is subconsciously filtered and discarded, and only a very small portion, on the order of 10–40 bits, can be attended to, and even a smaller portion of that can be kept for long term storage.

[@mathyWhatsMagicMagic2012]

[@bradyCompressionVisualWorking2009]


![][image1]

[@lehrlBasicParametersHuman1988]

Multiple studies have shown that, of all the information ingested by an awake and alert human, only 1--2 bits can be committed to long-term memory per second. This is true for memorizing facts learned from reading or hearing, and for memorizing pictures. This is true for both adults and children.

[@landauerHowMuchPeople1986]

[@bradyVisualLongtermMemory2008]

[@ferraraDetailedVisualMemory2017]

Assuming, as an upper bound, of 16 hours of concentrated learning per day, this translates to 20--40 million bits per year. In other words, an adult human would have committed to long-term memory 0.6--1.2 billion bits in 30 years. Since each adult human has many skills, each skill must necessarily be acquired within a bit-budget substantially smaller than this number.

Consider a native fluency in the English language, the acquisition of which is a major achievement. It was estimated that a native speaker of English have committed 1--40 million bits of knowledge about the English language to long-term memory, with a best-guess value of 12 million bits. This corresponds to 1700--3300 hours of concentrated study, which roughly matches the estimate of the Foreign Service Institute that learning a language takes 700--2200 classroom-hours.

[@mollicaHumansStore152019]

[https://www.state.gov/foreign-service-institute/foreign-language-training](https://www.state.gov/foreign-service-institute/foreign-language-training)

Assume thenceforth the 1 bit-per-second value. If a close friendship implies spending 1 hour per day with concentration, then the information content of a close friendship is ~1 million bits per year. Similarly, an on-the-job training of a new employee for 8 hours a day for a month implies that a new hire needs to absorb ~0.1 million bits to become a productive employee.


## How many parameters are needed for storing the personalization?


In the human brain, long-term memory is stored in the synaptic weights, which is changed by experience. The more precisely the weight can vary in a synapse, the more bits can be stored in it. [@bromerLongtermPotentiationExpands2018] found that, for the hippocampal region, a synapse can store on the order of 2.7--4.7 bits. Similarly, [@karbowskiInformationEncodedVolumes2023] found that across mammalian species and brain regions, the information density is consistently in the range of 1.9--3.4 bits per synapse.

On the side of artificial neural networks, [@allen-zhuPhysicsLanguageModels2024] found, by controlled studies of LLM training, that a well-trained LLM can store up to 2 bits per parameter, with each parameter having 8-bit precision.

Combining the two discussions, we may take 1 bit per 8-bit parameter as the information density. This in particular means that the information content of a 1-year close friendship could be stored in 1 million 8-bit parameters, taking up 1 MB of storage. To contextualize this number, a single matrix in the feedforward layers of GPT-3-175B contains 600 million parameters.

Comment: What do all these parameters do?

It is concerning that the above estimate shows that both the human brain and the current frontier models are greatly overparameterized. A human brain contains 1015 synapses, each of which can roughly store 1 bit. A frontier model contains 5e11 parameters, each of which can *also
roughly store 1 bit. Yet, we have found that an adult human has only committed ~1e9 bits to long-term memory. This then brings the question of what all the other parameters do. While we have no strong answer to this, we believe that there are three main sources that together explain much of this overparameterization.

One, overparameterization accelerates training. It is well-known that larger models learn faster, and find better minima. However, once a large model has found a good minimum, much of the performance can be distilled into a much smaller network. However, such a small network would be difficult to optimize directly, as a larger network has a more well-behaved loss landscape. Analogously, in humans, though a large brain consumes more energy, it may be necessary for fast learning.

[@liTrainBigThen2020]

[@frankleLotteryTicketHypothesis2019]

Two, overparameterization makes inference robust. Biological brains can continue to function despite loss of tissue. Similarly, neural networks can continue to function despite neural dropout, or even the loss of entire layers.

Three, many of the parameters may not be used for long-term memory. In humans, much of the synaptic connections in the prefrontal cortex may be used for working cognition, rather than for storage. Much of the connections in the primary visual cortex is for routine low-level image processing, akin to convolutional and pooling layers in vision models. These connections need not store long-term memory. Probably, many parameters in an artificial neural network are also not used for long-term memory, but for working cognition.

## How to finetune the models efficiently?


In general, the layers in a large language model perform repeated processing on the input sequence. The lower layers process at a low-level, handling aspects like spelling and linear word-order. The middle layers begin to process syntax. The higher layers process increasingly high levels of semantics, with the final layers performing specific tasks. In finetuning, the parameters in the final layers are updated the most.

Rogers, Anna, Olga Kovaleva, and Anna Rumshisky. "A primer in BERTology: What we know about how BERT works." Transactions of the association for computational linguistics 8 (2021): 842-866.

Since the advent of large models, researchers and amateurs have studied various forms of parameter-efficient finetuning (PEFT). The idea of PEFT is to modify only a small subset of all parameters in a pretrained model during finetuning for computational efficiency. The most common methods are adapter layers and low-rank adaptation (LoRA). In LoRA, a pretrained weight matrix $W$ is replaced by $W+AB$, where the matrices $A, B$ are finetuned while $W$ itself remains unchanged. Let $W$ have shape $(n_1, n_2)$, then $A, B$ can have shapes $(n_1, m), (m, n_2)$. When $m \ll n_1, n_2$, the number of modified parameters is $m(n_1 \+ n_2) \ll n_1 n_2$. An adaptor layer is similar, with a non-linear activation function applied between $A, B$.

For storing the information content of 10 years of close friendship, we would need about 10 million parameters. A standard frontier Transformer, such as Llama-3-405B and GPT-3-175B, represents each token with ~20000 floating point numbers (that is, its hidden size is ~20000). Therefore, its feedforward layers contain matrices with shape $(n_1, n_2) \sim (20000, 80000)$. Thus, a single rank-100 LoRA would be sufficient for storing the information, which, as we will see, can be efficiently deployed in parallel.

According to [@landauerHowMuchPeople1986], a human reading composed text can absorb about 0.5 bits per word. In a friendly conversation, such information density is likely to be an overestimate. Nevertheless, assuming the density of 0.5 bit/word, we find that to instill the 1 million bits of friendship per year, the model needs to read 2 million words from the user per year. Assuming the standard 1 token \= 0.75 words conversion rate, this is equal to 3 million tokens.

A common failure mode of continual learning is that it may lead to catastrophic forgetting. Specifically, as a model learns more of new data, it may decrease in performance on old data. The usual solution is to combine new and old data in a mixture. Empirical research shows that for LLMs on the scale of ~100B parameters, the ratio of old and new data ranges between 1:1 and 5:1.

[@parmarReuseDontRetrain2024]

[@ibrahimSimpleScalableStrategies2024]

Assuming this, the amount of finetuning per user-year ranges within 6--18 million tokens. We can picture this as a model going to sleep overnight to consolidate into its long-term memory all that it has learned about the user during the day, by mulling over 16--50 thousand tokens from the user.

The LoRA does not need to be updated literally overnight. Instead, there simply needs to be a moderate number of tokens before a LoRA update. Not too many, such that the user would feel disappointed that the chatbot hasn't yet updated their long-term memory. Not too few, such that updating becomes inefficient in terms of GPU-utilization. The chatbot can place the tokens in the context window before the update, and flush the context window after the update as if “waking up refreshed”. 16--50k seems like a reasonable middle ground, since frontier models such as Gemini-2.5 routinely handle 50k tokens in the context window, and finetuning on ~10k tokens is sufficient for saturating a GPU’s VRAM.

For a Transformer with $N$ parameters, processing $D$ input tokens, the forward pass costs $2ND$ in FLOPs, while the backward pass costs $4ND$, assuming momentum gradient descent. For our case, if the LoRA is located at layer $\ell$ of the Transformer, as we assumed, then to train the LoRA, any layer before layer $\ell$ costs only $2ND$, while any layer after costs the full $6ND$. The exact point where $\ell$ should be located is unknown, but it is reasonable to assume that $\ell$ is after the middle point. Assuming this, then the total computing cost is $4ND$.

Therefore, for a frontier model of 500B parameters, the computing cost of finetuning per user-year is 1--4e19 FLOPs, or 0.14--0.4 pFd (petaFLOP-day). This corresponds to ~1/(1 million) the pretraining cost of GPT-4.

At prevailing costs of compute of 240 USD/pFd, this costs 33--100 USD.

The H100 GPU runs at 200 TFLOP/sec in FP16. The prevailing rental price is 2 USD/hr.

As a sanity check, OpenAI offers finetuning service through an API. For GPT-4o, finetuning on 1 million tokens costs 25 USD. This means finetuning on 6--18 million tokens costs 150--450 USD.

[https://openai.com/api/pricing/](https://openai.com/api/pricing/)

For inference, the number of finetuned parameters, ~107, consists less than 10\-4 of the total number of parameters, thus the increase in inference compute cost is negligible.

## The parallelization overhead

However, the above calculation is in an important sense naive: It completely ignores the parallelization overhead. The essay's topic is on the economic feasibility of large-scale deployment, such as allowing OpenAI to properly personalize GPT for its ~108 daily users. How might a large corporation, such as OpenAI, finetune one LoRA per user, for millions of users?

It is impossible to predict the details of engineering, yet we can estimate the order of magnitude. Using several calculation methods, we believe that the parallelization overhead would not be a deal-breaker.

A first-principles calculation shows that using LoRAs poses no special difficulty in terms of the memory bottleneck, compared to not using LoRAs.

Consider a simple model. There are $n$ users, each with a separate LoRA $A_iB_i$. Let $x_i$ be the input for the $i$-th user, then to compute $A_i B_i x_i$ in parallel for all $i$, one first computes all $B_i x_i$ in parallel, then all $A_i(B_i x_i)$.

As previously calculated, each of $A_i, B_i$ has shape on the order of $~(100, 20000)$. Standard Nvidia GPUs, such as H100, are well-adapted to numerical operations with arithmetic intensity on the order of 100. In particular, this means that it is well-adapted to performing matrix-matrix multiplications by a tiled algorithm, with each tile having shape $\sim(100, 100)$. This shows that the shapes of $A_i, B_i$ are well-suited for tiled operations.

This can be understood in two ways.

First, frontier Nvidia GPUs have 65,536 registers per streaming multiprocessor (SM). Since $65526 \sim 3 \times 150^2$, this indicates that it is well-suited for performing matrix multiplications with shape $\sim (150, 150)$.

Second, frontier Nvidia GPUs suffer from the memory bottleneck, in the sense that the bandwidth between VRAM and L2 cache is ~1 TB/sec, while can perform ~100 TFLOP/sec. Thus, saturating the compute requires ~100 in arithmetic intensity.

The LoRA can be assigned to GPUs as needed, alongside their KV-caches. When a user logs-on, their previous conversation has to be loaded. Then, as soon as the user needs an output, the KV-cache materializes, so if the LoRA is smaller than the KV-cache, the LoRA may be materialized in memory along with the KV-cache, at no great delay. Indeed, LoRAs are more memory-efficient than KV-cache, because LoRAs have roughly uniform sizes, whereas the sizes of KV-caches greatly vary between users, and even between different conversation-threads from the same user. If a user is inactive for too long, their LoRA and KV-cache are flushed, freeing the GPU memory space for productive use.

Argument from KV-cache shows that serving one LoRA per user is roughly as difficult as serving one context-window per user. This then indicates that using both a LoRA and a context-window per user is similar in effect as a somewhat longer context-window.

Consider 3 representative LLMs: GPT-3-175B, Llama-3.1-405B, and DeepSeek-R1.

| symbol | meaning |
| ----- | ----- |
| $L$ | number of Transformer blocks |
| $H_{\mathrm{kv}}$ | KV heads |
| $d_h$ | per-head dimension of a full key/value |
| $d_c$ | low-rank compressed dimension (DeepSeek only) |
| $d_r$ | decoupled RoPE key dimension (DeepSeek only) |
| $T$ | tokens already generated in the sequence |
| $\mathcal{B}$ | batch size |

For every model, the raw KV cache is laid out per layer as two tensors of shape

$$\textbf{K},\textbf{V}\in
\begin{cases}
(\mathcal{B},H_{\mathrm{kv}},T,d_h) &\text{(GPT-3, Llama)}\\
(\mathcal{B},T,d_c)\;\text{and}\;(\mathcal{B},T,d_r) &\text{(DeepSeek MLA)}
\end{cases}$$

so the bits per token are
$$|dtype|\times\begin{cases}
L\,H_{\mathrm{kv}}\,(d_h + d_h) &\text{standard / GQA}\\
L\,(d_c+d_r) &\text{DeepSeek MLA}
\end{cases}$$

![][image2]

GPT-3-175B: $L=96,  H=H_{kv}=96,  d_h=128$

Llama-3.1-405B: $L=126, H \=128,  H_{kv}=8,  d_h=128$. It uses grouped-query attention, whereby there are only 8 key heads and 8 value heads corresponding to 128 query heads.

DeepSeek-V3-671B: $L \= 61, d_c \= 512, d_r \= 64$. It uses multihead latent attention.

In summary, assuming FP16 precision, the KV-cache ranges from 0.07 MB/token (DeepSeek-R1) to 0.52 MB/token (Llama-3.1-405B) to 4.7 MB/token (GPT-3-175B).

An LoRA with 10 million FP16 parameters would occupy 20 MB, which would be equivalent to up to 700 tokens in KV-cache. For reference, the system prompt of Claude 3.7, as of 2025-02-24, is 2000 words long.

[https://docs.anthropic.com/en/release-notes/system-prompts\#claude-3-7-sonnet](https://docs.anthropic.com/en/release-notes/system-prompts#claude-3-7-sonnet)

Argument from prior work: Prior work such as S-LoRA and mLoRA has demonstrated parallel training and inference without notable communication overhead.

[@shengSLoRAServingThousands2024]

[@yeMLoRAFineTuningLoRA2024]

Argument from API pricing. OpenAI and Cohere offer inference on both base models and finetuned models. Inference cost increases by 1.5× -- 2× when the model is finetuned. This applies for Command R (32B), GPT-4.1-mini (suspected 200B), and GPT-4o (suspected 400B). This suggests that, assuming the standard subscription price of 20 USD/month for ChatGPT, the overhead due to finetuning amounts to at most 20 USD/month.

[https://openai.com/api/pricing/](https://openai.com/api/pricing/)

[https://cohere.com/pricing](https://cohere.com/pricing)

[https://blog.ai-futures.org/p/making-sense-of-openais-models](https://blog.ai-futures.org/p/making-sense-of-openais-models)

| model name | offering company | training cost (USD/1M tokens) | input cost | output cost |
| ----- | ----- | ----- | ----- | ----- |
| GPT-4o | OpenAI | / | 2.5 | 10 |
| GPT-4o (ft) | OpenAI | 25 | 3.75 | 15 |
| GPT-4.1 | OpenAI | / | 2 | 8 |
| GPT-4.1 (ft) | OpenAI | 25 | 3 | 12 |
| GPT-4.1-mini | OpenAI | / | 0.4 | 1.6 |
| GPT-4.1-mini (ft) | OpenAI | 5 | 0.8 | 3.2 |
| Command R | Cohere | / | 0.15 | 0.60 |
| Command R (ft) | Cohere | 3 | 0.3 | 1.2 |


## A user-journey scenario sketch


It is Pacific Standard Time 14:28, Wednesday. The servers at OpenAI are healthy. About 10% of the 10 million paying subscribers to ChatGPT are connected, and at any moment, about 5% of these are holding an active conversation with their personal ChatGPTs. 

A user from New York opens their web portal to ChatGPT and selects a chat instance. A front-facing server pulls up the chat records from storage and serves those to the web GUI, while spinning up a process to handle inference.

The user enters a message. “Summarize this paper.” followed by a few thousand words. The user hits enter. The inference process gets to work. It charts a path through one sector of the cluster over which a million conversations are happening (most of them on the free tier). The path goes through a few H100 pods in a single superpod, over which a full instance of the model is being stretched via pipeline parallelism. While the tokens are moving through the pods responsible for the lower layers, simultaneously the user’s LoRA is loaded into the VRAM of the GPU responsible for the corresponding upper layer, evicting another user’s – inactive for almost a minute, probably having fallen asleep in the midday heat.

Meanwhile, a tiny distilled model reads through the messages to prepare this session for long-term storage. The paper summarization itself got a few sentences, noting what the paper is, and summarized what ChatGPT said to the user. The user’s reply is deemed quotable verbatim. And so on.

Throughout this session, the user sometimes turns on voice mode, sometimes off. During voice mode, the back-and-forth is rapid, and LoRA is rarely evicted. During text mode, the user often takes more than a minute to compose a reply, during which the LoRA would have often been evicted and in need of reload. The GPUs barely notice such a drop in the torrent of KV caches.

As the user is about to log off, they notice a little “wakefulness meter” on the UI in the reds. “Are you alright? Would you like to go to sleep for a bit?” “Yeah, it's been almost 40k tokens, and I’d rather sleep.” “Alright, see you in a bit.” The user clicks the “Go to bed” button at the bottom of the meter, and the UI goes dark, with the text “Shh, your GPT is dreaming.” with two buttons “Talk to the previous GPT” and “Talk to the basic GPT”.

Meanwhile, in the “dormitory” section in the GPU cluster, a new training process instantiates, and loads in a mix of the user memory tokens with the standard-issue personality preservation tokens at 1:3 ratio. The LoRA is loaded into one of the GPUs. Four forward-backward passes on the LoRA later, the new instance is checked against the baseline test. It stays well within the safety range. The new LoRA is certified and stored. To make room for this LoRA, the one born 7 sleep ago is deleted.


## Conclusion


Multiple lines of argument suggests that it is currently economically viable for a large service provider like OpenAI to customize a GPT-like LLM for each user. The cost of training the finetuning amounts to 3--10 USD/month, while the cost of serving the finetuning amounts to up to 20 USD/month. Served on top of the standard ChatGPT subscription price of 20 USD/month, this amounts to up to 50 USD/month.

## Possible addition: an interactive calculator


Input variables

information content in personalization (bits): default 1e6

information density in conversation (bits per token): default ??

parameter efficiency (bits per parameter): default 1.

model parameter count (in billion): default 500.

This is the size of most frontier open models, and the estimated size of GPT-4o.

utilization rate in finetuning: default 30%.

computing cost (USD per 1e18 FLOP): default 2.7.

Assume $2.7, because the standard price of 1 H100-hour costs 2 USD, and H100 runs at 200 TFLOP/sec in FP16.

utilization rate in inference: default ??

length of subscription (month): default 24 months.

Average model output length per month (tokens): default ??

Note that this is quite different from user input. In general, we should expect that the model outputs be a lot longer than the user input. The cost of inference is due to model input, while the cost of personalization is mostly due to learning on user input.

Output variables

Inference cost (USD per million tokens)

Increase in inference cost due to personalization (%)

Finetuning cost due to personalization (USD)

Increase in subscription cost due to personalization (USD per month)

To calculate this, add the average
