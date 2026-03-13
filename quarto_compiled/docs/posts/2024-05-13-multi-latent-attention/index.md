---
title: "The ultimate tug-of-war between cache and capacity"
subtitle: "from MHA, MQA, GQA to MLA"
author: "Jianlin Su"
date: "2024-05-13"
date-modified: "2024-05-13"
categories: [AI, scaling, translation]
format:
  html:
    toc: true
description: "Translation of a blogpost by the originator of RoPE, describing the GPU-based reasons that guided the design choices of multihead latent attention."

status: "finished"
confidence: "certain"
importance: 3
---

{{< include ../../../static/_macros.tex >}}

A few days ago, the [DeepSeek-V2](https://arxiv.org/abs/2405.04434) released by High-Flyer sparked heated discussions. First, what caused the biggest stir was its 1 million tokens/yuan price, roughly 100x cheaper than competing APIs, to the point that some people joked, "Even if it outputs gibberish at this price, I would consider that gibberish to be art". Secondly, according to the model's technical report, one of the key technologies behind such a low price is its newly proposed MLA (<strong><font color=red>M</font></strong>ulti-head <strong><font color=red>L</font></strong>atent <strong><font color=red>A</font></strong>ttention), which is an improvement over GQA. It is said to be more efficient and better than GQA, which has also attracted widespread attention from readers.

This article walks through the evolution from MHA, MQA, GQA to MLA, gradually introducing the design principles of MLA.

## MHA

MHA (<strong><font color=red>M</font></strong>ulti-<strong><font color=red>H</font></strong>ead <strong><font color=red>A</font></strong>ttention) is a form of attention proposed in the seminal [Attention is all you need](https://arxiv.org/abs/1706.03762), the foundation of current mainstream LLMs. Mathematically, MHA is equivalent to the concatenation of multiple independent single-head attentions. Assuming the input (row) vector sequence is $\boldsymbol{x}_1,\boldsymbol{x}_2,\cdots,\boldsymbol{x}_l$, where $\boldsymbol{x}_i\in\mathbb{R}^d$, then MHA can be formally written as

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{(s)} ,\boldsymbol{v}_{\leq t}^{(s)}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)\boldsymbol{v}_i^{(s)}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d\times d_k}\\
\boldsymbol{k}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_k^{(s)}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_k^{(s)}\in\mathbb{R}^{d\times d_k} \\
\boldsymbol{v}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d\times d_v}
\end{gathered}
\end{equation}
$$

For simplicity, the scaling factor of the Attention matrix is omitted here. In practice, a common setting is $d_k = d_v = d / h$, so we have

| model name | $d$ | $h$ | $d_k$ | $d_v$ |
|---|---|---|---|---|
| `Llama-2-7b` | 4096 | 32 | 128 | 128 |
| `Llama-2-70b` | 8192 | 64 | 128 | 128 |

Since we only consider the causal attention used by mainstream autoregressive LLMs here, when generating recursively token by token, the newly predicted $(t+1)$-th token will not affect the already calculated $\boldsymbol{k}_{\leq t}^{(s)} ,\boldsymbol{v}_{\leq t}^{(s)}$. Therefore, we can cache this part of the result for subsequent generation calls, avoiding unnecessary repeated calculations. This is the so-called **KV Cache**.

The subsequent MQA, GQA, and MLA are all products developed around the theme of "How do we reduce KV Cache while ensuring the best possible performance?".

## Bottleneck

A natural question is: <font color=red>why is reducing the size of the KV Cache so important?</font>

As we all know, LLM inference is generally performed on GPUs, and the VRAM of a single GPU is limited. Part of it is used to store the model parameters and activation values of the forward calculation, which depends on the size of the model and is a constant after the model is selected; the other part is used to store the KV Cache of the model, which depends not only on the size of the model, but also on the input length of the model, which means it grows dynamically during the inference process. When the context length is long enough, its size will dominate, possibly exceeding the total VRAM of a single GPU or even a single node (8 GPUs).

The principle of deploying models on GPUs is: if it can be deployed on one GPU, don't span multiple GPUs; if it can be deployed on one node, don't span multiple nodes. This is because in terms of communication bandwidth, intra-GPU > inter-GPU > inter-node.

The more nodes a model spans during deployment, the more it will be slowed down by the inter-node communication bandwidth, which is the weakest link. In fact, even though the bandwidth of SRAM and HBM in a single H100 GPU has reached 3 TB/s, this speed is still the bottleneck of inference for short context, not to mention the slower inter-GPU and inter-node communication.

Therefore, the purpose of reducing KV Cache is to achieve inference of longer context on fewer nodes, or to allow a larger inference batch size under the same context length, thereby achieving faster inference speed or greater total throughput. Of course, the ultimate goal is to achieve lower inference costs.

To learn more about this issue, I point the reader towards [FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness](https://arxiv.org/abs/2205.14135), [A guide to LLM inference and performance](https://www.baseten.co/blog/llm-transformer-inference-guide/), [LLM inference speed of light](https://zeux.io/2024/03/15/llm-inference-sol/) and other articles. We will not continue to expand here (mainly because I afraid that my limited understanding would mean that the more I write, the more mistakes I will make).

## MQA

MQA, which stands for "<strong><font color=red>M</font></strong>ulti-<strong><font color=red>Q</font></strong>uery <strong><font color=red>A</font></strong>ttention", is a very simple attempt to reduce KV Cache. It was first proposed in [Fast Transformer Decoding: One Write-Head is All You Need](https://arxiv.org/abs/1911.02150) (2019), which means that even before the LLM craze, reducing KV Cache was already a topic of great interest to researchers.

The idea behind MQA is simple: directly let all Attention Heads share the same K and V. In terms of formulas, this means removing the superscript ${}^{(s)}$ from all $\boldsymbol{k},\boldsymbol{v}$ in MHA:

$$
\begin{equation}\require{cancel}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{\color{#ccc}{\smash{\bcancel{(s)}}}} ,\boldsymbol{v}_{\leq t}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}}{}^{\top}\right)\boldsymbol{v}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d\times d_k}\\
\boldsymbol{k}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}} = \boldsymbol{x}_i\boldsymbol{W}_k^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_k^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d\times d_k} \\
\boldsymbol{v}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}} = \boldsymbol{x}_i\boldsymbol{W}_v^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d\times d_v}
\end{gathered}
\end{equation}
$$

Models that use MQA include [PaLM](https://arxiv.org/pdf/2204.02311), [StarCoder](https://arxiv.org/abs/2305.06161), and [Gemini](https://arxiv.org/abs/2312.11805), among others. It's clear that MQA directly reduces the KV Cache to $1/h$ of its original size, which is very significant and, from the perspective of saving video memory alone, is already the upper limit.

In terms of performance, the loss in most tasks appears to be relatively limited, and MQA's supporters believe that this loss can be compensated for through further training. In addition, it's worth noting that because MQA shares K and V, there is just one matrix for projecting the hidden vector to the key vector, and another for projecting to the value vector, instead of $h$ of them. Thus, the number of parameters for Attention will be reduced by nearly half. To keep the total number of model parameters unchanged, the size of feed-forward or gated linear unit is usually increased accordingly, which can also compensate for some of the performance loss.

## GQA 

However, some people are concerned that MQA compresses the KV Cache too much, which could affect the model's learning efficiency and the final results. To address this, a transitional version between MHA and MQA, called GQA (<strong><font color=red>G</font></strong>rouped-<strong><font color=red>Q</font></strong>uery <strong><font color=red>A</font></strong>ttention), was developed. It originated from the paper [GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints](https://arxiv.org/abs/2305.13245), which was published last year.

In retrospect, the idea behind GQA is also quite naive: it divides all Heads into $g$ groups (where $g$ is a divisor of $h$), and each group shares the same KV pair:

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{\color{red}{(\lceil sg/h\rceil)}} ,\boldsymbol{v}_{\leq t}^{\color{red}{(\lceil sg/h\rceil)}}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{\color{red}{(\lceil sg/h\rceil)}}{}^{\top}\right)\boldsymbol{v}_i^{\color{red}{(\lceil sg/h\rceil)}}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{\color{red}{(\lceil sg/h\rceil)}}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d\times d_k}\\
\boldsymbol{k}_i^{\color{red}{(\lceil sg/h\rceil)}} = \boldsymbol{x}_i\boldsymbol{W}_k^{\color{red}{(\lceil sg/h\rceil)}}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_k^{\color{red}{(\lceil sg/h\rceil)}}\in\mathbb{R}^{d\times d_k} \\
\boldsymbol{v}_i^{\color{red}{(\lceil sg/h\rceil)}} = \boldsymbol{x}_i\boldsymbol{W}_v^{\color{red}{(\lceil sg/h\rceil)}}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{\color{red}{(\lceil sg/h\rceil)}}\in\mathbb{R}^{d\times d_v}
\end{gathered}
\end{equation}
$$

Here, $\lceil\cdot\rceil$ is the ceiling function. GQA provides a natural transition from MHA to MQA. When $g=h$, it is MHA; when $g=1$, it is MQA. When $1 < g < h$, it only compresses the KV Cache to $g/h$. The compression rate is not as good as MQA, but it also provides greater flexibility and better guarantees in terms of effectiveness. The most well-known users of GQA are probably Meta's open-source [`Llama-2-70B`](https://llama.meta.com/llama2), and the entire [`Llama-3` series](https://llama.meta.com/llama3/). Other models using GQA include [`TigerBot`](https://arxiv.org/abs/2312.08688), [`DeepSeek-V1`](https://arxiv.org/abs/2401.02954), [`StarCoder2`](https://arxiv.org/abs/2402.19173), [Yi](https://arxiv.org/abs/2403.04652), [`ChatGLM2-6B`](https://github.com/THUDM/ChatGLM2-6B), and [`ChatGLM3`](https://github.com/THUDM/ChatGLM3).[^chatglm] There are many more models using GQA than models using MQA.

[^chatglm]: Though the `ChatGLM` report claims to use "Multi-Query Attention" in [page 3 of the report](https://arxiv.org/pdf/2406.12793#page=3), it is actually using GQA with $g=2$, as you can see in [page 5 of the report](https://arxiv.org/pdf/2406.12793#page=5).

`llama-2/3-70B` uses $g=8$, and it is the same for most other models of similar parameter count that uses GQA. This is not an accident, but a deliberate choice for efficient inference. We know that a model of 70B scale cannot be deployed on a single GPU (A100/H100 80G) without extreme quantization. If a single GPU is not enough, then a single node can be used. Generally, a node contains up to 8 GPUs. As we said earlier, each attention head is actually computed independently and then concatenated. When $g=8$, it is possible to have each GPU to calculate the Attention Head corresponding to one set of KV. This maximizes KV diversity under the constraint of minimal inter-GPU communication.

## MLA

With the groundwork laid by MHA, MQA, and GQA, it becomes relatively easier to understand MLA (<strong><font color=red>M</font></strong>ulti-head <strong><font color=red>L</font></strong>atent <strong><font color=red>A</font></strong>ttention). The technical report for `DeepSeek-V2` introduces MLA from the perspective of low-rank projection, leading some readers to ask questions like "Why has LoRA been around for so long, and yet MLA, which is essentially just low-rank projection applied of KV Cache, took such a long time to appear?".

However, the author believes that the low-rank projection perspective doesn't get to the heart of the matter. Because if we're talking about low-rank projection, the fact is that if we stack all the K and V of GQA together, we'll find that GQA is *also* basically low-rank projection:

$$
\begin{equation}\underbrace{\left[\boldsymbol{k}_i^{(1)},\cdots,\boldsymbol{k}_i^{(g)},\boldsymbol{v}_i^{(1)},\cdots,\boldsymbol{v}_i^{(g)}\right]}_{\boldsymbol{c}_i\in\mathbb{R}^{g(d_k+d_v)}} = \boldsymbol{x}_i \underbrace{\left[\boldsymbol{W}_k^{(1)},\cdots,\boldsymbol{W}_k^{(g)},\boldsymbol{W}_v^{(1)},\cdots,\boldsymbol{W}_v^{(g)}\right]}_{\boldsymbol{W}_c\in\mathbb{R}^{d\times g(d_k+d_v)}}\end{equation}
$$

Here, we combine all $\boldsymbol{k}_i^{(s)},\boldsymbol{v}_i^{(s)}$ and denote them as $\boldsymbol{c}_i$. The corresponding projection matrices are also combined and denoted as $\boldsymbol{W}_c$. Note that generally $d_c = g(d_k+d_v) < d$, such as in `Llama-2-70B` where $g = 8, d_k = d_v = 128$, so $d_c = 2048 < d = 8192$, so the transformation from $\boldsymbol{x}_i$ to $\boldsymbol{c}_i$ is *also* a low-rank projection. Therefore, the essential improvement of MLA is not the low-rank projection itself, but what is done after the low-rank projection.

### Part 1

What does GQA do after the projection? First, it divides the vector $\boldsymbol{c}_i$ into two halves, using them as K and V respectively. Then, each half is further divided into $g$ parts as $\boldsymbol{k}_1^{(s)}, \dots, \boldsymbol{k}_g^{(s)}, \boldsymbol{v}_1^{(s)}, \dots, \boldsymbol{v}_g^{(s)}$, and each is then copied $h/g$ times, in order to "fill up" the K and V needed by $h$ Attention Heads. We know that splitting and copying are simple linear transformations, so MLA's first key idea is to replace these simple linear transformations with general linear transformations to enhance the model's capacity:

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{(s)} ,\boldsymbol{v}_{\leq t}^{(s)}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)\boldsymbol{v}_i^{(s)}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d\times d_k}\\
\boldsymbol{k}_i^{(s)} = \boldsymbol{c}_i\boldsymbol{W}_k^{(s)}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_k^{(s)}\in\mathbb{R}^{d_c\times d_k} \\
\boldsymbol{v}_i^{(s)} = \boldsymbol{c}_i\boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_c\times d_v} \\[10pt]
\boldsymbol{c}_i = \boldsymbol{x}_i \boldsymbol{W}_c\in\mathbb{R}^{d_c},\quad \boldsymbol{W}_c\in\mathbb{R}^{d\times d_c}
\end{gathered}
\end{equation}
$$

However, while this approach theoretically increases the model's capacity, let's not forget that the main purpose of GQA is to reduce KV Cache. For the sake of saving computation and communication costs, we generally cache the projected $\boldsymbol{k}_i, \boldsymbol{v}_i$ rather than the pre-projected $\boldsymbol{c}_i$ or $\boldsymbol{x}_i$. However, MLA's approach, by using different projection matrices, makes all K and V Heads distinct again. This means the KV Cache size would revert to the same size as MHA, which goes against the very design purpose of GQA.

To solve this problem, MLA uses a simple clever identity on the dot-attention to circumvent this problem. First, we proceed as usual during the training. Then, during the inference, we use this identity

$$
\begin{equation}\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top} = \left(\boldsymbol{x}_t\boldsymbol{W}_q^{(s)}\right) \left(\boldsymbol{c}_i\boldsymbol{W}_k^{(s)}\right){}^{\top} = \boldsymbol{x}_t\left(\boldsymbol{W}_q^{(s)}\boldsymbol{W}_k^{(s)}{}^{\top}\right)\boldsymbol{c}_i^{\top} \end{equation}
$$

This means that during the inference phase, we can merge $\boldsymbol{W}_q^{(s)}\boldsymbol{W}_k^{(s)}{}^{\top}$ as the projection matrix for Q.[^merge_wqk] Then, $\boldsymbol{c}_i$ replaces the original $\boldsymbol{k}_i$.

Similarly, since there is another projection matrix after $\boldsymbol{o}_t$, the $\boldsymbol{W}_v^{(s)}$ in $\boldsymbol{v}_i^{(s)} = \boldsymbol{c}_i\boldsymbol{W}_v^{(s)}$ can also be absorbed into the subsequent projection matrix. Thus, equivalently, $\boldsymbol{v}_i$ can also be replaced by $\boldsymbol{c}_i$. Specifically, after the attention weights $\alpha_{tj}^{(s)}$ are computed using the dot-attention mechanism, we upcast the latent vector $\boldsymbol{c}_i$ to the value vector $\boldsymbol{v}_i^{(s)}$ using $\boldsymbol{W}_v^{(s)}$, do a weighted sum with the attention weights, then use a final output projection by $\boldsymbol{W}_o^{(s)}$. We can do the same merge at inference time:

$$
\boldsymbol{v}_t = \sum_{j\leq t} \boldsymbol{c}_j \left(\sum_{s=1}^h \alpha_{tj}^{(s)} \boldsymbol{W}_v^{(s)} \boldsymbol{W}_o^{(s)\top}\right)
$$

This means that at this point, the KV Cache only needs to store all $\boldsymbol{c}_i$, instead of all $\boldsymbol{k}_i^{(s)}$ and $\boldsymbol{v}_i^{(s)}$. Note that $\boldsymbol{c}_i$ is independent of ${}^{(s)}$, which means it is shared by all heads. In other words, during the inference phase, MLA can be converted into an MQA via a clever identity.

[^merge_wqk]: Note a detail here. Merging $\boldsymbol{W}_q^{(s)}\boldsymbol{W}_k^{(s)}{}^{\top}$ into a single matrix is only valid assuming infinite precision. In practice, if we use single precision, especially `BF16`, the precision loss after the matrix-merge is often noticeable. After multiple layers, this loss may become large enough that we would have to post-process.

To reiterate, the key theme of this article has always been reducing the KV Cache. So what has MLA achieved so far? The answer is that it has enhanced the capacity of GQA through different projection matrices, while maintaining the same size of KV Cache during inference. Conversely, if we only need capacities similar to GQA, can we further reduce the KV Cache? In other words, $d_c$ doesn't need to be $g(d_k+d_v)$, but can be a smaller value (`DeepSeek-V2` uses $d_c = 512$), thereby further compressing the KV Cache. This is the key idea of MLA.

### Part 2

Everything seems perfect, and it looks like we're about to finish cooking an ideal design that is both good and economical. But hold on, if we think a little deeper, we'll find that MLA, as it stands, has an unavoidable flaw -- it's incompatible with [RoPE (Rotary Position Embedding)](https://arxiv.org/abs/2104.09864).

We just mentioned that the key step for MLA to maintain the same KV Cache size as GQA is "merging $\boldsymbol{W}_q^{(s)}\boldsymbol{W}_k^{(s)}{}^{\top}$ into a single (position-independent) matrix as the projection matrix for Q". However, if RoPE is added, this step becomes impossible. This is because RoPE is a position-dependent, $d_k\times d_k$ block diagonal matrix $\boldsymbol{\mathcal{R}}_m$, satisfying $\boldsymbol{\mathcal{R}}_m\boldsymbol{\mathcal{R}}_n^{\top}=\boldsymbol{\mathcal{R}}_{m-n}$. When RoPE is added to MLA, it inserts an additional term $\boldsymbol{\mathcal{R}}_{t-i}$ between $\boldsymbol{W}_q^{(s)}$ and $\boldsymbol{W}_k^{(s)}{}^{\top}$:

$$
\begin{equation}
\begin{aligned}
\boldsymbol{q}_i^{(s)} &= \boldsymbol{x}_i\boldsymbol{W}_q^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\\
\boldsymbol{k}_i^{(s)} &= \boldsymbol{c}_i\boldsymbol{W}_k^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i} \\
\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top} &= \left(\boldsymbol{x}_t\boldsymbol{W}_q^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_t}\right) \left(\boldsymbol{c}_i\boldsymbol{W}_k^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right){}^{\top} = \boldsymbol{x}_t\left(\boldsymbol{W}_q^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_{t-i}}\boldsymbol{W}_k^{(s)}{}^{\top}\right)\boldsymbol{c}_i^{\top}
\end{aligned}
\end{equation}
$$

The term $\boldsymbol{W}_q^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_{t-i}}\boldsymbol{W}_k^{(s)}{}^{\top}$ cannot be combined into a static projection matrix (since it's related to the position difference $t-i$, which is not static), thus the key idea of MLA could not be combined with RoPE.

Some time ago, I had the honor of discussing this issue with the DeepSeek team. This problem turned out to be fundamental, so I couldn't actually offer any effective advice at the time. The simplest approach is to just give up RoPE and switch to another position encoding scheme that uses positional encoding based on attention bias, such as [ALiBi](https://arxiv.org/abs/2108.12409). However, DeepSeek's experiments show that it is significantly inferior to RoPE (note that MLA *can* use RoPE, but after adding RoPE, the identity transformation trick cannot be used to reduce KV Cache). I also suggested trying [Sandwich](https://arxiv.org/abs/2212.10356), which doesn't monotonically decay to negative infinity like ALiBi, so it might have better results, but it feels like a band-aid hack, not a real solution. Another compromise is to change the input of $\boldsymbol{q}_i$ to $\boldsymbol{c}_i$ as well, and then add RoPE after $\boldsymbol{c}_i$, i.e.,

$$
\begin{equation}\boldsymbol{q}_i^{(s)} = \boldsymbol{c}_i\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\boldsymbol{W}_q^{(s)},\quad\boldsymbol{k}_i^{(s)} = \boldsymbol{c}_i\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\boldsymbol{W}_k^{(s)}\end{equation}
$$

In this way, $\boldsymbol{\mathcal{R}}_i$ can be absorbed into $\boldsymbol{c}_i$, but then we lose the $\boldsymbol{\mathcal{R}}_m\boldsymbol{\mathcal{R}}_n^{\top}=\boldsymbol{\mathcal{R}}_{m-n}$ operation. In this case, RoPE no longer implements relative position through absolute position, but simply adds absolute positions to Q and K, forcing the model to learn end-to-end how to extract the relative position information that it needs to do its job.

The final released MLA adopts a hybrid approach -- each Attention Head's Q and K adds $d_r$ dimensions for adding RoPE, where the added dimensions for K are shared across all Heads:

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{(s)} ,\boldsymbol{v}_{\leq t}^{(s)}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)\boldsymbol{v}_i^{(s)}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \left[\boldsymbol{x}_i\boldsymbol{W}_{qc}^{(s)}, \boldsymbol{x}_i\boldsymbol{W}_{qr}^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right]\in\mathbb{R}^{d_k + d_r},\quad \boldsymbol{W}_{qc}^{(s)}\in\mathbb{R}^{d\times d_k},\boldsymbol{W}_{qr}^{(s)}\in\mathbb{R}^{d\times d_r}\\
\boldsymbol{k}_i^{(s)} = \left[\boldsymbol{c}_i\boldsymbol{W}_{kc}^{(s)}, \boldsymbol{x}_i\boldsymbol{W}_{kr}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right]\in\mathbb{R}^{d_k+d_r},\quad \boldsymbol{W}_{kc}^{(s)}\in\mathbb{R}^{d_c\times d_k}, \boldsymbol{W}_{kr}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d\times d_r} \\
\boldsymbol{v}_i^{(s)} = \boldsymbol{c}_i\boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_c\times d_v} \\[10pt]
\boldsymbol{c}_i = \boldsymbol{x}_i \boldsymbol{W}_c\in\mathbb{R}^{d_c},\quad \boldsymbol{W}_c\in\mathbb{R}^{d\times d_c}
\end{gathered}
\end{equation}
$$

In this way, the dimensions without RoPE can repeat the operation described in [Part 1](#part-1). During inference, the KV Cache only needs to store $\boldsymbol{c}_i$. The newly added dimensions with RoPE can be used to supplement positional information. And since all Heads share them, only $d_r$ dimensions are added to the K Cache. The original paper took $d_r = d_k / 2 = 64$, which is a small increase compared to the original $d_c = 512$.

### Part 3

One final detail: the final iteration of MLA also changes the input of Q to a low-rank projection form. This is not related to reducing KV Cache, but mainly to reduce the amount of parameters and the corresponding gradients[^lora-query] during training that occupy GPU memory:

[^lora-query]: The original paper said "Moreover, in order to reduce the activation memory during training, we also perform low-rank compression for the queries, even if it cannot reduce the KV cache", which I personally don't quite understand.

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{(s)} ,\boldsymbol{v}_{\leq t}^{(s)}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)\boldsymbol{v}_i^{(s)}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \left[\boldsymbol{c}_i'\boldsymbol{W}_{qc}^{(s)}, \boldsymbol{c}_i'\boldsymbol{W}_{qr}^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right]\in\mathbb{R}^{d_k + d_r},\quad \boldsymbol{W}_{qc}^{(s)}\in\mathbb{R}^{d_c'\times d_k},\boldsymbol{W}_{qr}^{(s)}\in\mathbb{R}^{d_c'\times d_r}\\
\boldsymbol{k}_i^{(s)} = \left[\boldsymbol{c}_i\boldsymbol{W}_{kc}^{(s)}, \boldsymbol{x}_i\boldsymbol{W}_{kr}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right]\in\mathbb{R}^{d_k+d_r},\quad \boldsymbol{W}_{kc}^{(s)}\in\mathbb{R}^{d_c\times d_k}, \boldsymbol{W}_{kr}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d\times d_r} \\
\boldsymbol{v}_i^{(s)} = \boldsymbol{c}_i\boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_c\times d_v} \\[10pt]
\boldsymbol{c}_i' = \boldsymbol{x}_i \boldsymbol{W}_c'\in\mathbb{R}^{d_c'},\quad \boldsymbol{W}_c'\in\mathbb{R}^{d\times d_c'} \\
\boldsymbol{c}_i = \boldsymbol{x}_i \boldsymbol{W}_c\in\mathbb{R}^{d_c},\quad \boldsymbol{W}_c\in\mathbb{R}^{d\times d_c} \\
\end{gathered}
\end{equation}
$$

Note the second term in $\boldsymbol{k}_i^{(s)}$, the part with RoPE, its input is still $\boldsymbol{x}_i$ and not $\boldsymbol{c}_i$. This maintains the original paper's setting, and it's not a typo. Also, $d_c' = 1536$ in the original paper, which is different from $d_c=512$. Also, we put the MHA with RoPE below for easy comparison:

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}, \boldsymbol{o}_t^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{(s)} ,\boldsymbol{v}_{\leq t}^{(s)}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)\boldsymbol{v}_i^{(s)}}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{(s)}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_q^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_q^{(s)}\in\mathbb{R}^{d\times d_k}\\
\boldsymbol{k}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_k^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\in\mathbb{R}^{d_k},\quad \boldsymbol{W}_k^{(s)}\in\mathbb{R}^{d\times d_k} \\
\boldsymbol{v}_i^{(s)} = \boldsymbol{x}_i\boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d_v},\quad \boldsymbol{W}_v^{(s)}\in\mathbb{R}^{d\times d_v}
\end{gathered}
\end{equation}
$$

It can be observed that, during the training phase, apart from an additional low-rank projection step and RoPE being added only in some dimensions, MLA is essentially the same as MHA where the Q and K Head Size is changed from $d_k$ to $d_k + d_r$.

The MLA in the inference phase is changed to:

$$
\begin{equation}
\begin{gathered}
\boldsymbol{o}_t = \left[\boldsymbol{o}_t^{(1)}\boldsymbol{W}_v^{(1)}, \boldsymbol{o}_t^{(2)}\boldsymbol{W}_v^{(2)}, \cdots, \boldsymbol{o}_t^{(h)}\boldsymbol{W}_v^{(h)}\right] \\[10pt]
\boldsymbol{o}_t^{(s)} = \mathrm{Attention}\left(\boldsymbol{q}_t^{(s)}, \boldsymbol{k}_{\leq t}^{\color{#ccc}{\smash{\bcancel{(s)}}}} ,\boldsymbol{c}_{\leq t}\right)\triangleq\frac{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}}{}^{\top}\right)\boldsymbol{c}_i}{\sum_{i\leq t}\exp\left(\boldsymbol{q}_t^{(s)} \boldsymbol{k}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}}{}^{\top}\right)} \\[15pt]
\boldsymbol{q}_i^{(s)} = \left[\boldsymbol{c}_i'\boldsymbol{W}_{qc}^{(s)}\boldsymbol{W}_{kc}^{(s)}{}^{\top}, \boldsymbol{c}_i'\boldsymbol{W}_{qr}^{(s)}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right]\in\mathbb{R}^{d_c + d_r}\\
\boldsymbol{k}_i^{\color{#ccc}{\smash{\bcancel{(s)}}}} = \left[\boldsymbol{c}_i, \boldsymbol{x}_i\boldsymbol{W}_{kr}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\color{#3ce2f7}{\boldsymbol{\mathcal{R}}_i}\right]\in\mathbb{R}^{d_c+d_r}\\
\boldsymbol{W}_{qc}^{(s)}\in\mathbb{R}^{d_c'\times d_k},\boldsymbol{W}_{kc}^{(s)}\in\mathbb{R}^{d_c\times d_k},\boldsymbol{W}_{qr}^{(s)}\in\mathbb{R}^{d_c'\times d_r},\boldsymbol{W}_{kr}^{\color{#ccc}{\smash{\bcancel{(s)}}}}\in\mathbb{R}^{d\times d_r} \\[10pt]
\boldsymbol{c}_i' = \boldsymbol{x}_i \boldsymbol{W}_c'\in\mathbb{R}^{d_c'},\quad \boldsymbol{W}_c'\in\mathbb{R}^{d\times d_c'} \\
\boldsymbol{c}_i = \boldsymbol{x}_i \boldsymbol{W}_c\in\mathbb{R}^{d_c},\quad \boldsymbol{W}_c\in\mathbb{R}^{d\times d_c} \\
\end{gathered}
\end{equation}
$$

At this point, the Head Size of Q and K becomes $d_c + d_r$, while the Head Size of V becomes $d_c$. According to the original paper's settings, this is equal to $4d_k = 4d_v$. So this inference-time change, although in effect reduces the KV Cache, increases the computational cost of inference.

So why does it still improve inference efficiency? This brings us back to the issue discussed in the [Bottleneck](#bottleneck) section. We can divide LLM inference into two parts: inference on the prompt for generating the first Token (Prefill) and generating each subsequent token (Generation). The Prefill stage involves parallel computation over all tokens in the prompt and storing the corresponding KV Cache. This stage can be bottlenecked by all of computation, bandwidth, and memory. Although MLA increases the computational cost, the reduction in KV Cache also reduces the pressure on memory and bandwidth, so it's roughly equal trade-off without benefit or cost. However, in the Generation stage, since only one token is computed at each step, it is only bottlenecked by bandwidth and memory. Therefore, the introduction of MLA can theoretically significantly improve the speed of Generation.

There is another detail that fully reflects this characteristic. In a typical LLM architecture, the parameters satisfy $h \times d_k = d$, meaning `num_heads * head_size = hidden_size`. However, `DeepSeek-V2` is different. It has $d_k=128, d=5120$, but $h=128$, which is 3 times the usual setting! This is because the KV Cache size of MLA is independent of $h$, thus, increasing $h$ only increases the computational cost and improves the model's ability, but it does not increase the KV Cache, so it does not cause a speed bottleneck.

## Summary

This article briefly outlines the evolution of multi-head attention, particularly the changes in concept from MHA to MQA, GQA, and finally to MLA, and then elaborates on the details of MLA. In this article, MLA is regarded as a generalization of GQA. It replaces GQA's splitting and replication with projection matrices, and introduces an identity transform to further compress the KV Cache, while adopting a hybrid method to be compatible with RoPE. Overall, MLA is a very practical variant of the attention mechanism.

## Metadata {.appendix}

Original is [缓存与效果的极限拉扯：从MHA、MQA、GQA到MLA](https://kexue.fm/archives/10091) posted on the homepage of Jianlin Su (苏剑林).

I added some extra explanatory notes here and there.